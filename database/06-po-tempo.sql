-- ============================================================
-- Tropica Farm — PO keluar: tambah jatuh tempo & status bayar
-- (menyamakan PO keluar dengan tagihan supplier)
-- Aman dijalankan berulang.
-- ============================================================
alter table public.purchase_orders add column if not exists jatuh_tempo  date;
alter table public.purchase_orders add column if not exists bayar_status text default 'belum';
