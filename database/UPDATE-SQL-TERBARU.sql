-- ============================================================
-- Tropica Farm — KUMPULAN UPDATE SQL (jalankan sekali kapan pun siap)
-- Aman dijalankan berulang. Jalankan di Supabase -> SQL Editor -> Run.
-- File ini akan terus diperbarui setiap ada perubahan struktur baru.
-- ============================================================

-- [2026-07-16] PO keluar: jatuh tempo + status bayar
alter table public.purchase_orders add column if not exists jatuh_tempo  date;
alter table public.purchase_orders add column if not exists bayar_status text default 'belum';
