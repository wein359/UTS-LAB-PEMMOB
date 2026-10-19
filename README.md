# 🧠 QuizApp — Aplikasi Kuis Pilihan Ganda

<p align="center">
  <img src="screenshots/logo.png" alt="App Logo" width="120"/>
</p>

---

## 👤 Identitas Mahasiswa

| Field | Detail |
|-------|--------|
| **Nama** | Wein Ilham Lutfi|
| **NIM**  | 241401101 |
| **LAB**  | Pemograman Mobile 3 |

---

## 📱 Informasi Aplikasi

### Nama Aplikasi
**QuizApp — Kuis Pemrograman Mobile**

### Deskripsi Singkat
QuizApp adalah aplikasi kuis pilihan ganda berbasis Flutter yang dirancang
untuk menguji pengetahuan pengguna seputar Pemrograman Mobile dan Flutter.
Pengguna memasukkan nama, menjawab 10 soal pilihan ganda dengan batas waktu
15 detik per soal, lalu melihat skor akhir beserta ringkasan jawaban secara
detail.

### Fitur-Fitur yang Tersedia

#### ✅ Fitur Wajib
| No | Fitur | Keterangan |
|----|-------|------------|
| 1 | **Input Nama Pengguna** | Validasi nama minimal 2 karakter sebelum kuis dimulai |
| 2 | **10 Soal Pilihan Ganda** | Soal seputar Flutter & Pemrograman Mobile dengan 4 opsi jawaban (A–D) |
| 3 | **Timer Per Soal** | Countdown 15 detik per soal; soal otomatis dilewati jika waktu habis |
| 4 | **Navigasi Antar Halaman** | WelcomeScreen → QuizScreen → ResultScreen menggunakan `pushReplacement` |
| 5 | **Reusable Widgets** | `CustomButton`, `CustomTextField`, `OptionCard`, `QuestionCard`, `TimerBar`, `QuizHeader`, `QuizIllustration`, `ResultIllustration` — masing-masing file terpisah |
| 6 | **Ilustrasi / Aset Visual** | Semua ilustrasi digambar dengan `CustomPainter` (tidak membutuhkan file gambar eksternal) |
| 7 | **Font Kustom** | Menggunakan font **Poppins** dari Google Fonts (didaftarkan di `pubspec.yaml`) |
| 8 | **UI Dinamis & Responsif** | `LayoutBuilder` + `MediaQuery` untuk menyesuaikan ukuran layar; `OrientationBuilder` untuk portrait/landscape |
| 9 | **State Management** | `Provider` (ChangeNotifier) — progres jawaban tidak hilang saat rotasi layar atau navigasi |
| 10 | **Data Lokal / Dummy** | 10 soal disimpan di `lib/data/quiz_data.dart`, tidak menggunakan database |

#### 🌟 Fitur Bonus
| No | Fitur | Keterangan |
|----|-------|------------|
| 1 | **Dark Mode & Light Mode** | Toggle tema terang/gelap via `ThemeProvider`; ikon animasi rotate+fade |
| 2 | **Adaptive & Responsive Design** | Layout dua kolom di landscape, padding dinamis untuk tablet, semua ukuran menggunakan `.clamp()` |

#### ✨ Fitur Tambahan
| Fitur | Keterangan |
|-------|------------|
| Animasi Entry WelcomeScreen | Fade-in + slide-up saat halaman pertama muncul |
| Animasi Transisi Halaman | Slide kanan→kiri (Welcome→Quiz), fade (Quiz→Result, Result→Welcome) |
| Live Score | Skor benar ditampilkan secara real-time di header saat kuis berlangsung |
| Animasi Timer Shake | Timer bergetar horizontal saat sisa waktu ≤ 4 detik |
| Animasi Slide Soal | Kartu pertanyaan slide + fade saat berpindah ke soal berikutnya |
| Reveal Warna Opsi | Jawaban benar → hijau, salah → merah, lainnya → redup setelah menjawab |
| Haptic Feedback | Getaran ringan saat memilih jawaban |
| Ilustrasi Hasil Kondisional | 4 ilustrasi berbeda: Trofi (100%), Medali (≥70%), Buku (≥40%), Roket (<40%) |
| Review Jawaban Expandable | `ExpansionTile` per soal di ResultScreen — tampilkan semua opsi dengan highlight |
| Avatar Inisial | Lingkaran gradient dengan 1–2 inisial nama pengguna di header kuis |

---


---

## 📸 Screenshot Aplikasi

> [ TAMBAHKAN SCREENSHOT TIAP HALAMAN DI SINI ]
> Contoh cara menambahkan:
> ```
> ![Welcome Screen](screenshots/welcome_screen.png)
> ![Quiz Screen](screenshots/quiz_screen.png)
> ![Result Screen](screenshots/result_screen.png)
> ```

| Welcome Screen | Quiz Screen | Result Screen |
|:-:|:-:|:-:|
| ![Welcome](screenshots/welcome_screen.png) | ![Quiz](screenshots/quiz_screen.png) | ![Result](screenshots/result_screen.png) |

| Dark Mode | Landscape Mode |
|:-:|:-:|
| ![Dark](screenshots/dark_mode.png) | ![Landscape](screenshots/landscape.png) |

---

## 🔗 Tautan

| Jenis | Link |
|-------|------|
| 🎨 Mockup / Prototype | [ ISI LINK FIGMA / CANVA MOCKUP KAMU ] |
| 🎥 Video Presentasi | [ ISI LINK GOOGLE DRIVE VIDEO KAMU ] |

---

## 🛠️ Teknologi yang Digunakan

| Teknologi | Versi |
|-----------|-------|
| Flutter | 3.27+ |
| Dart | 3.13+ |
| Provider | ^6.1.2 |
| Font Poppins | Google Fonts |

---

## 🚀 Cara Menjalankan Proyek

```bash
# 1. Clone repository
git clone https://github.com/[ USERNAME_GITHUB_KAMU ]/uts_lab.git

# 2. Masuk ke direktori proyek
cd uts_lab

# 3. Install dependencies
flutter pub get

# 4. Jalankan aplikasi
flutter run


