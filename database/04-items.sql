-- ============================================================
-- Tropica Farm — Tambahan: rincian item (jenis teh) per dokumen
-- Menyimpan daftar item sebagai JSON: [{nama, qty, harga}, ...]
-- Aman dijalankan berulang.
-- ============================================================
alter table public.orders          add column if not exists items jsonb default '[]'::jsonb;
alter table public.purchase_orders add column if not exists items jsonb default '[]'::jsonb;
alter table public.order_docs      add column if not exists items jsonb default '[]'::jsonb;
