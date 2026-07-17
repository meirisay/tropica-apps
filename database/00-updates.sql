-- ============================================================
-- Tropica Farm — FILE GABUNGAN semua update database
-- Jalankan file INI sekali saja kapan pun (aman diulang).
-- Setiap ada perubahan DB baru, file ini akan diperbarui —
-- cukup jalankan ulang seluruh isinya.
-- Terakhir diperbarui: 2026-07-16
-- ============================================================

-- ---- (A) Kolom rincian item (jenis teh) ----
alter table public.orders          add column if not exists items jsonb default '[]'::jsonb;
alter table public.purchase_orders add column if not exists items jsonb default '[]'::jsonb;
alter table public.order_docs      add column if not exists items jsonb default '[]'::jsonb;

-- ---- (B) PO keluar: jatuh tempo & status bayar ----
alter table public.purchase_orders add column if not exists jatuh_tempo  date;
alter table public.purchase_orders add column if not exists bayar_status text default 'belum';

-- ---- (C) Role: pastikan 'staff' & 'sales' tersedia ----
alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles add constraint profiles_role_check
  check (role in ('owner','keuangan','staff','sales'));

-- Catatan: pemberian role tiap akun & aturan RLS sudah dijalankan
-- lewat 05-roles-staff.sql. Kalau perlu diulang, jalankan file itu.
