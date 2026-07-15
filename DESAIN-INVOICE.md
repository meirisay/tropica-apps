# Desain Dokumen PI & Invoice

Spesifikasi final untuk **Proforma Invoice (PI)** dan **Invoice** yang bisa dicetak
dari aplikasi. Diterapkan ke HTML pada 2026-07-14 (fungsi `renderOverlay()` +
`defaultNotes()`). Dokumen full berbahasa Inggris, logo asli ditanam sebagai base64.

Sumber acuan: `~/Downloads/Ringkasan_PI_Invoice_TropicaFarm.pdf` (spec) +
`Contoh_PI_...` / `Contoh_Invoice_...` (contoh).

## PI = Down Payment 50%

- Banner: **"DOWN PAYMENT 50%"**
- Payment Term: "50% DP (Down Payment)"
- Tanggal dokumen = tanggal PI/order
- Gold band **AMOUNT DUE NOW** = nilai DP (dibulatkan ke atas, mis. Rp 43.500.013)
- Satu baris "due max" ("Due max. {tempoDpHari} days after PI date. Remaining …
  via a separate Invoice…"), **tanpa** rincian
- Dasar jatuh tempo = tanggal PI + **tempoDpHari** (default **3**)

## Invoice = Final Payment 50%

- Banner: **"FINAL PAYMENT 50%"**
- Payment Term: "50% Final Payment"
- Gold band **AMOUNT DUE NOW** = sisa/final (mis. Rp 43.500.012)
- Rincian = Total Order Value + "Down Payment 50% already paid (PI …) − Rp …"
- Baris jatuh tempo = tanggal kirim + **tempoHari** (default **7**)
- **Invoice Date** adalah field terpisah yang bisa diedit (`invoiceDate`,
  default = tanggal kirim)

## Notes (catatan)

Selalu ada **3 poin dinamis otomatis** (teks berbeda untuk PI vs Invoice) +
opsional "additional notes" (`seller.notes`). Catatan tambahan **tidak menggantikan**
catatan otomatis, hanya ditambahkan.

## Perhitungan total

- **PPN 11%** hanya atas barang (goods only)
- **Ongkos kirim** ditambahkan setelah PPN, tidak dikenai pajak
- Pembagian 50/50: DP dibulatkan **ke atas**, sisa dibulatkan **ke bawah**

## Penomoran (⚠️ masih ada konflik)

Saat ini aplikasi memakai format **`/gtf`**:
- `PI/<yy><m>-<seq>/gtf` (seq PI mulai dari 1045)
- `INV/<yy><m>-<seq>/gtf` (seq Invoice mulai dari 1077)
- huruf kecil `/gtf`, bulan **tidak** di-nol-depan (not zero-padded)
- sesuai spesifikasi Ringkasan yang ditunjuk user

**TAPI** contoh PDF menunjukkan format berbeda: **`-GTF`** huruf besar + bulan
**2 digit** (mis. `PI/2604-1045-GTF`).

➡️ **Keputusan yang belum final:** pilih `/gtf` (sekarang) atau `-GTF`.
Jika user memutuskan pakai `-GTF`, ubah `genPI` / `genInvoice` menjadi
`padStart(2,'0')` untuk bulan + akhiran `-GTF`.
