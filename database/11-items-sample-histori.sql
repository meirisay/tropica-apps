-- Tropica Farm — Histori Item Order dari tahap sample
-- Saat order sample dikonversi jadi PO (lewat "Order baru → Lanjutan dari sample"),
-- item PO bisa berbeda dari item sample. Kolom ini menyimpan SNAPSHOT item sample
-- agar histori item sample tetap terlihat di kartu order.
--
-- Jalankan di Supabase → SQL Editor.

alter table public.orders
  add column if not exists items_sample jsonb default '[]'::jsonb;

comment on column public.orders.items_sample is
  'Snapshot item saat tahap sample (histori), diisi ketika order sample dilanjutkan jadi PO.';
