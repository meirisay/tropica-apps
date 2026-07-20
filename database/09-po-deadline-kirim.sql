-- Tropica Farm — Deadline pengiriman pada PO keluar
-- PO punya dua "tenggat" berbeda:
--   • jatuh_tempo   = jatuh tempo PEMBAYARAN (internal, kapan kita bayar supplier)
--   • deadline_kirim = batas SUPPLIER mengirim barang (dicetak di PO yang diterbitkan ke supplier)
-- Kolom ini menyimpan deadline pengiriman itu.
--
-- Jalankan di Supabase → SQL Editor.

alter table public.purchase_orders
  add column if not exists deadline_kirim date;

comment on column public.purchase_orders.deadline_kirim is
  'Batas supplier mengirim barang (tampil di PO cetak ke supplier). Beda dari jatuh_tempo (pembayaran).';
