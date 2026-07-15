# Tropica Farm — Laporan Keuangan

Aplikasi buku kas (cashbook) berbasis web untuk **PT GLOBAL TROPICA FARMINDO**
(brand: **Tropica Farm**), bisnis suplai teh di Purwakarta, Jawa Barat.

Aplikasi ini mencatat keuangan per bulan dan per pembeli, dipakai bersama oleh tim kecil.

- **Website tim (live):** https://ornate-eclair-9d0efd.netlify.app
- **Penanggung jawab / signer:** Meirisa Yusniar
- **Kontak:** ichayusniar@gmail.com

---

## Isi Folder

| Item | Isi |
|------|-----|
| **`index.html`** | **Aplikasi itu sendiri** — file kerja utama (build final, identik dengan salinan kanonik di `~/Downloads`). Buka di browser atau deploy apa adanya. |
| `referensi/` | Aset acuan: logo sumber (`Logo Icon.png`) + PDF spesifikasi & contoh PI/Invoice. |
| [STRUKTUR-KODE.md](STRUKTUR-KODE.md) | Bentuk aplikasi, file-file penting, dan penjelasan tiap tab |
| [DATABASE.md](DATABASE.md) | Backend Supabase: koneksi, tabel, login, cara kerja penyimpanan |
| [HOSTING.md](HOSTING.md) | Hosting Netlify: URL, dashboard, dan hal yang perlu diwaspadai |
| [DEPLOY.md](DEPLOY.md) | Cara update situs / deploy versi baru, langkah demi langkah |
| [DESAIN-INVOICE.md](DESAIN-INVOICE.md) | Spesifikasi dokumen PI & Invoice (DP/Final, penomoran, PPN) |
| [STATUS.md](STATUS.md) | Status terkini + daftar pekerjaan yang belum selesai |

> Folder ini kini **mandiri** — kode, dokumentasi, dan aset acuan ada di satu tempat.

---

## Ringkasan Cepat

- **Jenis:** aplikasi web satu file HTML (`tropica-farm-ledger-supabase.html`).
- **Database:** Supabase (cloud), data dibagi ke seluruh tim.
- **Hosting:** Netlify.
- **Login:** email + password (dibuat manual di dashboard Supabase).

> ⚠️ **Catatan penting:** situs live saat ini masih memakai **build lama**
> (desain invoice final belum ter-deploy). Versi terbaru sudah siap di
> `~/Downloads/index.html`. Lihat [STATUS.md](STATUS.md) dan [DEPLOY.md](DEPLOY.md).
