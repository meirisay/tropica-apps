-- 19 · STOK OPNAME
-- Hitung fisik stok gudang dibandingkan stok sistem (pembelian "Stok / persediaan" − qty dialokasikan
-- ke order ± opname sebelumnya). Selisihnya jadi PENYESUAIAN:
--   • stok kurang → Beban "Selisih stok" + aset persediaan berkurang
--   • stok lebih  → Pendapatan lain + aset persediaan bertambah
-- Tidak menyentuh kas. Nilai pakai harga beli rata-rata tanpa PPN.
--
-- Cara jalankan: Supabase → SQL Editor → tempel & Run. Aman diulang (idempotent).

create table if not exists public.stock_opname (
  id            uuid primary key default gen_random_uuid(),
  tanggal       date not null default current_date,
  catatan       text,
  nilai_sistem  numeric(16,2) not null default 0,   -- nilai stok sistem saat dihitung
  nilai_fisik   numeric(16,2) not null default 0,   -- nilai stok hasil hitung fisik
  nilai_kurang  numeric(16,2) not null default 0,   -- total selisih kurang (positif) → beban
  nilai_lebih   numeric(16,2) not null default 0,   -- total selisih lebih (positif) → pendapatan lain
  created_by    uuid default auth.uid(),
  created_at    timestamptz default now()
);

create table if not exists public.stock_opname_items (
  id            uuid primary key default gen_random_uuid(),
  opname_id     uuid not null references public.stock_opname(id) on delete cascade,
  item_key      text not null,                       -- nama dinormalisasi (huruf kecil, spasi dirapikan)
  nama          text,
  satuan        text,
  qty_sistem    numeric(14,3) not null default 0,
  qty_fisik     numeric(14,3) not null default 0,
  selisih       numeric(14,3) not null default 0,    -- fisik − sistem
  harga         numeric(16,2) not null default 0,    -- harga/unit rata-rata (tanpa PPN)
  nilai_selisih numeric(16,2) not null default 0     -- selisih × harga
);
create index if not exists stock_opname_items_opname_idx on public.stock_opname_items(opname_id);
create index if not exists stock_opname_items_key_idx on public.stock_opname_items(item_key);

alter table public.stock_opname enable row level security;
alter table public.stock_opname_items enable row level security;

-- Baca & isi: owner, keuangan, staff (admin). Hapus: hanya owner & keuangan.
drop policy if exists p_opname_read on public.stock_opname;
create policy p_opname_read on public.stock_opname for select to authenticated
  using (public.my_role() in ('owner','keuangan','staff'));
drop policy if exists p_opname_insert on public.stock_opname;
create policy p_opname_insert on public.stock_opname for insert to authenticated
  with check (public.my_role() in ('owner','keuangan','staff'));
drop policy if exists p_opname_delete on public.stock_opname;
create policy p_opname_delete on public.stock_opname for delete to authenticated
  using (public.my_role() in ('owner','keuangan'));

drop policy if exists p_opname_items_read on public.stock_opname_items;
create policy p_opname_items_read on public.stock_opname_items for select to authenticated
  using (public.my_role() in ('owner','keuangan','staff'));
drop policy if exists p_opname_items_insert on public.stock_opname_items;
create policy p_opname_items_insert on public.stock_opname_items for insert to authenticated
  with check (public.my_role() in ('owner','keuangan','staff'));
drop policy if exists p_opname_items_delete on public.stock_opname_items;
create policy p_opname_items_delete on public.stock_opname_items for delete to authenticated
  using (public.my_role() in ('owner','keuangan'));

-- Selesai. Buka aplikasi → Keuangan → Stok Opname.
