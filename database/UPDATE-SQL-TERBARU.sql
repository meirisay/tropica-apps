-- ============================================================
-- Tropica Farm — KUMPULAN UPDATE SQL (jalankan SEKALI di Supabase)
-- Supabase -> SQL Editor -> New query -> tempel semua -> Run.
-- Aman diulang (pakai IF NOT EXISTS / CREATE OR REPLACE).
--
-- Tanpa ini, aplikasi akan error saat memuat Order/PO/Pengiriman
-- dan tombol Hapus order tidak berfungsi.
-- ============================================================

-- [2026-07-16] PO keluar: jatuh tempo + status bayar
alter table public.purchase_orders add column if not exists jatuh_tempo  date;
alter table public.purchase_orders add column if not exists bayar_status text default 'belum';

-- [07] Pisah Nilai Sample dari Nilai Jual (PO)
alter table public.orders
  add column if not exists nilai_sample numeric(16,2) default 0;

-- [09] Deadline pengiriman pada PO keluar (batas supplier kirim barang)
alter table public.purchase_orders
  add column if not exists deadline_kirim date;

-- [10] Detail item pengiriman untuk Delivery Order
alter table public.shipment_items
  add column if not exists jumlah     text,
  add column if not exists netto      text,
  add column if not exists keterangan text;

-- [11] Histori item sample saat order sample dilanjutkan jadi PO
alter table public.orders
  add column if not exists items_sample jsonb default '[]'::jsonb;

-- [08] Hapus order beserta SEMUA data terkait (atomik)
create or replace function public.delete_order_cascade(p_order uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if public.my_role() not in ('owner','keuangan','sales') then
    raise exception 'Tidak diizinkan menghapus order';
  end if;

  delete from public.transactions where order_id = p_order;
  delete from public.supplier_bills
    where order_id = p_order
       or po_id in (select id from public.purchase_orders where order_id = p_order);
  delete from public.purchase_orders where order_id = p_order;
  delete from public.shipments where order_id = p_order;
  delete from public.order_docs where order_id = p_order;
  delete from public.orders where id = p_order;
end;
$$;

grant execute on function public.delete_order_cascade(uuid) to authenticated;

-- [12] Modul Keuangan: Modal (setoran) + Investor + Bagi Hasil (owner/keuangan)
create table if not exists public.investors (
  id         uuid primary key default gen_random_uuid(),
  nama       text not null,
  tipe       text default 'sesekali',
  persen     numeric(6,2),
  catatan    text,
  created_at timestamptz default now()
);
create table if not exists public.modal_setoran (
  id          uuid primary key default gen_random_uuid(),
  investor_id uuid references public.investors(id) on delete set null,
  nama        text,
  tanggal     date,
  jumlah      numeric(16,2) default 0,
  catatan     text,
  created_at  timestamptz default now()
);
create table if not exists public.bagi_hasil (
  id          uuid primary key default gen_random_uuid(),
  investor_id uuid references public.investors(id) on delete set null,
  order_id    uuid references public.orders(id) on delete set null,
  order_no    text,
  dasar       text,
  tanggal     date,
  jumlah      numeric(16,2) default 0,
  catatan     text,
  created_at  timestamptz default now()
);
alter table public.investors     enable row level security;
alter table public.modal_setoran enable row level security;
alter table public.bagi_hasil    enable row level security;
drop policy if exists p_investors_read      on public.investors;
drop policy if exists p_investors_write     on public.investors;
drop policy if exists p_modal_setoran_read  on public.modal_setoran;
drop policy if exists p_modal_setoran_write on public.modal_setoran;
drop policy if exists p_bagi_hasil_read     on public.bagi_hasil;
drop policy if exists p_bagi_hasil_write    on public.bagi_hasil;
create policy p_investors_read on public.investors for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
create policy p_investors_write on public.investors for all to authenticated
  using (public.my_role() in ('owner','keuangan')) with check (public.my_role() in ('owner','keuangan'));
create policy p_modal_setoran_read on public.modal_setoran for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
create policy p_modal_setoran_write on public.modal_setoran for all to authenticated
  using (public.my_role() in ('owner','keuangan')) with check (public.my_role() in ('owner','keuangan'));
create policy p_bagi_hasil_read on public.bagi_hasil for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
create policy p_bagi_hasil_write on public.bagi_hasil for all to authenticated
  using (public.my_role() in ('owner','keuangan')) with check (public.my_role() in ('owner','keuangan'));

-- [13] Modul Keuangan: Aset tetap + Pinjaman/hutang (owner/keuangan)
create table if not exists public.aset_tetap (
  id         uuid primary key default gen_random_uuid(),
  nama       text not null,
  tanggal    date,
  nilai      numeric(16,2) default 0,
  catatan    text,
  created_at timestamptz default now()
);
create table if not exists public.pinjaman (
  id         uuid primary key default gen_random_uuid(),
  pemberi    text not null,
  tanggal    date,
  jumlah     numeric(16,2) default 0,
  status     text default 'belum',
  catatan    text,
  created_at timestamptz default now()
);
alter table public.aset_tetap enable row level security;
alter table public.pinjaman   enable row level security;
drop policy if exists p_aset_tetap_read  on public.aset_tetap;
drop policy if exists p_aset_tetap_write on public.aset_tetap;
drop policy if exists p_pinjaman_read    on public.pinjaman;
drop policy if exists p_pinjaman_write   on public.pinjaman;
create policy p_aset_tetap_read on public.aset_tetap for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
create policy p_aset_tetap_write on public.aset_tetap for all to authenticated
  using (public.my_role() in ('owner','keuangan')) with check (public.my_role() in ('owner','keuangan'));
create policy p_pinjaman_read on public.pinjaman for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
create policy p_pinjaman_write on public.pinjaman for all to authenticated
  using (public.my_role() in ('owner','keuangan')) with check (public.my_role() in ('owner','keuangan'));

-- Selesai. Setelah muncul "Success", buka aplikasi dan uji coba.
