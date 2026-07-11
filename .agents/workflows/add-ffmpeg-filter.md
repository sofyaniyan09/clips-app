---
description: Standar penambahan filter FFmpeg baru (crop, color grading, subtitle burn-in) agar reusable dan teruji dengan sample kecil sebelum dianggap selesai.
---

Saat menambahkan filter FFmpeg baru, ikuti langkah berikut:

1. Tulis command FFmpeg sebagai fungsi terpisah dan reusable — jangan ditulis langsung di dalam logic endpoint/controller.
2. Sertakan contoh command lengkap sebagai komentar di kode.
3. Buat/gunakan file video sample berdurasi kurang dari 30 detik untuk pengujian awal.
4. Jalankan filter pada sample tersebut dan verifikasi hasilnya secara visual sebelum melanjutkan.
5. Laporkan estimasi waktu render dan ukuran file output dari sample tersebut.
6. Jika filter ini akan dipakai berulang di preset niche berbeda, pastikan parameternya bisa dikonfigurasi (bukan hardcoded).