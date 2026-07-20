-- Tropica Farm — Pisahkan Nilai Sample dari Nilai Jual (PO)
-- Sebelumnya order hanya punya 1 kolom nilai (nilai_jual), sehingga saat
-- nilai PO diisi, nilai sample ketimpa/hilang. Kolom ini menyimpan nilai
-- penawaran tahap sample secara terpisah agar keduanya bertahan di kartu order.
--
-- Jalankan di Supabase → SQL Editor SEBELUM memakai build terbaru.

alter table public.orders
  add column if not exists nilai_sample numeric(16,2) default 0;

comment on column public.orders.nilai_sample is
  'Nilai penawaran tahap sample; terpisah dari nilai_jual (nilai PO/deal).';
