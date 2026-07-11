---
description: Standar integrasi Groq API dan OpenRouter API — memastikan API key aman, ada retry logic, dan token usage ter-log untuk monitoring biaya.
---

Saat mengintegrasikan Groq API atau OpenRouter API, ikuti langkah berikut:

1. Buat service/wrapper function terpisah per provider (misal groqService.js, openRouterService.js) — jangan panggil API langsung dari controller/route.
2. Tambahkan retry logic sederhana (2-3 kali percobaan) jika request gagal karena timeout/rate limit.
3. Log token usage (input/output) dan durasi request setiap kali API dipanggil, untuk keperluan monitoring biaya per-job.
4. Pastikan API key dibaca dari environment variable (.env), dan lakukan pengecekan bahwa file .env sudah masuk .gitignore.
5. Tambahkan fallback ke model alternatif jika model utama gagal/limit tercapai (khusus untuk panggilan lewat OpenRouter).