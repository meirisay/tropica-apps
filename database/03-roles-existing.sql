-- ============================================================
-- Tropica Farm — LANGKAH 2 (versi akun yang sudah ada)
-- Menambah role gabungan 'admin_sales' + memberi role ke 3 akun.
--
-- Jalankan file INI (tidak perlu 02-accounts.sql).
-- Syarat: ke-3 akun sudah ada di Authentication -> Users.
-- Aman dijalankan berulang.
-- ============================================================

-- ------------------------------------------------------------
-- 1) Tambah pilihan role gabungan 'admin_sales'
--    (= akses Sales + Admin, tetap tanpa keuangan)
-- ------------------------------------------------------------
alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles add constraint profiles_role_check
  check (role in ('owner','keuangan','admin','sales','admin_sales'));

-- ------------------------------------------------------------
-- 2) Perbarui aturan akses supaya 'admin_sales' mendapat
--    gabungan hak Sales + Admin.
-- ------------------------------------------------------------

-- Master: buyers & suppliers (boleh dicatat semua role operasional)
drop policy if exists p_buyers_write on public.buyers;
create policy p_buyers_write on public.buyers for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','sales','admin_sales'))
  with check (public.my_role() in ('owner','keuangan','admin','sales','admin_sales'));

drop policy if exists p_suppliers_write on public.suppliers;
create policy p_suppliers_write on public.suppliers for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','sales','admin_sales'))
  with check (public.my_role() in ('owner','keuangan','admin','sales','admin_sales'));

-- orders (tulis): + admin_sales
drop policy if exists p_orders_write on public.orders;
create policy p_orders_write on public.orders for all to authenticated
  using (public.my_role() in ('owner','keuangan','sales','admin_sales'))
  with check (public.my_role() in ('owner','keuangan','sales','admin_sales'));

-- order_docs (PI & Invoice): + admin_sales
drop policy if exists p_docs_read on public.order_docs;
create policy p_docs_read on public.order_docs for select to authenticated
  using (public.my_role() in ('owner','keuangan','sales','admin_sales'));
drop policy if exists p_docs_write on public.order_docs;
create policy p_docs_write on public.order_docs for all to authenticated
  using (public.my_role() in ('owner','keuangan','sales','admin_sales'))
  with check (public.my_role() in ('owner','keuangan','sales','admin_sales'));

-- purchase_orders (PO keluar): + admin_sales
drop policy if exists p_po_read on public.purchase_orders;
create policy p_po_read on public.purchase_orders for select to authenticated
  using (public.my_role() in ('owner','keuangan','sales','admin_sales'));
drop policy if exists p_po_write on public.purchase_orders;
create policy p_po_write on public.purchase_orders for all to authenticated
  using (public.my_role() in ('owner','keuangan','sales','admin_sales'))
  with check (public.my_role() in ('owner','keuangan','sales','admin_sales'));

-- supplier_bills (tagihan): + admin_sales (karena mencakup Admin)
drop policy if exists p_bills_read on public.supplier_bills;
create policy p_bills_read on public.supplier_bills for select to authenticated
  using (public.my_role() in ('owner','keuangan','admin','admin_sales'));
drop policy if exists p_bills_write on public.supplier_bills;
create policy p_bills_write on public.supplier_bills for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','admin_sales'))
  with check (public.my_role() in ('owner','keuangan','admin','admin_sales'));

-- shipments + isinya (tulis): + admin_sales
drop policy if exists p_ship_write on public.shipments;
create policy p_ship_write on public.shipments for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','sales','admin_sales'))
  with check (public.my_role() in ('owner','keuangan','admin','sales','admin_sales'));

drop policy if exists p_shipit_write on public.shipment_items;
create policy p_shipit_write on public.shipment_items for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','sales','admin_sales'))
  with check (public.my_role() in ('owner','keuangan','admin','sales','admin_sales'));

drop policy if exists p_shipdoc_write on public.shipment_docs;
create policy p_shipdoc_write on public.shipment_docs for all to authenticated
  using (public.my_role() in ('owner','keuangan','admin','sales','admin_sales'))
  with check (public.my_role() in ('owner','keuangan','admin','sales','admin_sales'));

-- Catatan: bill_payments & transactions TETAP owner+keuangan saja,
-- jadi 'admin_sales' otomatis tidak bisa membuka Pembayaran & Keuangan.

-- ------------------------------------------------------------
-- 3) Beri role ke akun yang sudah ada
-- ------------------------------------------------------------
insert into public.profiles (id, nama, email, role)
select u.id, u.email, u.email, v.role
from auth.users u
join (values
  ('meirisa.yusniar@tropicafarm.com', 'owner'),
  ('finance@tropicafarm.com',         'keuangan'),
  ('ichayusniar@gmail.com',           'admin_sales')
) as v(email, role) on lower(v.email) = lower(u.email)
on conflict (id) do update
  set role = excluded.role,
      email = excluded.email;

-- Lihat hasilnya (harus muncul 3 baris):
select email, role from public.profiles order by role;
