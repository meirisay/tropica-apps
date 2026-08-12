-- 15 · DATA MASTER BUYER & SUPPLIER
-- Tambah kolom untuk data lengkap + BEBERAPA alamat gudang (jsonb array {nama, alamat}).
-- buyers sudah punya: nama, kontak, alamat, npwp. suppliers sudah punya: nama, kontak, rekening.
--
-- Cara jalankan: Supabase → SQL Editor → tempel & Run. Aman diulang (idempotent).

-- Buyers: tambah telepon + daftar gudang (alamat kantor = kolom 'alamat' yang sudah ada)
alter table public.buyers add column if not exists telp   text;
alter table public.buyers add column if not exists gudang jsonb default '[]'::jsonb;

-- Suppliers: tambah alamat kantor, npwp, telepon, daftar gudang
alter table public.suppliers add column if not exists alamat text;
alter table public.suppliers add column if not exists npwp   text;
alter table public.suppliers add column if not exists telp   text;
alter table public.suppliers add column if not exists gudang jsonb default '[]'::jsonb;

-- gudang = array lokasi, contoh:
--   [{"nama":"Gudang Cikarang","alamat":"Jl. Industri Blok C2, Cikarang"},
--    {"nama":"Gudang Bandung","alamat":"Jl. Soekarno-Hatta No. 55, Bandung"}]
