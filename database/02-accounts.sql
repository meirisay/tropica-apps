-- ============================================================
-- Tropica Farm — LANGKAH 2: beri role ke tiap akun
--
-- URUTAN:
--   1) Buat dulu akunnya di Supabase -> Authentication -> Users
--      (email + password + Auto Confirm User).
--   2) Sesuaikan daftar email di bawah dengan akun yang Anda buat.
--   3) Jalankan file ini di SQL Editor.
--
-- Aman dijalankan berulang: kalau role berubah, tinggal edit lalu Run lagi.
-- ============================================================

-- ------------------------------------------------------------
-- Beri role berdasarkan email. GANTI email di bawah bila perlu.
-- Pilihan role: 'owner', 'keuangan', 'admin', 'sales'
-- ------------------------------------------------------------
insert into public.profiles (id, nama, email, role)
select u.id, u.email, u.email, v.role
from auth.users u
join (values
  ('owner@tropicafarm.com',   'owner'),
  ('finance@tropicafarm.com', 'keuangan'),
  ('admin@tropicafarm.com',   'admin'),
  ('sales@tropicafarm.com',   'sales')
) as v(email, role) on lower(v.email) = lower(u.email)
on conflict (id) do update
  set role = excluded.role,
      email = excluded.email;

-- Lihat hasilnya:
select email, role from public.profiles order by role;

-- ------------------------------------------------------------
-- (OPSIONAL) Auto-buat baris profiles untuk akun baru di masa depan.
-- Akun baru otomatis dapat role 'sales'; ubah rolenya lewat SQL di atas.
-- ------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles (id, nama, email, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'nama', new.email), new.email, 'sales')
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
