# Hosting — Netlify

Aplikasi di-host di **Netlify** sejak 2026-07-14.

- **URL tim (publik):** https://ornate-eclair-9d0efd.netlify.app
  (disajikan di root sebagai `index.html`)
- **Dashboard project Netlify:**
  https://app.netlify.com/projects/ornate-eclair-9d0efd/overview

Backend tetap di Supabase (lihat [DATABASE.md](DATABASE.md)), jadi data tetap
tersimpan di cloud dan dibagi ke seluruh tim, terlepas dari hosting.

> anon key di dalam file **aman** untuk di-host publik.

## Hal-hal yang perlu diwaspadai

**1. Jangan pakai app.netlify.com/drop untuk update.**
Halaman itu membuat **situs BARU** dengan URL berbeda. Untuk update situs yang sudah
ada, gunakan tab **Deploys** di project (lihat [DEPLOY.md](DEPLOY.md)).

**2. Selalu konfirmasi hasil deploy.**
Pernah terjadi (2026-07-14) deploy pertama ternyata menaikkan salinan **lama**
(Supabase jalan, tapi tanpa "FINAL PAYMENT", logo daun lama, tanpa badge v2).
Setelah deploy, cek URL publik apakah sudah memuat penanda versi terbaru
(mis. `Desain final v2` / `FINAL PAYMENT`) sebelum menganggapnya sudah terbaru.

**3. Cache saat buka via `file://`.**
Membuka file HTML langsung (`file://`) sering menampilkan versi lama karena cache.
Solusi: hard refresh (Cmd+Shift+R), jendela Incognito, atau buka dengan nama file
baru. Badge **"Desain final v2"** ada untuk membantu mendeteksi hal ini. Dengan
hosting, kebingungan cache file lokal ini hilang.
