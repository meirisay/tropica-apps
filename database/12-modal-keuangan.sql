-- [12] Modul Keuangan: Modal (setoran) + Investor + Bagi Hasil
-- Data keuangan sensitif => hanya owner & keuangan yang boleh baca/tulis.

create table if not exists public.investors (
  id         uuid primary key default gen_random_uuid(),
  nama       text not null,
  tipe       text default 'sesekali',   -- 'pemilik' | 'tetap' | 'sesekali'
  persen     numeric(6,2),              -- porsi % dari laba (opsional; kosong = per-kasus)
  catatan    text,
  created_at timestamptz default now()
);

create table if not exists public.modal_setoran (
  id          uuid primary key default gen_random_uuid(),
  investor_id uuid references public.investors(id) on delete set null,
  nama        text,                      -- denormalisasi utk tampilan
  tanggal     date,
  jumlah      numeric(16,2) default 0,
  catatan     text,
  created_at  timestamptz default now()
);

create table if not exists public.bagi_hasil (
  id          uuid primary key default gen_random_uuid(),
  investor_id uuid references public.investors(id) on delete set null,
  order_id    uuid references public.orders(id) on delete set null,
  order_no    text,                      -- denormalisasi utk tampilan
  dasar       text,                      -- dasar perhitungan, mis. "10% laba Mei" / "Special PO-1"
  tanggal     date,
  jumlah      numeric(16,2) default 0,
  catatan     text,
  created_at  timestamptz default now()
);

alter table public.investors     enable row level security;
alter table public.modal_setoran enable row level security;
alter table public.bagi_hasil    enable row level security;

drop policy if exists p_investors_read     on public.investors;
drop policy if exists p_investors_write    on public.investors;
drop policy if exists p_modal_setoran_read on public.modal_setoran;
drop policy if exists p_modal_setoran_write on public.modal_setoran;
drop policy if exists p_bagi_hasil_read    on public.bagi_hasil;
drop policy if exists p_bagi_hasil_write   on public.bagi_hasil;

create policy p_investors_read on public.investors for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
create policy p_investors_write on public.investors for all to authenticated
  using (public.my_role() in ('owner','keuangan'))
  with check (public.my_role() in ('owner','keuangan'));

create policy p_modal_setoran_read on public.modal_setoran for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
create policy p_modal_setoran_write on public.modal_setoran for all to authenticated
  using (public.my_role() in ('owner','keuangan'))
  with check (public.my_role() in ('owner','keuangan'));

create policy p_bagi_hasil_read on public.bagi_hasil for select to authenticated
  using (public.my_role() in ('owner','keuangan'));
create policy p_bagi_hasil_write on public.bagi_hasil for all to authenticated
  using (public.my_role() in ('owner','keuangan'))
  with check (public.my_role() in ('owner','keuangan'));
