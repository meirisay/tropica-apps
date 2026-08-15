# Hosting — Netlify

Aplikasi di-host di **Netlify** sejak 2026-07-14.

> **Update sejak 2026-08-11: auto-deploy dari Git.** Situs tersambung ke GitHub
> (`meirisay/tropica-apps`) + Netlify CD — **deploy = push ke branch `main`** (lihat
> [DEPLOY.md](DEPLOY.md)). Drag-drop manual sudah tidak dipakai lagi.

- **URL tim (publik):** https://tropicafarm.netlify.app
  (disajikan di root sebagai `index.html`)
  > ⚠️ URL LAMA **https://ornate-eclair-9d0efd.netlify.app sudah MATI (HTTP 404)** per 2026-08-15.
  > Pastikan SEMUA anggota tim memakai `https://tropicafarm.netlify.app`. Kalau ada yang masih
  > menyimpan link lama, mereka tidak akan menerima update apa pun.
- **Dashboard project Netlify:** buka via https://app.netlify.com → project **tropicafarm**.

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
