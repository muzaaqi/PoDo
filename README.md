# PoDo — Portal Dosen

<p align="center">
  <img src="assets/images/logo.png" alt="PoDo Logo" width="120" />
</p>

<p align="center">
  <strong>Aplikasi Mobile Portal Akademik Dosen Berbasis Flutter & Forui Design System</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/UI_Library-Forui-blueviolet" alt="Forui" />
  <img src="https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite" alt="SQLite" />
  <img src="https://img.shields.io/badge/Tests-197%20Passed-brightgreen" alt="Tests" />
  <img src="https://img.shields.io/badge/Release-v1.0.0-blue" alt="Release" />
</p>

---

## 📱 Tentang PoDo

**PoDo (Portal Dosen)** adalah aplikasi mobile yang dirancang khusus untuk memfasilitasi aktivitas tridharma dosen di lingkungan perguruan tinggi. Aplikasi ini memungkinkan dosen untuk mengelola jadwal mengajar harian, data master mata kuliah dan kelas (offering), direktori dan biodata mahasiswa, hingga penilaian akademik bertahap berbasis Capaian Pembelajaran Mata Kuliah (CPMK 1 - 4) secara luring (*offline-first*) menggunakan basis data lokal SQLite.

Antarmuka dibangun dengan mengedepankan **Forui Design System**, menghadirkan pengalaman visual modern, responsif, dan konsisten dengan palet warna matte pastel yang ramah mata.

---

## 📥 Unduh APK

Versi rilis siap pakai dapat diunduh langsung melalui tautan GitHub Releases di bawah ini:

👉 **[Unduh PoDo v1.0.0 (app-release.apk)](https://github.com/muzaaqi/PoDo/releases/latest/download/app-release.apk)**

Untuk melihat seluruh riwayat rilis dan log perubahan, kunjungi halaman **[GitHub Releases](https://github.com/muzaaqi/PoDo/releases)**.

---

## ✨ Fitur Utama

### 1. Autentikasi Dosen & Multi-Akun Demo
- Login menggunakan email atau username dengan kata sandi.
- Akun terhubung langsung ke data dosen pada basis data SQLite lokal.
- Sesi aktif tersimpan secara aman dalam state aplikasi.
- Dialog konfirmasi saat keluar (*logout*) untuk mencegah aksi tidak sengaja.

### 2. Dasbor Akademik (Home Screen)
- Sapaan personal kepada dosen aktif dan kartu identitas singkat.
- Ringkasan metrik statistik: jumlah kelas aktif, mahasiswa bimbingan, dan jadwal mengajar hari ini.
- Aksi Cepat (*Quick Actions*):
  - **Isi Biodata Mahasiswa**: membuka form tambah mahasiswa baru.
  - **Informasi Mahasiswa**: membuka direktori mahasiswa lengkap dengan pencarian.
  - **Input Nilai**: mengarahkan langsung ke daftar mata kuliah yang diampu.
- Pengumuman dan informasi terkini dari kampus.

### 3. Jadwal Mengajar Interaktif (Schedule Screen)
- Filter hari interaktif (Senin hingga Sabtu).
- Kartu jadwal memuat nama mata kuliah, kelas, ruangan perkuliahan, rentang jam mengajar, dan bobot SKS.
- Penanda waktu aktif (*status badge*) yang informatif.

### 4. Manajemen Mata Kuliah & Kelas (Courses)
- **Katalog Kelas Dosen**: menampilkan seluruh kelas yang diampu dosen aktif dengan pencarian nama atau kode mata kuliah.
- **Speed Dial Action**:
  - **Tambah Mata Kuliah Baru**: membuat master data mata kuliah (Kode, Nama, SKS).
  - **Tambah Kelas / Offering**: membuka kelas baru dengan integrasi jadwal otomatis (hari, jam mulai, jam selesai, ruangan, dan tahun ajaran).
- **Detail Kelas & Jadwal Terintegrasi**:
  - Kartu header menampilkan jadwal perkuliahan utama secara otomatis.
  - Edit kelas dan jadwal dalam satu alur terpadu.
  - Hapus kelas dengan perlindungan konfirmasi dan penghapusan relasi jadwal serta nilai (*cascade delete*).

### 5. Penilaian Progresif CPMK (Grading System)
- Input nilai langsung dari daftar mahasiswa di halaman detail kelas melalui modal sheet Forui.
- **Fleksibel & Progresif**: dosen dapat mengisi nilai secara bertahap (misalnya hanya CPMK 1 & 2 di tengah semester). Komponen yang belum dinilai dapat dikosongkan.
- **Kalkulasi Otomatis**: rata-rata nilai dihitung secara dinamis hanya dari komponen CPMK yang sudah terisi.
- **Validasi Ketat**: memvalidasi rentang nilai 0 s.d. 100 untuk setiap komponen dan mencegah submit tanpa satu pun nilai.
- **Status Mahasiswa**: visual badge *Sudah Dinilai* atau *Belum Dinilai* dengan ringkasan chip nilai tiap CPMK (`C1: 85  C2: 90  C3: -  C4: -`).

### 6. Pengelolaan Mahasiswa Kelas (Roster Management)
- Tambah mahasiswa ke dalam kelas dengan pilihan mahasiswa yang belum terdaftar.
- Hapus mahasiswa dari kelas dalam mode kelola mahasiswa.

### 7. Direktori & Biodata Mahasiswa (Student CRUD)
- Pencarian cepat daftar mahasiswa berdasarkan Nama atau NIM.
- Form lengkap untuk menambah atau memperbarui biodata mahasiswa:
  - Nomor Induk Mahasiswa (NIM) dengan validasi digit.
  - Nama Lengkap Mahasiswa.
  - Program Studi (pilihan dropdown Forui dengan opsi "Lainnya" untuk input kustom).
  - Jurusan / Departemen.
  - Nomor Telepon dengan validasi format.
  - Alamat Domisili.
- Peringatan perubahan belum tersimpan (*unsaved changes guard*) saat pengguna menekan tombol kembali.

### 8. Profil Dosen (Account Screen)
- Menampilkan foto profil atau avatar inisial, nama lengkap dengan gelar, NIDN / NIDH, departemen, email, dan nomor telepon.
- Ringkasan aktivitas akademik dosen yang diambil langsung dari database SQLite.

---

## 🔑 Kredensial Demo

Untuk mencoba dan menguji aplikasi, gunakan salah satu akun demo berikut:

| Nama Dosen | Email / Username | Password | NIDN / NIDH | ID Dosen |
|---|---|---|---|---|
| **Dr. Budi Santoso, M.Kom.** | `dosen@kampus.id` atau `dosen` | `password123` | 0012038501 | `L001` |
| **Dr. Siti Rahayu, M.T.** | `siti@kampus.id` atau `siti` | `password123` | 0025068802 | `L002` |

---

## 🛠️ Arsitektur & Teknologi

Proyek ini dibangun mengikuti prinsip **Feature-Based Architecture**:

```text
lib/
├── app/                  # Inisialisasi aplikasi, tema root, dan konfigurasi rute
│   ├── app.dart
│   └── routes.dart
├── core/                 # Komponen dan utilitas bersama lintas fitur
│   ├── database/         # SQLite helper dan seeder data awal
│   ├── theme/            # Token tema Forui (warna, radius, tipografi)
│   └── widgets/          # Widget global pakai ulang
└── features/             # Modul fungsional per domain
    ├── auth/             # Login dan manajemen sesi dosen
    ├── dashboard/        # Halaman Home dan ringkasan metrik
    ├── schedule/         # Jadwal mengajar dan filter hari
    ├── courses/          # Mata kuliah, kelas, dan roster mahasiswa
    ├── grades/           # Form CPMK progresif dan kalkulasi nilai
    ├── students/         # Direktori dan form biodata mahasiswa
    └── lecturers/        # Profil dan informasi akademik dosen
```

### Tech Stack:
- **Framework:** Flutter (Channel stable, Dart 3.x)
- **UI Library:** [Forui](https://forui.dev/) (`forui: ^0.27.7`)
- **Icon Pack:** Forui Lucide Icons integration
- **Database:** SQLite via [`sqflite`](https://pub.dev/packages/sqflite)
- **Testing:** `flutter_test`, `sqflite_common_ffi`

---

## 🚀 Memulai (Panduan Pengembang)

### Prasyarat
- Flutter SDK versi 3.13 atau yang lebih baru.
- Android Studio / VS Code dengan ekstensi Flutter & Dart.
- Perangkat fisik Android atau Android Emulator (API level 24+).

### Langkah Instalasi

1. **Clone repositori:**
   ```bash
   git clone https://github.com/muzaaqi/PoDo.git
   cd PoDo
   ```

2. **Pasang dependensi:**
   ```bash
   flutter pub get
   ```

3. **Jalankan analisis kode:**
   ```bash
   flutter analyze
   ```

4. **Jalankan pengujian otomatis:**
   ```bash
   flutter test
   ```

5. **Jalankan aplikasi di perangkat / emulator:**
   ```bash
   flutter run
   ```

### Membuat Build APK Rilis

Untuk menghasilkan paket APK produksi:

```bash
flutter build apk --release
```

Hasil build akan berada di: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Status Pengujian

Seluruh alur fitur telah diuji secara komprehensif menggunakan automated widget testing dan integration flow tests:
- **Total Test:** 197 pengujian unit dan widget.
- **Hasil:** 100% lulus tanpa kegagalan.
- **Cakupan Pengujian:**
  - Login dan alur navigasi 4 tab utama.
  - CRUD Mahasiswa dan validasi form biodata.
  - Tambah Mata Kuliah & Kelas beserta validasi rentang waktu 24 jam.
  - Penilaian CPMK 1 - 4 progresif, kalkulasi rata-rata, dan pembaruan SQLite.
  - Alur integrasi end-to-end (Home -> Course List -> Course Detail -> Grade Input Sheet).

---

## 📄 Lisensi

Proyek ini dikembangkan untuk keperluan akademik dan portofolio.
Hak cipta dilindungi undang-undang.
