-- 14 · PERSEDIAAN / STOK
-- Izinkan tagihan supplier berjenis 'persediaan' (pembelian stok TANPA order buyer).
-- Stok ini masuk ke ASET (Persediaan) di Neraca, BUKAN HPP — laba baru terpengaruh
-- saat stok dialokasikan ke order buyer (Tahap 2).
--
-- Cara jalankan: buka Supabase project → SQL Editor → tempel & Run.
-- Aman diulang (idempotent).

alter table public.supplier_bills
  drop constraint if exists supplier_bills_jenis_check;

alter table public.supplier_bills
  add constraint supplier_bills_jenis_check
  check (jenis in ('pemenuhan_po','operasional','persediaan'));

-- Catatan:
-- • purchase_orders.order_id sudah nullable → PO stok tanpa order tidak perlu perubahan struktur.
-- • v_order_summary.hpp hanya menjumlah bill jenis 'pemenuhan_po' yang punya order_id,
--   jadi bill 'persediaan' otomatis TIDAK masuk HPP. Tidak ada perubahan view yang diperlukan.
