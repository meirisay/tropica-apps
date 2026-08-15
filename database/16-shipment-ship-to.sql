-- 16 · ALAMAT KIRIM (SHIP TO) PER PENGIRIMAN
-- Sebelumnya: mengetik alamat/kontak di form Pengiriman MENIMPA alamat master buyer.
-- Sekarang: alamat/kontak kiriman disimpan di record pengiriman itu sendiri,
-- sehingga alamat master buyer TIDAK ikut berubah.
--
-- Cara jalankan: Supabase → SQL Editor → tempel & Run. Aman diulang (idempotent).

alter table public.shipments add column if not exists ship_kontak text;
alter table public.shipments add column if not exists ship_alamat text;

-- Isi awal (opsional): salin alamat buyer saat ini ke pengiriman lama yang belum punya,
-- supaya DO lama tetap menampilkan alamat seperti sebelumnya.
update public.shipments s
set ship_alamat = b.alamat, ship_kontak = b.kontak
from public.buyers b
where s.buyer_id = b.id
  and s.ship_alamat is null and s.ship_kontak is null;
