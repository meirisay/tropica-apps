-- Tropica Farm — Hapus order beserta SEMUA data yang menempel (atomik)
-- Sebelumnya menghapus order gagal karena FK dari purchase_orders / supplier_bills /
-- shipments / transactions (tanpa ON DELETE CASCADE). Fungsi ini menghapus semuanya
-- dalam satu transaksi, urut sesuai ketergantungan FK.
--
-- Jalankan di Supabase → SQL Editor. Dipanggil dari app via sb.rpc('delete_order_cascade').

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

  -- transaksi buyer (DP/pelunasan/dll) untuk order ini
  delete from public.transactions where order_id = p_order;

  -- tagihan supplier: yang terkait order langsung, atau lewat PO order ini
  -- (bill_payments ikut terhapus via ON DELETE CASCADE pada bill_id)
  delete from public.supplier_bills
    where order_id = p_order
       or po_id in (select id from public.purchase_orders where order_id = p_order);

  -- PO keluar order ini
  delete from public.purchase_orders where order_id = p_order;

  -- pengiriman (shipment_items & shipment_docs ikut via ON DELETE CASCADE)
  delete from public.shipments where order_id = p_order;

  -- dokumen PI/Invoice (juga ON DELETE CASCADE, tapi eksplisit biar jelas)
  delete from public.order_docs where order_id = p_order;

  -- terakhir: order-nya
  delete from public.orders where id = p_order;
end;
$$;

grant execute on function public.delete_order_cascade(uuid) to authenticated;
