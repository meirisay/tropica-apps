-- ============================================================
-- Tropica Farm — Ganti role 'admin' -> 'staff', hapus 'admin_sales'
-- Akun: nelimulyani645@gmail.com = staff, ichayusniar@gmail.com = sales
--
-- Syarat: akun nelimulyani645@gmail.com sudah ada di
--   Authentication -> Users. Aman dijalankan berulang.
-- ============================================================

-- 1) Longgarkan dulu batasan role
alter table public.profiles drop constraint if exists profiles_role_check;

-- 2) Atur ulang role tiap akun
insert into public.profiles (id, nama, email, role)
select u.id, u.email, u.email, v.role
from auth.users u
join (values
  ('meirisa.yusniar@tropicafarm.com', 'owner'),
  ('finance@tropicafarm.com',         'keuangan'),
  ('nelimulyani645@gmail.com',        'staff'),
  ('ichayusniar@gmail.com',           'sales')
) as v(email, role) on lower(v.email) = lower(u.email)
on conflict (id) do update set role = excluded.role, email = excluded.email;

-- 3) Ubah sisa role lama (jika ada) ke 'staff' biar tidak menyalahi batasan
update public.profiles set role='staff' where role in ('admin','admin_sales');

-- 4) Pasang batasan role baru
alter table public.profiles add constraint profiles_role_check
  check (role in ('owner','keuangan','staff','sales'));

-- 5) Perbarui aturan akses (ganti admin/admin_sales -> staff)
-- buyers & suppliers: semua role operasional boleh catat
drop policy if exists p_buyers_write on public.buyers;
create policy p_buyers_write on public.buyers for all to authenticated
  using (public.my_role() in ('owner','keuangan','staff','sales'))
  with check (public.my_role() in ('owner','keuangan','staff','sales'));

drop policy if exists p_suppliers_write on public.suppliers;
create policy p_suppliers_write on public.suppliers for all to authenticated
  using (public.my_role() in ('owner','keuangan','staff','sales'))
  with check (public.my_role() in ('owner','keuangan','staff','sales'));

-- orders / order_docs / purchase_orders: staff TIDAK boleh (hanya owner/keuangan/sales)
drop policy if exists p_orders_write on public.orders;
create policy p_orders_write on public.orders for all to authenticated
  using (public.my_role() in ('owner','keuangan','sales'))
  with check (public.my_role() in ('owner','keuangan','sales'));

drop policy if exists p_docs_read on public.order_docs;
create policy p_docs_read on public.order_docs for select to authenticated
  using (public.my_role() in ('owner','keuangan','sales'));
drop policy if exists p_docs_write on public.order_docs;
create policy p_docs_write on public.order_docs for all to authenticated
  using (public.my_role() in ('owner','keuangan','sales'))
  with check (public.my_role() in ('owner','keuangan','sales'));

drop policy if exists p_po_read on public.purchase_orders;
create policy p_po_read on public.purchase_orders for select to authenticated
  using (public.my_role() in ('owner','keuangan','sales'));
drop policy if exists p_po_write on public.purchase_orders;
create policy p_po_write on public.purchase_orders for all to authenticated
  using (public.my_role() in ('owner','keuangan','sales'))
  with check (public.my_role() in ('owner','keuangan','sales'));

-- supplier_bills (tagihan): staff boleh catat
drop policy if exists p_bills_read on public.supplier_bills;
create policy p_bills_read on public.supplier_bills for select to authenticated
  using (public.my_role() in ('owner','keuangan','staff'));
drop policy if exists p_bills_write on public.supplier_bills;
create policy p_bills_write on public.supplier_bills for all to authenticated
  using (public.my_role() in ('owner','keuangan','staff'))
  with check (public.my_role() in ('owner','keuangan','staff'));

-- shipments + isinya: staff & sales boleh catat
drop policy if exists p_ship_write on public.shipments;
create policy p_ship_write on public.shipments for all to authenticated
  using (public.my_role() in ('owner','keuangan','staff','sales'))
  with check (public.my_role() in ('owner','keuangan','staff','sales'));

drop policy if exists p_shipit_write on public.shipment_items;
create policy p_shipit_write on public.shipment_items for all to authenticated
  using (public.my_role() in ('owner','keuangan','staff','sales'))
  with check (public.my_role() in ('owner','keuangan','staff','sales'));

drop policy if exists p_shipdoc_write on public.shipment_docs;
create policy p_shipdoc_write on public.shipment_docs for all to authenticated
  using (public.my_role() in ('owner','keuangan','staff','sales'))
  with check (public.my_role() in ('owner','keuangan','staff','sales'));

-- (bill_payments & transactions tetap owner/keuangan saja)

-- 6) Lihat hasil
select email, role from public.profiles order by role;
