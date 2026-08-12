# Cara Update / Deploy Situs

Situs live: **https://tropicafarm.netlify.app** — disajikan dari `index.html`.

## Auto-deploy (cara baru, sejak 2026-08-11)

Situs **tersambung ke GitHub** (`meirisay/tropica-apps`, remote `origin` via SSH) dengan
**Netlify Continuous Deployment**. Konfigurasi build ada di [`netlify.toml`](netlify.toml)
(hanya `index.html` yang dipublikasikan; dokumen `.md` & `database/*.sql` tidak ikut publik).

> **Deploy = push ke branch `main`.** Tidak perlu drag-drop lagi.

### Langkah

Pekerjaan aktif ada di branch **`cadangan-17jul`**; **`main`** = branch deploy.

```bash
# 1. commit perubahan di cadangan-17jul (lihat juga skill: commit)
git add index.html && git commit -m "..."   # akhiri dgn Co-Authored-By

# 2. (disarankan) bump penanda versi di index.html — baris login "Versi: Cetak vX.Y ..."
#    supaya deploy mudah diverifikasi.

# 3. merge ke main + push → memicu auto-deploy
git checkout main
git merge cadangan-17jul          # fast-forward
git push origin main             # ← Netlify otomatis build & deploy (~1–2 menit)
git checkout cadangan-17jul
git push origin cadangan-17jul
```

### Verifikasi (build ~1 menit)

```bash
curl -s https://tropicafarm.netlify.app | grep -o "Versi: [^<]*"
```
Pastikan menampilkan versi terbaru. Kalau setelah ~3 menit belum berubah, cek
**Netlify → Deploys** (build gagal/antre?) dan pastikan production branch = `main`.

## Troubleshooting

- **Push minta username/password GitHub:** remote ke-reset ke HTTPS. Kembalikan ke SSH:
  ```bash
  git remote set-url origin git@github.com:meirisay/tropica-apps.git
  ```
- **Data:** semua data di Supabase — deploy hanya memperbarui `index.html`, tidak menyentuh data.
- **Repo publik/privat:** file `.md` & `database/*.sql` ada di repo (tidak dipublish ke situs).
  Set repo **Private** di GitHub bila isinya sensitif.

## Riwayat metode lama (usang)

Dulu deploy manual: drag-drop `index.html` ke Netlify → tab Deploys. **Jangan dipakai lagi** —
sekarang cukup push ke `main`. (Dan jangan pernah pakai `app.netlify.com/drop` — itu bikin situs
baru dengan URL berbeda.)
