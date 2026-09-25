-- 17 · ALOKASI STOK SEBAGIAN KE BEBERAPA ORDER
-- Sebelumnya satu tagihan stok (jenis 'persediaan') hanya bisa dialokasikan UTUH ke SATU order
-- (kolom order_id + jenis diubah jadi 'pemenuhan_po'). Sekarang satu tagihan stok bisa dipecah:
-- sebagian ke order A, sebagian ke order B, sisanya tetap di Aset persediaan.
--
-- Tagihan aslinya TIDAK diubah (nomor tagihan, nilai, pembayaran tetap satu) — yang disimpan
-- hanya "berapa rupiah dari tagihan ini menjadi HPP order mana".
--
-- Cara jalankan: Supabase → SQL Editor → tempel & Run. Aman diulang (idempotent).

create table if not exists public.stock_allocations (
  id          uuid primary key default gen_random_uuid(),
  bill_id     uuid not null references public.supplier_bills(id) on delete cascade,
  order_id    uuid not null references public.orders(id) on delete cascade,
  nilai       numeric(16,2) not null default 0,   -- porsi rupiah = qty × harga item (+PPN bila tagihan ber-PPN)
  item        text,                               -- nama item di tagihan yang dipakai (untuk hitung sisa qty per item)
  qty         numeric(14,3),                      -- jumlah barang yang dialokasikan (kosong bila tagihan tanpa rincian item)
  satuan      text,
  keterangan  text,
  created_at  timestamptz default now()
);
create index if not exists stock_allocations_bill_idx  on public.stock_allocations(bill_id);
create index if not exists stock_allocations_order_idx on public.stock_allocations(order_id);

alter table public.stock_allocations enable row level security;

-- Baca: sama seperti tagihan supplier (owner, keuangan, staff) supaya view HPP tetap bisa dihitung.
drop policy if exists p_alloc_read on public.stock_allocations;
create policy p_alloc_read on public.stock_allocations for select to authenticated
  using (public.my_role() in ('owner','keuangan','staff'));
-- Tulis: hanya owner & keuangan (alokasi mengubah HPP/laba order).
drop policy if exists p_alloc_write on public.stock_allocations;
create policy p_alloc_write on public.stock_allocations for all to authenticated
  using (public.my_role() in ('owner','keuangan'))
  with check (public.my_role() in ('owner','keuangan'));

-- View ringkasan order: HPP ikut menghitung porsi stok yang dialokasikan ke order itu.
-- Kas keluar ikut proporsional (porsi alokasi ÷ nilai tagihan × pembayaran tagihan).
drop view if exists public.v_order_summary;
create view public.v_order_summary
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
                    where b.order_id = o.id and b.jenis = 'pemenuhan_po'), 0)
         + coalesce((select sum(a.nilai) from public.stock_allocations a
                    where a.order_id = o.id), 0)   as hpp,
         coalesce((select sum(p.jumlah) from public.bill_payments p
                    join public.supplier_bills b on b.id = p.bill_id
                   where b.order_id = o.id), 0)
         + coalesce((select sum(
                        case when coalesce(b.nilai,0) > 0
                             then a.nilai / b.nilai * coalesce((select sum(p.jumlah) from public.bill_payments p where p.bill_id = b.id), 0)
                             else 0 end)
                     from public.stock_allocations a
                     join public.supplier_bills b on b.id = a.bill_id
                    where a.order_id = o.id), 0)   as kas_keluar
  from public.orders o
) s;

-- Selesai. Setelah muncul "Success", buka aplikasi → Tagihan Supplier → tombol "Alokasikan".
