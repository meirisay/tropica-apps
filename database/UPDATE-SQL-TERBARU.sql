-- ============================================================
-- Tropica Farm — KUMPULAN UPDATE SQL (jalankan SEKALI di Supabase)
-- Supabase -> SQL Editor -> New query -> tempel semua -> Run.
-- Aman diulang (pakai IF NOT EXISTS / CREATE OR REPLACE).
--
-- Tanpa ini, aplikasi akan error saat memuat Order/PO/Pengiriman
-- dan tombol Hapus order tidak berfungsi.
-- ============================================================

-- [2026-07-16] PO keluar: jatuh tempo + status bayar
alter table public.purchase_orders add column if not exists jatuh_tempo  date;
alter table public.purchase_orders add column if not exists bayar_status text default 'belum';

-- [07] Pisah Nilai Sample dari Nilai Jual (PO)
alter table public.orders
  add column if not exists nilai_sample numeric(16,2) default 0;

-- [09] Deadline pengiriman pada PO keluar (batas supplier kirim barang)
alter table public.purchase_orders
  add column if not exists deadline_kirim date;

-- [10] Detail item pengiriman untuk Delivery Order
alter table public.shipment_items
  add column if not exists jumlah     text,
  add column if not exists netto      text,
  add column if not exists keterangan text;

-- [11] Histori item sample saat order sample dilanjutkan jadi PO
alter table public.orders
  add column if not exists items_sample jsonb default '[]'::jsonb;

-- [08] Hapus order beserta SEMUA data terkait (atomik)
create or replace function public.delete_order_cascade(p_order uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if public.my_role() not in ('owner','keuangan','sales') then
    raise exception 'Tidak diizinkan menghapus order';
  end if;

  delete from public.transactions where order_id = p_order;
  delete from public.supplier_bills
    where order_id = p_order
       or po_id in (select id from public.purchase_orders where order_id = p_order);
  delete from public.purchase_orders where order_id = p_order;
  delete from public.shipments where order_id = p_order;
  delete from public.order_docs where order_id = p_order;
  delete from public.orders where id = p_order;
end;
$$;

grant execute on function public.delete_order_cascade(uuid) to authenticated;

-- Selesai. Setelah muncul "Success", buka aplikasi dan uji coba.
