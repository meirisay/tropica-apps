# Cara Update / Deploy Situs

Situs live disajikan dari `index.html` di Netlify. Untuk menaikkan versi baru:

## Langkah

1. **Siapkan file terbaru sebagai `index.html`.**
   Salin/rename versi HTML terbaru menjadi `index.html`.
   `~/Downloads/index.html` sudah disiapkan sebagai salinan siap-deploy.

2. **Buka dashboard project Netlify** (BUKAN app.netlify.com/drop):
   https://app.netlify.com/projects/ornate-eclair-9d0efd/overview

3. **Masuk ke tab `Deploys`.**

4. **Seret (drag-and-drop)** file `index.html` ke area unggah manual di tab Deploys.

   > ⚠️ Jangan pakai **app.netlify.com/drop** — itu membuat situs baru dengan URL berbeda.

5. **Konfirmasi hasilnya.** Buka URL publik dan pastikan versi terbaru muncul —
   cari penanda seperti `Desain final v2` atau `FINAL PAYMENT`. Jika masih versi lama,
   berarti yang ter-deploy salah / masih ter-cache.

## Cek cepat lewat terminal (opsional)

```bash
# Harus menampilkan "Desain final v2" jika build final sudah live
curl -s https://ornate-eclair-9d0efd.netlify.app | grep -o "Desain final v2"
curl -s https://ornate-eclair-9d0efd.netlify.app | grep -o "FINAL PAYMENT"
```

## Status per 2026-07-15

Situs live **masih build lama** — dua penanda di atas belum muncul di URL publik,
padahal `~/Downloads/index.html` lokal sudah versi final. Artinya: **re-deploy masih
perlu dilakukan** untuk memutakhirkan desain invoice di situs live.
Lihat [STATUS.md](STATUS.md).
