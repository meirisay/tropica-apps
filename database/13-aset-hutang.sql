-- [13] Modul Keuangan: Aset tetap + Pinjaman (hutang)
-- Data keuangan sensitif => hanya owner & keuangan yang boleh baca/tulis.

create table if not exists public.aset_tetap (
  id         uuid primary key default gen_random_uuid(),
  nama       text not null,
  tanggal    date,                       -- tanggal perolehan
  nilai      numeric(16,2) default 0,
  catatan    text,
  created_at timestamptz default now()
);

create table if not exists public.pinjaman (
  id         uuid primary key default gen_random_uuid(),
  pemberi    text not null,              -- pemberi pinjaman, mis. Tonto / Fauzan
  tanggal    date,
  jumlah     numeric(16,2) default 0,
  status     text default 'belum',       -- 'belum' | 'lunas'
  catatan    text,
  created_at timestamptz default now()
);

alter table public.aset_tetap enable row level security;
alter table public.pinjaman   enable row level security;

drop policy if exists p_aset_tetap_read  on public.aset_tetap;
drop policy if exists p_aset_tetap_write on public.aset_tetap;
drop policy if exists p_pinjaman_read    on public.pinjaman;
drop policy if exists p_pinjaman_write   on public.pinjaman;

create policy p_aset_tetap_read on public.aset_tetap for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
create policy p_aset_tetap_write on public.aset_tetap for all to authenticated
  using (public.my_role() in ('owner','keuangan'))
  with check (public.my_role() in ('owner','keuangan'));

create policy p_pinjaman_read on public.pinjaman for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
create policy p_pinjaman_write on public.pinjaman for all to authenticated
  using (public.my_role() in ('owner','keuangan'))
  with check (public.my_role() in ('owner','keuangan'));
