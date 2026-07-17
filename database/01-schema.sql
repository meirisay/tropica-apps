-- ============================================================
-- Tropica Farm — Skema database (Supabase / PostgreSQL)
-- LANGKAH 1: fondasi tabel + aturan akses (RLS) + perhitungan otomatis
--
-- Cara jalankan:
--   Supabase Dashboard -> SQL Editor -> New query -> tempel SEMUA isi
--   file ini -> Run. Aman dijalankan berulang (pakai IF NOT EXISTS).
--   Tidak mengganggu tabel kv_store yang lama.
-- ============================================================

create extension if not exists pgcrypto;

-- ------------------------------------------------------------
-- 0. PROFIL PENGGUNA + HELPER ROLE
-- ------------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  nama       text,
  email      text,
  role       text not null default 'sales'
             check (role in ('owner','keuangan','admin','sales')),
  created_at timestamptz default now()
);

-- Ambil role user yang sedang login. SECURITY DEFINER supaya tidak
-- rekursif dengan RLS tabel profiles.
create or replace function public.my_role()
returns text language sql stable security definer set search_path = public
as $$ select role from public.profiles where id = auth.uid() $$;

-- ------------------------------------------------------------
-- 1. MASTER DATA
-- ------------------------------------------------------------
create table if not exists public.buyers (
  id         uuid primary key default gen_random_uuid(),
  nama       text not null,
  kontak     text,
  alamat     text,
  npwp       text,
  created_at timestamptz default now(),
  created_by uuid default auth.uid()
);

create table if not exists public.suppliers (
  id         uuid primary key default gen_random_uuid(),
  nama       text not null,
  kontak     text,
  rekening   text,
  created_at timestamptz default now(),
  created_by uuid default auth.uid()
);

-- ------------------------------------------------------------
-- 2. INTI ORDER
-- ------------------------------------------------------------
create table if not exists public.orders (
  id                uuid primary key default gen_random_uuid(),
  no_order          text unique not null,
  buyer_id          uuid references public.buyers(id),
  status            text not null default 'sample'
                    check (status in ('sample','sample_approve','po','dp',
                                       'produksi','kirim','lunas','batal')),
  nilai_jual        numeric(16,2) default 0,
  po_masuk_no       text,
  po_masuk_tanggal  date,
  tanggal_order     date default current_date,
  pic_sales         uuid references public.profiles(id),
  total_bayar_buyer numeric(16,2) default 0,   -- diisi otomatis oleh trigger
  catatan           text,
  created_at        timestamptz default now()
);

create table if not exists public.order_docs (
  id         uuid primary key default gen_random_uuid(),
  order_id   uuid references public.orders(id) on delete cascade,
  jenis      text check (jenis in ('pi_sample','pi_dp','invoice','invoice_sample')),
  nomor      text,
  tanggal    date,
  nilai      numeric(16,2) default 0,
  status     text default 'terbit' check (status in ('draft','terbit','lunas')),
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 3. SISI PEMBELIAN (SUPPLIER)
-- ------------------------------------------------------------
create table if not exists public.purchase_orders (
  id         uuid primary key default gen_random_uuid(),
  no_po      text unique not null,
  order_id   uuid references public.orders(id),
  supplier_id uuid references public.suppliers(id),
  tanggal    date default current_date,
  total      numeric(16,2) default 0,
  status     text default 'draft' check (status in ('draft','terkirim','barang_datang')),
  created_at timestamptz default now()
);

create table if not exists public.supplier_bills (
  id            uuid primary key default gen_random_uuid(),
  no_tagihan    text,
  po_id         uuid references public.purchase_orders(id),
  order_id      uuid references public.orders(id),
  supplier_id   uuid references public.suppliers(id),
  nilai         numeric(16,2) default 0,
  tanggal_terima date default current_date,
  jatuh_tempo   date,
  jenis         text default 'pemenuhan_po' check (jenis in ('pemenuhan_po','operasional')),
  status        text default 'belum' check (status in ('belum','sebagian','lunas')),
  created_at    timestamptz default now()
);

create table if not exists public.bill_payments (
  id             uuid primary key default gen_random_uuid(),
  bill_id        uuid references public.supplier_bills(id) on delete cascade,
  tanggal        date default current_date,
  jumlah         numeric(16,2) default 0,
  transaction_id uuid,
  created_at     timestamptz default now()
);

-- ------------------------------------------------------------
-- 4. PENGIRIMAN (BUKU KIRIM)
-- ------------------------------------------------------------
create table if not exists public.shipments (
  id            uuid primary key default gen_random_uuid(),
  no_kirim      text unique not null,
  order_id      uuid references public.orders(id),
  buyer_id      uuid references public.buyers(id),
  jenis         text check (jenis in ('sample','barang','dokumen')),
  ekspedisi     text,
  no_resi       text,
  tanggal_kirim date default current_date,
  tanggal_terima date,
  status        text default 'dikirim' check (status in ('dikirim','diterima')),
  catatan       text,
  created_at    timestamptz default now()
);

create table if not exists public.shipment_items (
  id          uuid primary key default gen_random_uuid(),
  shipment_id uuid references public.shipments(id) on delete cascade,
  nama_item   text,
  qty         text,
  supplier_id uuid references public.suppliers(id)
);

create table if not exists public.shipment_docs (
  id          uuid primary key default gen_random_uuid(),
  shipment_id uuid references public.shipments(id) on delete cascade,
  jenis_dok   text,
  nomor       text,
  lembar      integer default 1
);

-- ------------------------------------------------------------
-- 5. KEUANGAN — BUKU BESAR ARUS KAS
-- ------------------------------------------------------------
create table if not exists public.transactions (
  id         uuid primary key default gen_random_uuid(),
  tanggal    date default current_date,
  arah       text check (arah in ('masuk','keluar')),
  jenis      text check (jenis in ('dp','pelunasan','hpp','biaya_usaha',
                                    'modal','bayar_hutang','lain')),
  jumlah     numeric(16,2) default 0,
  order_id   uuid references public.orders(id),
  kategori   text,
  catatan    text,
  created_by uuid default auth.uid(),
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 6. OTOMATIS: sinkron total bayar buyer ke orders
--    (supaya Piutang bisa dihitung tanpa membuka tabel transactions)
-- ------------------------------------------------------------
create or replace function public.sync_order_bayar()
returns trigger language plpgsql security definer set search_path = public
as $$
declare oid uuid;
begin
  oid := coalesce(new.order_id, old.order_id);
  if oid is not null then
    update public.orders o
       set total_bayar_buyer = coalesce((
             select sum(t.jumlah) from public.transactions t
              where t.order_id = oid
                and t.arah = 'masuk'
                and t.jenis in ('dp','pelunasan')), 0)
     where o.id = oid;
  end if;
  return null;
end $$;

drop trigger if exists trg_sync_bayar on public.transactions;
create trigger trg_sync_bayar
  after insert or update or delete on public.transactions
  for each row execute function public.sync_order_bayar();

-- ------------------------------------------------------------
-- 7. PERHITUNGAN OTOMATIS PER ORDER (HPP, kas keluar, talangan, laba)
--    security_invoker = on  -> RLS ikut berlaku, jadi Sales tidak
--    melihat kolom biaya (nilainya kosong untuk role yang tak berhak).
-- ------------------------------------------------------------
create or replace view public.v_order_summary
with (security_invoker = on) as
select s.*,
       greatest(s.kas_keluar - s.masuk_buyer, 0) as talangan_modal,
       (s.nilai_jual - s.hpp)                    as laba
from (
  select o.id,
         o.no_order,
         o.status,
         o.nilai_jual,
         o.total_bayar_buyer                       as masuk_buyer,
         (o.nilai_jual - o.total_bayar_buyer)      as piutang,
         coalesce((select sum(b.nilai) from public.supplier_bills b
                    where b.order_id = o.id and b.jenis = 'pemenuhan_po'), 0) as hpp,
         coalesce((select sum(p.jumlah) from public.bill_payments p
                    join public.supplier_bills b on b.id = p.bill_id
                   where b.order_id = o.id), 0)     as kas_keluar
  from public.orders o
) s;

-- ============================================================
-- 8. AKTIFKAN RLS + ATURAN AKSES PER ROLE
--    Pola: policy "read" (siapa boleh lihat) + "write" (siapa boleh ubah)
-- ============================================================
alter table public.profiles        enable row level security;
alter table public.buyers          enable row level security;
alter table public.suppliers       enable row level security;
alter table public.orders          enable row level security;
alter table public.order_docs      enable row level security;
alter table public.purchase_orders enable row level security;
alter table public.supplier_bills  enable row level security;
alter table public.bill_payments   enable row level security;
alter table public.shipments       enable row level security;
alter table public.shipment_items  enable row level security;
alter table public.shipment_docs   enable row level security;
alter table public.transactions    enable row level security;

-- profiles: lihat profil sendiri; owner/keuangan lihat semua
drop policy if exists p_profiles_read on public.profiles;
create policy p_profiles_read on public.profiles for select to authenticated
  using (id = auth.uid() or public.my_role() in ('owner','keuangan'));
drop policy if exists p_profiles_write on public.profiles;
create policy p_profiles_write on public.profiles for all to authenticated
  using (public.my_role() = 'owner') with check (public.my_role() = 'owner');

-- buyers & suppliers: semua yang login boleh lihat & catat
drop policy if exists p_buyers_read on public.buyers;
create policy p_buyers_read on public.buyers for select to authenticated using (true);
drop policy if exists p_buyers_write on public.buyers;
create policy p_buyers_write on public.buyers for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','sales'))
  with check (public.my_role() in ('owner','keuangan','admin','sales'));

drop policy if exists p_suppliers_read on public.suppliers;
create policy p_suppliers_read on public.suppliers for select to authenticated using (true);
drop policy if exists p_suppliers_write on public.suppliers;
create policy p_suppliers_write on public.suppliers for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','sales'))
  with check (public.my_role() in ('owner','keuangan','admin','sales'));

-- orders: semua boleh lihat (kolom biaya tidak ada di tabel ini).
-- Tulis: owner, keuangan, sales (Admin terkunci dari Daftar Order).
drop policy if exists p_orders_read on public.orders;
create policy p_orders_read on public.orders for select to authenticated using (true);
drop policy if exists p_orders_write on public.orders;
create policy p_orders_write on public.orders for all to authenticated
  using (public.my_role() in ('owner','keuangan','sales'))
  with check (public.my_role() in ('owner','keuangan','sales'));

-- order_docs (PI & Invoice): owner, keuangan, sales (Admin terkunci)
drop policy if exists p_docs_read on public.order_docs;
create policy p_docs_read on public.order_docs for select to authenticated
  using (public.my_role() in ('owner','keuangan','sales'));
drop policy if exists p_docs_write on public.order_docs;
create policy p_docs_write on public.order_docs for all to authenticated
  using (public.my_role() in ('owner','keuangan','sales'))
  with check (public.my_role() in ('owner','keuangan','sales'));

-- purchase_orders (PO keluar): owner, keuangan, sales (Admin terkunci)
drop policy if exists p_po_read on public.purchase_orders;
create policy p_po_read on public.purchase_orders for select to authenticated
  using (public.my_role() in ('owner','keuangan','sales'));
drop policy if exists p_po_write on public.purchase_orders;
create policy p_po_write on public.purchase_orders for all to authenticated
  using (public.my_role() in ('owner','keuangan','sales'))
  with check (public.my_role() in ('owner','keuangan','sales'));

-- supplier_bills (tagihan): owner, keuangan, admin (Sales terkunci)
drop policy if exists p_bills_read on public.supplier_bills;
create policy p_bills_read on public.supplier_bills for select to authenticated
  using (public.my_role() in ('owner','keuangan','admin'));
drop policy if exists p_bills_write on public.supplier_bills;
create policy p_bills_write on public.supplier_bills for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin'))
  with check (public.my_role() in ('owner','keuangan','admin'));

-- bill_payments (pembayaran): owner, keuangan saja
drop policy if exists p_pay_read on public.bill_payments;
create policy p_pay_read on public.bill_payments for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
drop policy if exists p_pay_write on public.bill_payments;
create policy p_pay_write on public.bill_payments for all to authenticated
  using (public.my_role() in ('owner','keuangan'))
  with check (public.my_role() in ('owner','keuangan'));

-- shipments + isinya: semua boleh lihat; catat oleh owner/keuangan/admin/sales
drop policy if exists p_ship_read on public.shipments;
create policy p_ship_read on public.shipments for select to authenticated using (true);
drop policy if exists p_ship_write on public.shipments;
create policy p_ship_write on public.shipments for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','sales'))
  with check (public.my_role() in ('owner','keuangan','admin','sales'));

drop policy if exists p_shipit_read on public.shipment_items;
create policy p_shipit_read on public.shipment_items for select to authenticated using (true);
drop policy if exists p_shipit_write on public.shipment_items;
create policy p_shipit_write on public.shipment_items for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','sales'))
  with check (public.my_role() in ('owner','keuangan','admin','sales'));

drop policy if exists p_shipdoc_read on public.shipment_docs;
create policy p_shipdoc_read on public.shipment_docs for select to authenticated using (true);
drop policy if exists p_shipdoc_write on public.shipment_docs;
create policy p_shipdoc_write on public.shipment_docs for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','sales'))
  with check (public.my_role() in ('owner','keuangan','admin','sales'));

-- transactions (arus kas): owner, keuangan saja
drop policy if exists p_tx_read on public.transactions;
create policy p_tx_read on public.transactions for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
drop policy if exists p_tx_write on public.transactions;
create policy p_tx_write on public.transactions for all to authenticated
  using (public.my_role() in ('owner','keuangan'))
  with check (public.my_role() in ('owner','keuangan'));

-- ============================================================
-- Selesai Langkah 1. Berikutnya: buat akun tiap divisi lalu isi
-- tabel profiles (Langkah 2).
-- ============================================================
