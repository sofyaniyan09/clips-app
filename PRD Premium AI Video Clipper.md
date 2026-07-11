# Product Requirements Document (PRD)
## Premium AI Video Clipper — "Studio Produksi Otomatis"

| Metadata | Detail |
|---|---|
| Versi Dokumen | 1.0 |
| Status | Draft — Blueprint Kerja |
| Target Platform | Mobile (Flutter) + Backend Cloud |
| Tipe Produk | AI-Powered Automated Short-Form Video Production Studio |
| Target Pengguna | Content Creator TikTok / Reels / YouTube Shorts, Digital Agency, Solo Creator Niche (Trivia, Edukasi, Motivasi, dll) |

---

## 1. Ringkasan Produk & USP (Unique Selling Proposition)

### 1.1 Latar Belakang Masalah

Creator konten short-form saat ini menghadapi tiga masalah besar:
1. **Waktu editing manual yang mahal** — memotong video panjang (podcast, webinar, video edukasi) menjadi klip pendek membutuhkan jam kerja untuk mencari momen "viral-worthy".
2. **Kualitas visual editor otomatis kompetitor sangat generik** — hasil crop 9:16 kaku (center-crop statis), subtitle template usang, tanpa sentuhan sinematik.
3. **Inkonsistensi branding** — setiap kali membuat klip baru, creator harus mengulang proses styling (font, warna, watermark) secara manual.

### 1.2 Visi Produk

**Premium AI Video Clipper** bukan alat pemotong video (video cutter), melainkan **Studio Produksi Otomatis** — sebuah pipeline AI end-to-end yang mengubah satu video sumber panjang menjadi banyak output klip pendek dengan kualitas *cinematic-grade*, siap upload, tanpa sentuhan editing manual tambahan.

### 1.3 Unique Selling Proposition (USP)

| USP | Penjelasan Singkat |
|---|---|
| **"Zero Manual Touch to Viral"** | Input 1 link/file → Output klip yang sudah di-crop sinematik, di-subtitle, dan di-brand sesuai preset — tanpa perlu dibuka di editor lain. |
| **Kurasi Berbasis Narasi, Bukan Volume** | Kompetitor mendeteksi momen "ramai" (volume tinggi/tepuk tangan). Produk ini menggunakan LLM untuk membaca *makna* transkrip dan menemukan struktur psikologis penahan perhatian (hook → build-up → payoff). |
| **Estetika Sinematik Bawaan** | Depth-of-field buatan, color grading profesional, dan framing dinamis berbasis face-tracking — setara hasil kerja editor profesional. |
| **Branding Sistematis (Preset Niche)** | Sekali setting identitas visual niche (misalnya akun misteri/edukasi), semua output ke depannya otomatis konsisten tanpa perlu diatur ulang. |
| **Ringan di Perangkat Pengguna** | Seluruh proses berat (rendering, AI inference) berjalan di server, sehingga aplikasi mobile tetap ringan dan responsif di HP kelas menengah. |

### 1.4 Target Output Value Proposition

> "Anda memasukkan 1 video 60 menit → dalam beberapa menit, Anda menerima 5-10 klip pendek yang tampak seperti hasil kerja tim editor profesional, lengkap dengan branding channel Anda."

---

## 2. Arsitektur Sistem (Secara Teknis)

### 2.1 Prinsip Arsitektur

Pemisahan tugas tegas antara **presentation layer** (ringan, di client) dan **computation layer** (berat, di server) — pola ini disebut **"Thin Client, Fat Server"**.

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONT-END (Flutter)                       │
│  - UI/UX Dark Mode                                                │
│  - Input Link/File Upload                                         │
│  - Video Preview Player                                            │
│  - Job Status Polling / WebSocket Listener                        │
│  - Preset Management UI                                            │
└───────────────────────────┬────────────────────────────────────────┘
                            │ REST API / WebSocket (HTTPS)
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND — API GATEWAY LAYER                    │
│               (Node.js/Express atau Python/FastAPI)               │
│  - Auth & Session Management                                       │
│  - Job Queue Orchestrator (BullMQ / Celery + Redis)                │
│  - File Ingestion (yt-dlp untuk link, S3/local untuk upload)      │
└───────────────────────────┬────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────────┐  ┌──────────────────┐
│  Groq API      │   │  OpenRouter API    │  │  Processing Core │
│  (Whisper)     │   │  (LLM Kurasi)       │  │  (FFmpeg +        │
│  - Transkripsi │   │  - Analisis Narasi  │  │   MediaPipe)      │
│    Super Cepat │   │  - Timestamp Pilihan│  │  - Face Tracking   │
│                │   │  - Metadata Hook    │  │  - Crop 9:16       │
└───────────────┘   └───────────────────┘  │  - Color Grading   │
                                            │  - Bokeh Synthetic │
                                            │  - Subtitle Burn-in│
                                            └──────────────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │  Storage (S3/GCS)    │
                 │  - Final Clip Output │
                 │  - Thumbnail Preview │
                 └─────────────────────┘
```

### 2.2 Spesifikasi Front-End (Flutter)

| Aspek | Spesifikasi |
|---|---|
| Framework | Flutter (Dart), target Android & iOS |
| Tema | Dark-mode default, aksen warna neon/kontras tinggi untuk kesan "studio profesional" |
| State Management | Riverpod atau Bloc (disarankan Riverpod untuk skalabilitas solo dev) |
| Fungsi Utama | (1) Input tautan YouTube/TikTok/Drive, (2) Upload file lokal, (3) Video preview player (menggunakan `video_player` + `chewie`), (4) Manajemen preset (CRUD sederhana), (5) Dashboard status job (queued/processing/done) |
| Komunikasi Server | REST API (`dio` package) + WebSocket/Socket.IO untuk real-time progress bar |
| **Batasan Tegas** | **Front-end TIDAK melakukan decoding/encoding video, TIDAK menjalankan FFmpeg/inference AI apapun secara lokal.** Semua render berat 100% di server. |
| Output Rendering | Player hanya menampilkan hasil video final (streaming via signed URL dari cloud storage) |

### 2.3 Spesifikasi Back-End (Server-Side)

| Komponen | Teknologi | Fungsi |
|---|---|---|
| API Gateway | Node.js (Express/Fastify) *atau* Python (FastAPI) | Menerima request, autentikasi, routing job |
| Job Queue | Redis + BullMQ (Node) atau Celery (Python) | Antrian pemrosesan asinkron agar server tidak macet saat banyak job bersamaan |
| Ingestion Service | `yt-dlp` (untuk link YouTube/TikTok), multipart upload handler | Mengunduh/menerima video sumber |
| Speech-to-Text | **Groq API (Whisper large-v3)** | Transkripsi audio ke teks + timestamp per kata (word-level timestamps) dengan latensi sangat rendah |
| Narrative Curation Engine | **OpenRouter API** (routing ke Gemini 1.5 Pro / Claude 3.5 Sonnet — model dengan context window panjang) | Membaca transkrip penuh, mengidentifikasi segmen dengan struktur naratif kuat |
| Visual Processing Core | **FFmpeg** (command-line, dieksekusi via `fluent-ffmpeg` atau `subprocess`) | Crop, resize 9:16, color grading (LUT/filter), burn-in subtitle, render output |
| Face/Object Tracking | **MediaPipe** (Python — Face Mesh / Face Detection / Pose) | Mendeteksi posisi wajah per frame untuk menentukan titik fokus crop dinamis |
| Storage | AWS S3 / Google Cloud Storage / Cloudflare R2 | Menyimpan video sumber, hasil render, thumbnail |
| Database | PostgreSQL / MongoDB | Menyimpan data user, preset, riwayat job, metadata video |

### 2.4 Alasan Pemisahan Ini Penting

- **Skalabilitas**: Beban komputasi FFmpeg/MediaPipe berat (CPU/GPU-bound) tidak boleh membebani perangkat pengguna yang bervariasi (low-end hingga high-end).
- **Konsistensi Kualitas**: Semua rendering menggunakan environment server yang seragam — hasil output konsisten terlepas dari device pengguna.
- **Keamanan API Key**: Kredensial Groq API dan OpenRouter API tidak pernah terekspos ke client, seluruhnya tersimpan di environment variable server.

---

## 3. Fitur Utama & Fitur Pembeda (Killer Features)

### 3.1 Komposisi Visual Sinematik (Smart Cinematic Cropping)

**Cara Kerja:**
1. MediaPipe Face Detection/Face Mesh berjalan per-frame (atau per-N frame untuk efisiensi) pada video sumber untuk melacak koordinat wajah/subjek utama.
2. Koordinat tersebut dihaluskan menggunakan algoritma smoothing (misalnya *moving average* atau *Kalman filter*) agar pergerakan crop tidak "patah-patah" (jitter) saat subjek bergerak.
3. FFmpeg menerima koordinat crop dinamis per-timestamp (melalui filter `crop` dengan ekspresi dinamis atau generate segmented crop) untuk menghasilkan rasio 9:16 presisi yang selalu mengikuti subjek.
4. **Focal Depth Synthetic (Bokeh Buatan)**: Menggunakan segmentasi (MediaPipe Selfie Segmentation) untuk memisahkan subjek dari background, lalu menerapkan Gaussian blur bertingkat pada background melalui filter FFmpeg (`boxblur`/`gblur`) — menciptakan efek depth-of-field seperti kamera profesional meski sumber video flat.
5. **Color Grading Sinematik**: Menerapkan LUT (`.cube` file) atau filter kombinasi (`eq`, `curves`, `colorbalance`) di FFmpeg untuk menghasilkan tone warna khas sinema (contoh: teal-orange, moody-desaturated, warm-cinematic) — dipilih sesuai preset niche.

**Keunggulan vs Kompetitor:**
Kompetitor umum (CapCut auto-reframe, Opus Clip) menggunakan center-crop statis atau tracking kasar. Fitur ini menggabungkan tracking halus + depth effect + grading — hasil akhir terasa seperti "diedit manusia", bukan otomatis.

### 3.2 Kurator AI Berbasis Psikologi Narasi

**Cara Kerja:**
1. Transkrip lengkap (dengan timestamp) dari Groq Whisper dikirim ke LLM (via OpenRouter) sebagai satu kesatuan konteks utuh (memanfaatkan context window panjang Gemini 1.5 Pro/Claude 3.5 Sonnet).
2. Prompt sistem mengarahkan LLM untuk menganalisis struktur naratif, bukan sekadar volume/energi suara, dengan mencari pola:
   - **The Hook**: Kalimat pembuka yang memancing rasa penasaran/kontroversi dalam 3 detik pertama segmen.
   - **Fakta Mengejutkan/Twist**: Titik di mana informasi baru mengubah pemahaman pendengar.
   - **Comment-Bait**: Pernyataan kontroversial/terbuka untuk didebat yang memancing interaksi komentar.
   - **Payoff/Closure**: Penutup yang memberi rasa "selesai" secara emosional agar penonton puas menonton sampai akhir.
3. LLM mengembalikan output terstruktur (JSON) berisi daftar kandidat klip: `start_time`, `end_time`, `hook_score`, `alasan_naratif`, `judul_saran`.
4. Sistem menyortir kandidat berdasarkan skor gabungan (potensi retensi + panjang optimal 15-60 detik) dan menyajikan ke pengguna untuk konfirmasi atau otomatis diproses.

**Keunggulan vs Kompetitor:**
Kompetitor berbasis "audio peak/keyword spotting" sering salah memotong (memotong di tengah kalimat penting). Pendekatan berbasis pemahaman naratif utuh menghasilkan klip yang secara kontekstual lengkap dan psikologis lebih "menempel".

### 3.3 Sistem Auto-Branding Sekali Klik (Preset Niche)

**Cara Kerja:**
1. Pengguna membuat "Preset Niche" sekali di awal — menyimpan kombinasi: LUT color grading, font & warna subtitle, posisi & ukuran watermark/logo (dengan koordinat presisi piksel), style animasi caption.
2. Contoh preset **"Trivia Misteri/Edukasi"**:
   - Color grading: moody, desaturasi tinggi, sedikit vignette gelap di tepi frame.
   - Subtitle: font tebal (bold sans-serif), ukuran besar, warna putih dengan stroke hitam.
   - Watermark: logo/teks "TK" disematkan presisi di sudut kanan-atas (misal offset 24px dari tepi), ukuran & transparansi tetap konsisten di semua output.
3. Preset disimpan sebagai konfigurasi JSON di database, dipanggil ulang oleh FFmpeg command generator setiap kali user memilih preset tersebut untuk job baru.

**Keunggulan vs Kompetitor:**
Kompetitor mengharuskan user mengatur ulang branding di setiap video. Fitur ini menjadikan branding sebagai *reusable asset* — cocok untuk creator yang mengelola banyak channel niche berbeda secara paralel.

### 3.4 Smart Subtitle Interaktif & Emosional

**Cara Kerja:**
1. Timestamp per-kata dari Groq Whisper digunakan untuk membuat file subtitle dinamis (format ASS/SSA, bukan SRT statis) yang mendukung animasi per-kata.
2. FFmpeg (via filter `ass`/`subtitles`) melakukan burn-in subtitle dengan animasi pop-up (scale-in, fade-in per kata muncul sinkron dengan audio).
3. LLM tahap kurasi juga menandai *kata-kata pemicu emosi* (contoh: angka mengejutkan, kata superlatif, kata kontroversial) dalam metadata — kata-kata ini di-render dengan warna kontras berbeda (misal kuning/merah menyala) dibanding warna subtitle default.
4. Style animasi (bounce, shake ringan, scale pop) dikontrol lewat parameter ASS tag (`\t`, `\fscx`, `\fscy`) yang di-generate otomatis oleh script backend.

**Keunggulan vs Kompetitor:**
Auto-caption kompetitor umumnya statis per-baris. Animasi per-kata + highlight emosional otomatis meningkatkan watch-time dan menonjolkan bagian penting tanpa editing manual.

---

## 4. Langkah Eksekusi Pengembangan (Development Roadmap)

> Roadmap dirancang realistis untuk pengembang solo, dengan pendekatan iteratif — setiap fase menghasilkan milestone yang bisa diuji secara independen sebelum lanjut ke fase berikutnya.

### Fase 1 — Pengembangan UI/UX Front-End Flutter (Estimasi: 2–3 minggu)

- [ ] Setup project Flutter + struktur folder (feature-based architecture)
- [ ] Desain sistem dark-mode (color palette, typography, komponen reusable)
- [ ] Halaman: Home/Input (link paste + file upload), Dashboard Job Status, Preset Manager, Video Preview Player
- [ ] Integrasi state management (Riverpod)
- [ ] Mock API (dummy JSON) untuk simulasi alur tanpa backend nyata
- [ ] **Milestone:** UI bisa diklik end-to-end dengan data dummy, siap dihubungkan ke backend.

### Fase 2 — Pembangunan Jembatan Back-End (Server API) (Estimasi: 2 minggu)

- [ ] Setup server (FastAPI/Express) + struktur endpoint dasar (`/upload`, `/job/status/:id`, `/preset`)
- [ ] Integrasi `yt-dlp` untuk ingestion video dari link
- [ ] Setup job queue (Redis + BullMQ/Celery) untuk pemrosesan asinkron
- [ ] Setup storage (S3/GCS) untuk file sumber & output
- [ ] Autentikasi dasar (JWT) & manajemen user
- [ ] **Milestone:** Flutter app bisa upload video/link nyata, server menerima & menyimpan file, status job ter-update (meski proses AI belum jalan).

### Fase 3 — Integrasi Logika API AI (Estimasi: 2–3 minggu)

- [ ] Integrasi Groq API (Whisper) → hasilkan transkrip + timestamp per kata
- [ ] Desain prompt engineering untuk OpenRouter (Gemini 1.5 Pro/Claude 3.5 Sonnet) → kurasi momen berbasis narasi
- [ ] Struktur output JSON terstandarisasi (start/end time, skor, alasan, judul saran)
- [ ] Endpoint baru: `/job/transcribe`, `/job/curate`
- [ ] Testing akurasi kurasi dengan sample video beragam (podcast, edukasi, motivasi)
- [ ] **Milestone:** Sistem bisa menerima video panjang → otomatis menghasilkan daftar timestamp klip potensial dengan alasan naratif, ditampilkan di Flutter app.

### Fase 4 — Mesin Pemotong Mekanis (FFmpeg & MediaPipe) (Estimasi: 3–4 minggu)

- [ ] Script MediaPipe untuk face-tracking & generate koordinat crop per-frame
- [ ] Algoritma smoothing pergerakan crop (anti-jitter)
- [ ] Script FFmpeg: crop dinamis 9:16, color grading (LUT), synthetic bokeh
- [ ] Implementasi generator subtitle ASS dinamis (animasi + highlight kata emosional) dari data Groq
- [ ] Sistem Preset Niche → mapping konfigurasi ke parameter FFmpeg otomatis
- [ ] Pipeline render final: gabungkan seluruh layer (crop + grading + subtitle + watermark) → export MP4 final
- [ ] Optimasi performa render (paralelisasi job, GPU-acceleration jika tersedia — `h264_nvenc`)
- [ ] **Milestone:** End-to-end pipeline lengkap — dari input link/file hingga output klip final siap upload, dapat diunduh via Flutter app.

### Fase 5 (Lanjutan/Opsional) — Polish & Skalabilitas

- [ ] Notifikasi push saat job selesai
- [ ] Batch processing (multi-klip sekaligus dari 1 video sumber)
- [ ] Analytics dasar (klip mana yang paling sering di-generate/preset favorit)
- [ ] Monetisasi (subscription tier: jumlah render/bulan, resolusi output, akses preset premium)

---

## Lampiran: Pertimbangan Teknis Tambahan

| Topik | Catatan |
|---|---|
| Biaya Operasional | Groq API (murah & cepat untuk STT), OpenRouter (bayar per-token sesuai model dipilih) — perlu monitoring biaya per-job untuk pricing tier pengguna |
| Concurrency | Job queue wajib membatasi jumlah render FFmpeg paralel sesuai kapasitas CPU/GPU server agar tidak overload |
| Format Output | MP4 (H.264) 9:16, resolusi 1080x1920, bitrate disesuaikan platform target (TikTok/Reels/Shorts) |
| Keamanan | Validasi ukuran & durasi file upload, rate-limiting API, sanitasi input link (hindari SSRF via `yt-dlp`) |
| Privasi Data | Video sumber sebaiknya dihapus otomatis dari storage server setelah periode retensi tertentu (misal 7 hari) |

---

*Dokumen ini adalah blueprint kerja awal. Detail teknis (skema database, kontrak API endpoint, prompt LLM final) akan dijabarkan lebih lanjut dalam dokumen teknis terpisah per fase pengembangan.*
