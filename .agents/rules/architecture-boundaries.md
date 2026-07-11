---
trigger: always_on
---

FRONT-END (Flutter) HANYA boleh berisi kode UI/UX: tampilan, navigasi,
pemutar video preview, dan pemanggilan API. Front-end TIDAK BOLEH
menjalankan FFmpeg, MediaPipe, atau logika AI apapun secara lokal.

Semua proses berat (rendering video, face-tracking, transkripsi,
kurasi narasi AI) WAJIB berjalan di backend server.

Setiap endpoint API backend harus asinkron dan masuk ke job queue
(Redis + BullMQ/Celery), bukan diproses langsung secara sinkron pada
request masuk.