# Database — Supabase

Semua data aplikasi disimpan di **Supabase** (dipilih pada 2026-07-14 dibanding
Google Sheets / Firebase karena butuh login sungguhan + peran/role). Karena data
di cloud, seluruh tim melihat data yang sama.

## Koneksi

- **Project URL:** `https://odokswsetqfgibwtqptz.supabase.co`
- **Project ref:** `odokswsetqfgibwtqptz`
- **Region:** Southeast Asia (Singapore)

`SUPABASE_URL` dan `SUPABASE_ANON_KEY` ditanam langsung di dalam HTML
(sekitar baris 247–248 pada file utama).

> 🔑 **Kunci & keamanan:** anon key memang **aman** dipublikasikan — dilindungi oleh
> login + RLS (Row Level Security). **`service_role` key TIDAK BOLEH** dimasukkan ke
> dalam file HTML dalam kondisi apa pun.

## Model penyimpanan

Semua data disimpan dalam **satu tabel key-value**:

```
public.kv_store (
  key         text primary key,
  value       jsonb,
  updated_at  timestamptz
)
```

- **RLS aktif** dengan satu policy: `for all to authenticated using (true) with check (true)`
  → siapa pun yang sudah login boleh baca/tulis.
- Fungsi aplikasi:
  - `safeGet(k)` → `.select('value').eq('key', k).maybeSingle()`
  - `safeSet(k, v)` → `.upsert({ key, value })`

### Daftar key yang dipakai

```
months            buyers            capital
invSeq            piSeq             seller
cash:<month>:<buyerId>
sales:<month>:<buyerId>
settings:<month>
```

## Login / Autentikasi

- Metode: **email + password**.
- Akun tim dibuat **manual** di dashboard Supabase:
  **Authentication → Users → Add user**, centang **"Auto Confirm User"**.
- Aplikasi punya gerbang login (`boot()` → `showApp` / `showLogin`) dengan tombol
  **Keluar/logout**. Nama pengguna (`whoName`) terisi otomatis dari email.

## Yang perlu diperhatikan (concurrency)

Penyimpanan memakai **upsert per-key utuh**, sehingga jika dua orang mengedit
bulan + pembeli yang sama **bersamaan**, berlaku *last-write-wins* (yang menyimpan
terakhir menang). Ini masih dapat diterima untuk tim kecil, dan bisa diperkuat nanti
bila diperlukan.

> Koneksi terverifikasi berfungsi pada 2026-07-14 (REST 200, login berhasil).
