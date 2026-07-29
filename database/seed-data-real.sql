-- ============================================================
-- SEED DATA ASLI — Tropica Farm (dari Excel "Laporan keuangan Wedrink & GAGA")
-- Jalankan di Supabase -> SQL Editor -> Run. AMAN DIULANG (penjaga anti-dobel).
-- Dibangun bertahap per bulan / per modul. Jalankan sekali di akhir.
--
-- Prasyarat: UPDATE-SQL-TERBARU.sql sudah dijalankan (tabel keuangan ada).
-- ============================================================


-- ============================================================
-- [MODAL] April 2026
--   Owner (pemilik) 30jt + Mba Sari (investor tetap 10%) 25jt
--   DP Buyer 43,5jt TIDAK di sini (pembayaran buyer -> Order/Piutang).
--   Investasi Usaha -> modul Aset (bagian terpisah di bawah).
-- ============================================================

-- Investor (dibuat hanya jika belum ada)
insert into public.investors (nama, tipe, persen, catatan)
select 'Owner', 'pemilik', null, 'Pemilik usaha (Meirisa)'
where not exists (select 1 from public.investors where nama = 'Owner');

insert into public.investors (nama, tipe, persen, catatan)
select 'Mba Sari', 'tetap', 10, 'Investor tetap 10% laba (PO-1 Wedrink khusus flat Rp2.500.000)'
where not exists (select 1 from public.investors where nama = 'Mba Sari');

-- Setoran modal April
insert into public.modal_setoran (investor_id, nama, tanggal, jumlah, catatan)
select i.id, 'Owner', date '2026-04-01', 30000000, 'Modal pribadi — April'
from public.investors i
where i.nama = 'Owner'
  and not exists (select 1 from public.modal_setoran m
    where m.nama = 'Owner' and m.tanggal = date '2026-04-01' and m.jumlah = 30000000);

insert into public.modal_setoran (investor_id, nama, tanggal, jumlah, catatan)
select i.id, 'Mba Sari', date '2026-04-01', 25000000, 'Modal investor — April'
from public.investors i
where i.nama = 'Mba Sari'
  and not exists (select 1 from public.modal_setoran m
    where m.nama = 'Mba Sari' and m.tanggal = date '2026-04-01' and m.jumlah = 25000000);


-- ============================================================
-- [ASET TETAP] Investasi Usaha (dari sheet Modal) — perolehan April 2026
--   Daftar + total 40.355.000, tanpa penyusutan.
-- ============================================================
insert into public.aset_tetap (nama, tanggal, nilai, catatan)
select v.nama, date '2026-04-01', v.nilai, v.catatan
from (values
  ('Bangunan',              30000000::numeric, ''),
  ('Mesin sealer otomatis',  2803000::numeric, '1 pcs'),
  ('Rak',                     974000::numeric, '2 pcs @487.000'),
  ('Meja',                   1528000::numeric, '2 pcs @764.000'),
  ('ATK',                     200000::numeric, '1 set'),
  ('Kursi',                   800000::numeric, '4 pcs @200.000'),
  ('Sertifikat Halal',       2000000::numeric, ''),
  ('Kalkulator',              550000::numeric, ''),
  ('Transport',              1500000::numeric, '')
) as v(nama, nilai, catatan)
where not exists (
  select 1 from public.aset_tetap a where a.nama = v.nama and a.nilai = v.nilai);


-- ============================================================
-- [ORDER + KEUANGAN] April 2026 — Wedrink (PO-WD-0426), LUNAS
--   1 order: Black Tea OP A 500 Kg.
--   Nilai jual 87.000.000 (termasuk PPN 11% + ongkir; dibulatkan dari 87.000.025)
--   Dibayar: DP 43,5jt + Pelunasan 43,5jt = lunas.
--   HPP (bahan baku) 55.801.200 | Biaya operasional 7.175.000 (pengiriman+gaji)
--   Bagi hasil Mba Sari 2.500.000 (khusus PO-1, flat).
--   Sudah dirapikan: modal & aset & pajak/PPN TIDAK dicatat ulang di sini.
-- ============================================================

-- Buyer
insert into public.buyers (nama)
select 'Wedrink' where not exists (select 1 from public.buyers where nama='Wedrink');

-- Order (no_order unik -> on conflict do nothing)
insert into public.orders (no_order, buyer_id, status, nilai_jual, tanggal_order, po_masuk_no, items, catatan)
select 'PO-WD-0426', b.id, 'lunas', 87000000, date '2026-04-16', 'PO-WD-0426',
  '[{"nama":"Black Tea OP A","qty":500,"satuan":"Kg","harga":154955}]'::jsonb,
  'April 2026 — Wedrink. Nilai jual termasuk PPN 11% + ongkir 1jt (asli 87.000.025).'
from public.buyers b where b.nama='Wedrink'
on conflict (no_order) do nothing;

-- Pembayaran buyer (DP + Pelunasan) -> trigger isi total_bayar_buyer
insert into public.transactions (tanggal, arah, jenis, jumlah, order_id, kategori, catatan)
select date '2026-04-16', 'masuk', 'dp', 43500000, o.id, 'DP buyer', 'DP Wedrink 50%'
from public.orders o where o.no_order='PO-WD-0426'
  and not exists (select 1 from public.transactions t where t.order_id=o.id and t.jenis='dp' and t.jumlah=43500000);

insert into public.transactions (tanggal, arah, jenis, jumlah, order_id, kategori, catatan)
select date '2026-04-28', 'masuk', 'pelunasan', 43500000, o.id, 'Pelunasan buyer', 'Pelunasan Wedrink'
from public.orders o where o.no_order='PO-WD-0426'
  and not exists (select 1 from public.transactions t where t.order_id=o.id and t.jenis='pelunasan' and t.jumlah=43500000);

-- Supplier bahan baku
insert into public.suppliers (nama)
select 'Supplier Teh' where not exists (select 1 from public.suppliers where nama='Supplier Teh');

-- Tagihan HPP (bahan baku pemenuhan PO) + pembayarannya
insert into public.supplier_bills (no_tagihan, order_id, supplier_id, nilai, tanggal_terima, jenis, status)
select 'HPP bahan baku April', o.id, s.id, 55801200, date '2026-04-27', 'pemenuhan_po', 'lunas'
from public.orders o, public.suppliers s
where o.no_order='PO-WD-0426' and s.nama='Supplier Teh'
  and not exists (select 1 from public.supplier_bills b where b.order_id=o.id and b.jenis='pemenuhan_po' and b.nilai=55801200);

insert into public.bill_payments (bill_id, tanggal, jumlah)
select b.id, date '2026-04-27', 55801200
from public.supplier_bills b join public.orders o on o.id=b.order_id
where o.no_order='PO-WD-0426' and b.nilai=55801200
  and not exists (select 1 from public.bill_payments p where p.bill_id=b.id and p.jumlah=55801200);

-- Kas keluar bayar supplier (untuk Arus Kas)
insert into public.transactions (tanggal, arah, jenis, jumlah, order_id, kategori, catatan)
select date '2026-04-27', 'keluar', 'bayar_hutang', 55801200, o.id, 'Bayar supplier', 'Bahan baku teh (HPP) April'
from public.orders o where o.no_order='PO-WD-0426'
  and not exists (select 1 from public.transactions t where t.order_id=o.id and t.jenis='bayar_hutang' and t.jumlah=55801200);

-- Biaya usaha operasional (pengiriman + gaji)
insert into public.transactions (tanggal, arah, jenis, jumlah, order_id, kategori, catatan)
select date '2026-04-28', 'keluar', 'biaya_usaha', 1300000, o.id, 'Pengiriman', 'Pengiriman supplier -> gudang'
from public.orders o where o.no_order='PO-WD-0426'
  and not exists (select 1 from public.transactions t where t.order_id=o.id and t.jenis='biaya_usaha' and t.jumlah=1300000 and t.kategori='Pengiriman');

insert into public.transactions (tanggal, arah, jenis, jumlah, order_id, kategori, catatan)
select date '2026-04-28', 'keluar', 'biaya_usaha', 1100000, o.id, 'Pengiriman', 'Pengiriman gudang -> buyer'
from public.orders o where o.no_order='PO-WD-0426'
  and not exists (select 1 from public.transactions t where t.order_id=o.id and t.jenis='biaya_usaha' and t.jumlah=1100000 and t.kategori='Pengiriman');

insert into public.transactions (tanggal, arah, jenis, jumlah, kategori, catatan)
select date '2026-04-30', 'keluar', 'biaya_usaha', 4775000, 'Gaji', 'Gaji karyawan April'
where not exists (select 1 from public.transactions t where t.jenis='biaya_usaha' and t.jumlah=4775000 and t.kategori='Gaji' and t.tanggal=date '2026-04-30');

-- Bagi hasil Mba Sari (khusus PO-1 Wedrink, flat)
insert into public.bagi_hasil (investor_id, order_id, order_no, dasar, tanggal, jumlah, catatan)
select i.id, o.id, 'PO-WD-0426', 'Khusus PO-1 Wedrink (flat)', date '2026-04-30', 2500000, 'Bagi hasil April'
from public.investors i, public.orders o
where i.nama='Mba Sari' and o.no_order='PO-WD-0426'
  and not exists (select 1 from public.bagi_hasil h where h.order_no='PO-WD-0426' and h.jumlah=2500000 and h.investor_id=i.id);


-- ============================================================
-- [FIX APRIL] Ongkir + PO Keluar + Pembelian rinci (jalankan setelah blok April)
-- ============================================================

-- #2 Ongkir: item order + nilai jual jadi 87.000.025 (cocok DPP+PPN+ongkir)
update public.orders
set nilai_jual = 87000025,
    items = '[{"nama":"Black Tea OP A","qty":500,"satuan":"Kg","harga":154955},{"nama":"Ongkir","satuan":"ongkir","qty":1,"harga":1000000}]'::jsonb
where no_order = 'PO-WD-0426';

-- Pelunasan disesuaikan agar lunas tepat (43.500.000 + 43.500.025 = 87.000.025)
update public.transactions
set jumlah = 43500025
where jenis = 'pelunasan' and jumlah = 43500000
  and order_id = (select id from public.orders where no_order='PO-WD-0426');

-- #3 PO Keluar ke supplier (Chakra & Naufal)
insert into public.suppliers (nama) select 'Chakra' where not exists (select 1 from public.suppliers where nama='Chakra');
insert into public.suppliers (nama) select 'Naufal' where not exists (select 1 from public.suppliers where nama='Naufal');

insert into public.purchase_orders (no_po, order_id, supplier_id, tanggal, total, status, items)
select 'PO-CHK-0426', o.id, s.id, date '2026-04-16', 19980000, 'barang_datang',
  '[{"nama":"Teh Cakra","qty":200,"satuan":"Kg","harga":99900}]'::jsonb
from public.orders o, public.suppliers s
where o.no_order='PO-WD-0426' and s.nama='Chakra'
on conflict (no_po) do nothing;

insert into public.purchase_orders (no_po, order_id, supplier_id, tanggal, total, status, items)
select 'PO-NFL-0426', o.id, s.id, date '2026-04-16', 28060000, 'barang_datang',
  '[{"nama":"Black Tea OP A (Naufal)","qty":305,"satuan":"Kg","harga":92000}]'::jsonb
from public.orders o, public.suppliers s
where o.no_order='PO-WD-0426' and s.nama='Naufal'
on conflict (no_po) do nothing;

-- #7 Pembelian: rinci isi tagihan HPP (dari sheet Biaya usaha April)
update public.supplier_bills
set items = '[{"nama":"Teh Cakra","qty":200,"satuan":"Kg","harga":99900},{"nama":"Naufal (Black Tea OP A)","qty":305,"satuan":"Kg","harga":92000},{"nama":"Kemasan","qty":5000,"satuan":"Pcs","harga":725},{"nama":"Dus","qty":42,"satuan":"Pcs","harga":38850},{"nama":"Plastik","qty":6,"satuan":"Kg","harga":55000},{"nama":"Label","qty":275,"satuan":"Lbr","harga":7300}]'::jsonb
where no_tagihan = 'HPP bahan baku April'
  and order_id = (select id from public.orders where no_order='PO-WD-0426');

-- (bagian berikutnya menyusul: Hutang, lalu Mei dst.)
