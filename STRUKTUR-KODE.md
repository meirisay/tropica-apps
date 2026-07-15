# Struktur Kode

## Bentuk aplikasi

Aplikasi ini adalah **satu file HTML** yang berdiri sendiri — semua tampilan,
logika, dan styling ada di dalam satu berkas. Tidak ada proses build, tidak perlu
install apa pun; cukup dibuka di browser atau di-host apa adanya.

## File-file

### Di folder proyek ini (`Documents/gtf/aplikasi/`)

| File | Keterangan |
|------|-----------|
| `index.html` | **Aplikasi utama.** Build final, identik dengan file kanonik di `~/Downloads`. Dipakai untuk pengembangan & deploy. |
| `referensi/` | Logo sumber + PDF spesifikasi & contoh (acuan desain). |

### Di folder `~/Downloads/` (arsip / sumber asli)

| File | Keterangan |
|------|-----------|
| `tropica-farm-ledger-supabase.html` | **File kanonik asli.** Versi Supabase terbaru — sama isinya dengan `index.html` di sini. |
| `index.html` | Salinan siap-deploy (nama `index.html` supaya jadi halaman root di Netlify). |
| `tropica-farm-ledger-v2.html` | Salinan cadangan, identik dengan file utama. |
| `tropica-farm-ledger.html` | Versi **LAMA** sebelum Supabase — tidak dipakai lagi. |

> Karena `index.html` di folder ini identik dengan yang kanonik, edit boleh dilakukan di
> sini. Saat mau deploy, pastikan salinan yang dinaikkan ke Netlify sudah versi terbaru
> (lihat [DEPLOY.md](DEPLOY.md)).

Aset pendukung: `Logo Icon.png` (logo lingkaran emas, sudah ditanam sebagai base64
di dalam HTML), serta PDF contoh & spesifikasi PI/Invoice.

> Badge versi **"Desain final v2"** tampil di header dan layar login — gunanya untuk
> mendeteksi apakah browser menampilkan versi terbaru atau versi lama yang ter-cache.

## Tab dalam aplikasi

| Tab | Fungsi |
|-----|--------|
| **Ringkasan** | Dashboard ikhtisar keuangan. |
| **Modal** | Pencatatan modal / permodalan. |
| **Arus kas** | Log transaksi inti. Entri keluar yang berkategori otomatis mengisi tab Biaya usaha. |
| **Biaya usaha** | Read-only, terisi otomatis dari kategori kas keluar. |
| **Penjualan** | Berbasis order: nomor Invoice/PI otomatis, pembayaran DP + pelunasan yang otomatis masuk ke Arus kas, serta cetak PI & Invoice. |
| **Piutang** | Daftar order belum lunas + hitung mundur jatuh tempo. |
| **HPP** | Laba per pembeli, investor, kas kecil, laba bersih. |

## Cara data disimpan (ringkas)

Dulu data disimpan di `window.storage` (lokal di browser). **Sekarang semua data
disimpan di Supabase** lewat fungsi `safeGet(key)` dan `safeSet(key, value)`.
Detail lengkap ada di [DATABASE.md](DATABASE.md).
