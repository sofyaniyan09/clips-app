---
description: Standar pembuatan endpoint API baru di backend Premium AI Video Clipper — memastikan setiap endpoint mengikuti pola asinkron dengan job queue.
---

Saat membuat endpoint API baru, ikuti langkah berikut secara berurutan:

1. Buat route baru dengan validasi input (tipe data, field wajib, format file/link).
2. Jangan proses request secara sinkron — masukkan proses berat ke job queue (Redis + BullMQ/Celery).
3. Return response berisi job_id dan status awal ("queued").
4. Buat/gunakan endpoint status terpisah untuk polling progress job berdasarkan job_id.
5. Tambahkan error handling untuk kasus: file tidak valid, link rusak/tidak bisa diunduh, dan payload kosong.
6. Setelah selesai, tuliskan ringkasan singkat cara mengetes endpoint ini secara manual (contoh request & response yang diharapkan).