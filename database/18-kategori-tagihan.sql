-- 18 · KATEGORI PEMBELIAN
-- Jenis pembelian: Pemenuhan PO buyer (kategori Raw material / OPS pemenuhan PO), Operasional kantor,
-- Operasional ChaCha, Stok / persediaan. Pilihan itu disimpan di kolom `kategori` supaya saat dibayar,
-- transaksi Arus Kas langsung berkategori benar dan Biaya usaha menaruhnya di bagian yang tepat.
--
-- Cara jalankan: Supabase → SQL Editor → tempel & Run. Aman diulang (idempotent). Data lama tidak diubah,
-- kecuali isian awal kategori di bawah (hanya mengisi yang masih kosong).

alter table public.supplier_bills add column if not exists kategori text;

-- Isi awal dari aturan lama: tagihan operasional dari supplier ChaCha → Operasional ChaCha,
-- tagihan operasional lain → Pembelian operasional. Pemenuhan PO untuk order buyer ChaCha → Pemenuhan kebutuhan ChaCha.
update public.supplier_bills b set kategori = 'Operasional ChaCha'
  from public.suppliers s
 where s.id = b.supplier_id and b.jenis = 'operasional' and b.kategori is null and s.nama ~* 'cha\s*cha';
update public.supplier_bills set kategori = 'Pembelian operasional'
 where jenis = 'operasional' and kategori is null;
update public.supplier_bills b set kategori = 'Pemenuhan kebutuhan ChaCha'
  from public.orders o join public.buyers y on y.id = o.buyer_id
 where o.id = b.order_id and b.jenis = 'pemenuhan_po' and b.kategori is null and y.nama ~* 'cha\s*cha';

-- Selesai.
