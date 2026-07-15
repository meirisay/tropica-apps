# Status & Pekerjaan yang Belum Selesai

**Per 2026-07-15.**

Tim sedang **aktif memakai** deployment Netlify:
https://ornate-eclair-9d0efd.netlify.app
User memilih tetap menjalankan deploy sebelumnya untuk sekarang; pengembangan lanjut
akan menyusul.

## ⚠️ Penting: situs live masih build LAMA

Situs live saat ini menyajikan **build lama** — Supabase berfungsi, tetapi belum
memuat desain invoice final (tanpa "FINAL PAYMENT", masih logo daun lama, tanpa badge
v2). Build terbaru sudah ada di disk dan siap deploy sebagai `~/Downloads/index.html`.
Langkah update ada di [DEPLOY.md](DEPLOY.md).

## Open items untuk ronde berikutnya

1. **Re-deploy** `~/Downloads/index.html` agar situs live memakai desain invoice final
   (saat user siap).
2. **Putuskan format penomoran dokumen:** `/gtf` (sekarang) vs `-GTF` + bulan 2 digit
   (sesuai contoh PDF). Lihat [DESAIN-INVOICE.md](DESAIN-INVOICE.md).
3. **Buat akun login Supabase** untuk tiap anggota tim
   (dashboard → Authentication → Users). Lihat [DATABASE.md](DATABASE.md).
4. **Hardening (opsional, nanti):** concurrency edit multi-user + tombol
   backup/export data.
