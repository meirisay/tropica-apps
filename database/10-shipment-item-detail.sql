-- Tropica Farm — Detail item pengiriman untuk Delivery Order (Nota Pengiriman Barang)
-- DO/Surat Jalan menampilkan kolom: Jumlah (mis. "25 karton"), Netto (mis. "10 kg"),
-- Qty total (mis. "250 kg"), dan Keterangan kemasan. Kolom-kolom ini menyimpannya.
--
-- Jalankan di Supabase → SQL Editor.

alter table public.shipment_items
  add column if not exists jumlah     text,   -- jumlah kemasan, mis. "25 karton"
  add column if not exists netto      text,   -- netto per kemasan, mis. "10 kg"
  add column if not exists keterangan text;    -- keterangan kemasan

comment on column public.shipment_items.jumlah is 'Jumlah kemasan (mis. 25 karton) — tampil di Delivery Order.';
comment on column public.shipment_items.netto is 'Netto per kemasan (mis. 10 kg) — tampil di Delivery Order.';
comment on column public.shipment_items.keterangan is 'Keterangan kemasan — tampil di Delivery Order.';
