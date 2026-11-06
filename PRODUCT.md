# Product: PoDo (Portal Dosen)

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Dosen (Lecturer) adalah satu-satunya jenis pengguna pada versi ini. Dosen mengakses aplikasi secara luring pada perangkat mobile untuk melihat jadwal mengajar, mengelola kelas/offering yang diampu, mendata mahasiswa, dan menginput nilai evaluasi pembelajaran berbasis CPMK.

## Product Purpose

PoDo (Portal Dosen) adalah aplikasi mobile berbasis Flutter yang membantu dosen mengakses informasi akademik dan menjalankan aktivitas pengajaran dasar secara mandiri. Data disimpan di SQLite pada perangkat lokal (bukan server/cloud). Sukses berarti dosen dapat dengan cepat menemukan jadwal, melihat daftar mahasiswa pada kelas yang diampu, dan memasukkan nilai CPMK 1-4 secara akurat dan persisten.

## Positioning

Aplikasi portal dosen offline-first yang ramping dan berfokus langsung pada alur mengajar dan penilaian berbasis CPMK (Capaian Pembelajaran Mata Kuliah). Berbeda dari sistem informasi akademik institusi besar yang lambat dan penuh modul administrasi kompleks, PoDo dirancang khusus untuk kenyamanan langsung dosen di kelas tanpa ketergantungan koneksi jaringan luar.

## Operating Context

- **Lingkungan Penggunaan:** Kampus, ruang kelas, laboratorium, atau ruang kerja dosen pada perangkat ponsel Android.
- **Ritual & Alur Inti:**
  1. Login demo hardcoded (dipetakan ke `lecturer_id`).
  2. Home: sapaan dosen, quick actions (Isi Biodata Mahasiswa, Mahasiswa, Input Nilai).
  3. Jadwal: filter hari mengajar, ruangan, dan jam perkuliahan.
  4. Mata Kuliah: melihat offering/kelas dosen, detail kelas, daftar mahasiswa.
  5. Penilaian: memilih mahasiswa pada Course Detail -> membuka Grade Input Bottom Sheet -> mengisi nilai CPMK 1-4 (rentang 0-100) -> simpan ke SQLite.
  6. Akun: profil dosen aktif dan logout.

## Capabilities and Constraints

- **Teknologi:** Flutter (Dart), Forui component library (`forui`), SQLite (`sqflite`), dan `path`.
- **Database Architecture:** Hardcoded Seed Data -> SQLite -> Repository -> UI. Seluruh akses data melalui `DatabaseHelper` dan repository feature-based.
- **Navigasi Utama:** 4 tab pada `FBottomNavigationBar`: Home -> Jadwal -> Mata Kuliah -> Akun.
- **Screen Fungsional:** 8 screen fungsional (Home, Jadwal, Mata Kuliah/Course List, Detail Mata Kuliah, Akun, Daftar Mahasiswa, Form Biodata Mahasiswa, Login) + 1 Splash Screen + 1 Grade Input Bottom Sheet (modal overlay, bukan route mandiri).
- **Aturan Integritas Data:**
  - NIM mahasiswa unik.
  - Kode master course unik.
  - Kombinasi `offering_id` dan `student_nim` unik.
  - Relasi 1 enrollment ke maksimal 1 grade record (CPMK 1-4).
  - Nilai CPMK 1, 2, 3, 4 divalidasi pada rentang 0-100.
  - Tidak ada modul UTS, UAS, kehadiran, atau tugas. Tidak mengarang rumus nilai akhir/huruf mutu tanpa aturan resmi.
- **Autentikasi Demo:** Kredensial hardcoded di `AuthRepository` untuk demo tugas perkuliahan; tidak menyimpan password di SQLite.

## Brand Commitments

- **Nama Aplikasi:** PoDo (Portal Dosen).
- **Visual Design System:** Forui (`forui`) sebagai sumber kebenaran UI components (`FButton`, `FCard`, `FTextFormField`, `FBadge`, `FAvatar`, `FDialog`, dll.).
- **Tone of Voice:** Profesional, terstruktur, akademik, tenang, bebas dari emoji dan ornamen berlebihan.
- **App Bar Policy:** Ringkas (tinggi kompak 40dp), judul halaman rata tengah dan kecil, hanya muncul saat di-scroll (tidak muncul pada posisi awal).

## Evidence on Hand

- Source code lengkap dan teruji di `lib/`.
- Seed data awal di `lib/core/database/seed/` (`seed_lecturers.dart`, `seed_students.dart`, `seed_courses.dart`, `seed_offerings.dart`, `seed_enrollments.dart`, `seed_schedules.dart`).
- Test suite komprehensif di `test/` (124 tests unit & widget, 100% pass).
- SQLite in-memory database test harness (`sqflite_common_ffi`).

## Product Principles

1. **Forui-First & Native Craft:** Utamakan komponen resmi Forui sebelum membuat custom widget. Jaga konsistensi token tema, radius, dan tipografi.
2. **Single Source of Truth:** SQLite melalui Repository adalah satu-satunya sumber data operasional di runtime. Tidak membaca seed mentah di layer UI.
3. **Fokus Dosen & Alur Ramping:** Hanya menyediakan fungsionalitas yang benar-benar dibutuhkan dosen. Tidak menambah kompleksitas atau fitur di luar cakupan tugas.
4. **Ketahanan Data (Idempotent & Persistent):** Data hasil input dosen tidak boleh hilang saat aplikasi ditutup/dibuka kembali dan tidak boleh tertimpa oleh proses seeder.

## Accessibility & Inclusion

- Responsif terhadap berbagai resolusi layar Android (termasuk layar sempit 320-360dp).
- Form dapat di-scroll (`SingleChildScrollView`) agar input field dan tombol submit tidak terpotong saat virtual keyboard aktif.
- Screen reader semantic labeling pada elemen kunci (seperti avatar profil dan detail baris dosen) untuk kompatibilitas TalkBack.

---

## 1. Ringkasan Produk

**PoDo (Portal Dosen)** adalah aplikasi mobile berbasis Flutter yang membantu dosen mengakses informasi akademik dan menjalankan aktivitas pengajaran dasar melalui satu aplikasi.

Fokus utama PoDo:
- Melihat jadwal mengajar.
- Melihat mata kuliah/kelas yang diampu.
- Mengelola daftar mahasiswa pada kelas.
- Menambahkan dan memperbarui biodata mahasiswa.
- Memasukkan serta memperbarui nilai mahasiswa berdasarkan CPMK 1 sampai CPMK 4.
- Melihat profil dosen yang sedang login.

Aplikasi dibuat untuk kebutuhan proyek/tugas perkuliahan dan demonstrasi lokal. Data disimpan pada SQLite di perangkat, bukan pada server atau layanan cloud.

## 2. Masalah dan Tujuan

### Masalah yang ingin dibantu

Dosen membutuhkan alur sederhana untuk melihat kelas yang diampu, mengetahui mahasiswa yang terdaftar, dan memasukkan nilai mahasiswa. Data demo juga harus tersedia sejak aplikasi pertama kali dijalankan agar alur aplikasi dapat langsung diperagakan.

### Tujuan produk

1. Menyediakan portal akademik sederhana yang berorientasi pada kebutuhan dosen.
2. Memudahkan dosen menemukan jadwal dan mata kuliah yang diampu.
3. Menyediakan alur input nilai yang terikat pada mata kuliah/kelas dan mahasiswa yang benar.
4. Memungkinkan dosen menambah data mahasiswa, mata kuliah, kelas, dan pendaftaran mahasiswa.
5. Menyediakan data awal melalui seed yang dimasukkan ke SQLite secara otomatis.
6. Memastikan data yang dibuat atau diubah melalui aplikasi tetap tersimpan setelah aplikasi ditutup dan dibuka kembali.

### Bukan tujuan produk

- Menggantikan sistem informasi akademik kampus secara penuh.
- Menyediakan sinkronisasi server, multi-device, atau kolaborasi real-time.
- Menyediakan autentikasi produksi yang aman.
- Mengelola seluruh proses akademik seperti KRS, presensi, pembayaran, wisuda, atau administrasi kampus.
- Menentukan bobot CPMK, nilai akhir, atau konversi huruf mutu tanpa aturan resmi dari pemilik proyek.
- Menyediakan role administrator akademik yang terpisah, kecuali diminta kemudian.

## 3. Pengguna dan Hak Akses

### Pengguna utama: Dosen

Dosen adalah satu-satunya jenis pengguna yang menjadi fokus versi proyek ini.

Dosen dapat:
- Login menggunakan kredensial demo yang ditanam di source code.
- Melihat dashboard.
- Melihat jadwal mengajar miliknya.
- Melihat mata kuliah/kelas yang diampu.
- Membuat offering/kelas untuk mata kuliah.
- Membuat master mata kuliah baru jika belum tersedia.
- Melihat mahasiswa yang terdaftar pada kelas.
- Menambahkan mahasiswa yang sudah ada ke kelas.
- Menambahkan atau memperbarui biodata mahasiswa.
- Menginput dan memperbarui nilai CPMK 1–4.
- Melihat profil dosen aktif dan logout.

**Batasan penting:** Karena aplikasi tidak memiliki role administrator pada versi ini, fitur tambah master mata kuliah tersedia bagi dosen untuk kebutuhan demo. Dalam sistem kampus sesungguhnya, pengelolaan master mata kuliah biasanya dapat dibatasi kepada administrator akademik.

## 4. Navigasi dan Informasi Arsitektur Produk

### Bottom navigation utama

Bottom navigation memiliki empat item dengan urutan tetap:
1. **Home** — dashboard dan pintasan aktivitas.
2. **Jadwal** — jadwal mengajar dosen aktif.
3. **Mata Kuliah** — daftar offering/kelas dan akses pengelolaan mahasiswa serta nilai.
4. **Akun** — profil dosen aktif dan logout.

Daftar mahasiswa dan form biodata diakses dari Home. Input nilai diakses melalui Mata Kuliah, bukan melalui tab Nilai tersendiri.

### Daftar screen

Splash Screen tidak dihitung sebagai screen fungsional. Target produk terdiri dari delapan screen fungsional.

| Screen | Tujuan | Aksi utama |
|---|---|---|
| Splash | Menampilkan identitas PoDo sebelum login | Melanjutkan ke Login |
| Login | Mengautentikasi dosen demo | Masuk ke aplikasi |
| Home | Menjadi titik awal aktivitas dosen | Membuka biodata, input nilai, dan informasi mahasiswa |
| Jadwal | Menampilkan jadwal mengajar dosen aktif | Memfilter jadwal berdasarkan hari |
| Akun/Profil | Menampilkan data dosen aktif | Melihat profil dan logout |
| Daftar Mahasiswa | Menampilkan data mahasiswa yang tersimpan | Mencari dan memilih mahasiswa |
| Form Biodata Mahasiswa | Menambah atau mengubah data mahasiswa | Menyimpan biodata |
| Daftar Mata Kuliah | Menampilkan kelas yang diampu dosen aktif | Membuka detail atau menambah mata kuliah/kelas |
| Detail Mata Kuliah | Menampilkan informasi kelas dan mahasiswa terdaftar | Menambah mahasiswa atau memilih mahasiswa untuk input nilai |

**Grade Input Bottom Sheet** adalah overlay, bukan screen atau item navigasi. Overlay ini dibuka dari Detail Mata Kuliah setelah dosen memilih seorang mahasiswa.

## 5. Alur Penggunaan Utama

### 5.1 Alur awal dan login

1. Pengguna membuka aplikasi.
2. Splash menampilkan branding PoDo.
3. Aplikasi membuka Login.
4. Pengguna memasukkan email/username dan password demo.
5. Sistem memvalidasi kredensial melalui mekanisme hardcoded.
6. Kredensial yang valid dipetakan ke `lecturer_id`.
7. Pengguna masuk ke Home dan aplikasi menggunakan identitas dosen tersebut untuk mengambil data profil, jadwal, dan mata kuliah.

Kredensial demo bukan mekanisme keamanan produksi dan password tidak disimpan di SQLite.

### 5.2 Alur melihat jadwal

1. Dosen membuka tab Jadwal.
2. Aplikasi menampilkan jadwal milik dosen yang sedang login.
3. Dosen memilih filter hari.
4. Aplikasi menampilkan mata kuliah, kelas, ruangan, serta jam mulai dan selesai untuk hari tersebut.
5. Jadwal diurutkan berdasarkan waktu mulai.

### 5.3 Alur mengelola mata kuliah/kelas

1. Dosen membuka tab Mata Kuliah.
2. Aplikasi menampilkan offering/kelas yang terkait dengan dosen aktif.
3. Dosen dapat memilih offering untuk membuka Detail Mata Kuliah.
4. Dosen juga dapat memilih aksi Tambah Mata Kuliah/Kelas.
5. Dosen memilih master mata kuliah yang sudah tersedia, atau membuat master baru jika belum ada.
6. Dosen mengisi informasi kelas, tahun akademik, dan semester.
7. Sistem menyimpan master baru (jika dibuat) dan offering ke SQLite.
8. Daftar Mata Kuliah diperbarui.

Istilah:
- **Course** adalah master mata kuliah, misalnya Pemrograman Mobile.
- **Course offering** adalah penyelenggaraan mata kuliah oleh dosen untuk kelas dan periode tertentu, misalnya Pemrograman Mobile kelas A pada semester tertentu.

Membuat offering tidak otomatis mendaftarkan mahasiswa ke kelas tersebut.

### 5.4 Alur melihat detail dan menambah mahasiswa

1. Dosen memilih offering dari Daftar Mata Kuliah.
2. Aplikasi membuka Detail Mata Kuliah.
3. Aplikasi menampilkan informasi mata kuliah/kelas, dosen pengampu, periode akademik, jadwal/ruangan jika tersedia, dan daftar mahasiswa.
4. Daftar mahasiswa berasal dari relasi pendaftaran kelas, bukan dari daftar nilai.
5. Dosen memilih Tambah Mahasiswa.
6. Aplikasi menampilkan mahasiswa yang sudah ada di database tetapi belum terdaftar pada offering tersebut.
7. Dosen mencari dan memilih satu atau beberapa mahasiswa.
8. Sistem menyimpan relasi pendaftaran ke SQLite.
9. Daftar mahasiswa pada Detail Mata Kuliah diperbarui.

Mahasiswa yang sudah terdaftar tidak boleh ditambahkan lagi ke offering yang sama. Menambahkan mahasiswa ke kelas tidak otomatis membuat record nilai.

### 5.5 Alur biodata mahasiswa

1. Dosen membuka quick action Isi Biodata Mahasiswa dari Home.
2. Aplikasi membuka Form Biodata Mahasiswa.
3. Dosen mengisi nama lengkap, NIM, program studi, jurusan, nomor telepon, dan alamat lengkap.
4. Sistem memvalidasi field wajib dan keunikan NIM.
5. Sistem menyimpan data melalui repository ke SQLite.
6. Data tersedia pada Daftar Mahasiswa dan dapat dipilih saat menambahkan mahasiswa ke offering.

Form yang sama dapat digunakan untuk memperbarui biodata mahasiswa yang sudah ada.

### 5.6 Alur input dan pembaruan nilai

1. Dosen membuka tab Mata Kuliah atau quick action Input Nilai dari Home.
2. Aplikasi menampilkan Daftar Mata Kuliah.
3. Dosen memilih offering.
4. Aplikasi membuka Detail Mata Kuliah beserta daftar mahasiswa.
5. Dosen memilih seorang mahasiswa.
6. Aplikasi menampilkan Grade Input Bottom Sheet dengan identitas mahasiswa dan mata kuliah/kelas.
7. Dosen mengisi CPMK 1, CPMK 2, CPMK 3, dan CPMK 4.
8. Sistem memvalidasi nilai setiap CPMK pada rentang 0–100.
9. Dosen menyimpan nilai.
10. Sistem membuat record nilai jika belum ada, atau memperbarui record yang sudah ada.
11. Bottom sheet ditutup dan status nilai mahasiswa diperbarui di Detail Mata Kuliah.

Jika mahasiswa sudah memiliki nilai, form harus menampilkan nilai yang tersimpan agar dosen dapat memperbaruinya.

**Tidak ada komponen UTS, UAS, kehadiran, atau tugas dalam form nilai versi ini.**

### 5.7 Alur profil dan logout

1. Dosen membuka tab Akun.
2. Aplikasi mengambil profil berdasarkan `lecturer_id` sesi.
3. Aplikasi menampilkan informasi dosen dan ringkasan akademik yang datanya tersedia.
4. Dosen menekan Keluar.
5. Sistem menghapus sesi lokal dan kembali ke Login.

## 6. Kebutuhan Fungsional

| ID | Kebutuhan | Kriteria hasil |
|---|---|---|
| FR-01 | Splash | Branding PoDo tampil dan pengguna diarahkan ke Login. |
| FR-02 | Login demo | Kredensial valid mengarahkan ke Home dan mengidentifikasi dosen aktif; kredensial salah menampilkan pesan kesalahan. |
| FR-03 | Dashboard | Home menampilkan sapaan dosen aktif dan quick action yang berfungsi. |
| FR-04 | Jadwal | Jadwal hanya menampilkan jadwal dosen aktif dan dapat difilter berdasarkan hari. |
| FR-05 | Profil dosen | Profil diambil dari database berdasarkan dosen aktif, bukan data mahasiswa atau teks statis. |
| FR-06 | Daftar mahasiswa | Data mahasiswa berasal dari SQLite dan dapat dicari berdasarkan nama/NIM. |
| FR-07 | Biodata mahasiswa | Dosen dapat menambah dan memperbarui biodata; NIM harus unik. |
| FR-08 | Daftar mata kuliah | Menampilkan offering milik dosen aktif. |
| FR-09 | Tambah mata kuliah/kelas | Dosen dapat memilih master course atau membuat master baru, lalu membuat offering. |
| FR-10 | Detail mata kuliah | Menampilkan detail offering dan mahasiswa yang terdaftar, termasuk yang belum dinilai. |
| FR-11 | Tambah mahasiswa ke kelas | Dosen dapat mendaftarkan mahasiswa yang belum terdaftar ke offering. Duplikasi harus dicegah. |
| FR-12 | Input nilai CPMK | Dosen dapat menyimpan empat komponen CPMK untuk mahasiswa pada offering yang dipilih. |
| FR-13 | Perbarui nilai | Nilai tersimpan dapat dimuat kembali dan diperbarui. |
| FR-14 | Status nilai | Detail Mata Kuliah membedakan mahasiswa yang sudah dan belum memiliki record nilai. |
| FR-15 | Logout | Sesi lokal dihapus dan pengguna kembali ke Login. |
| FR-16 | Persistensi | Data hasil tambah/ubah tetap tersedia setelah aplikasi ditutup dan dibuka kembali. |

## 7. Data dan Aturan Bisnis

### 7.1 Sumber data

PoDo menggunakan pola:
**Hardcoded Seed Data → SQLite → Repository → UI**

- Developer menyiapkan beberapa record dosen, mahasiswa, mata kuliah, offering, enrollment, dan jadwal sebagai konstanta Dart.
- Pada inisialisasi database baru, seed dimasukkan otomatis ke SQLite.
- Setelah proses seed, seluruh tampilan dan operasi aplikasi menggunakan SQLite melalui repository.
- Form tambah/ubah menyimpan data ke SQLite.
- Seed tidak dibaca langsung oleh screen dan tidak menjadi sumber data runtime.

### 7.2 Entitas produk

| Entitas | Kegunaan |
|---|---|
| Lecturer | Identitas dan profil dosen |
| Student | Biodata mahasiswa |
| Course | Master mata kuliah |
| Course Offering | Mata kuliah yang dibuka oleh dosen untuk kelas/periode tertentu |
| Teaching Schedule | Hari, waktu, dan ruangan untuk offering |
| Course Enrollment | Relasi mahasiswa dengan offering |
| Grade | Nilai CPMK 1–4 untuk satu enrollment |

Relasi utama:
- Satu dosen dapat memiliki banyak course offering.
- Satu master mata kuliah dapat digunakan oleh banyak offering.
- Satu offering dapat memiliki beberapa jadwal.
- Satu offering dapat memiliki banyak enrollment.
- Satu mahasiswa dapat terdaftar pada banyak offering.
- Satu enrollment dapat memiliki nol atau satu record grade.

### 7.3 Aturan integritas

- NIM mahasiswa unik.
- Kode master mata kuliah unik.
- Kombinasi offering dan NIM mahasiswa unik.
- Satu enrollment hanya memiliki satu record grade yang dapat diperbarui.
- Nilai CPMK harus berada pada rentang 0–100.
- Mahasiswa yang belum memiliki grade tetap harus tampil pada daftar kelas.
- Pendaftaran mahasiswa tidak otomatis membuat grade.
- Pembuatan master course dan offering terkait harus berhasil sebagai satu operasi konsisten.
- Data yang dibuat pengguna tidak boleh ditimpa oleh proses seed berikutnya.
- Data demo harus diberi identitas yang jelas dan tidak menggunakan data pribadi nyata tanpa izin.

### 7.4 Seed dan persistensi

- Seed awal dijalankan otomatis setelah tabel database dibuat.
- Seeder harus idempotent dan menggunakan key stabil.
- Seed tidak boleh memakai strategi replace yang menimpa data pengguna.
- Penambahan seed pada versi aplikasi berikutnya harus bersifat additive dan dilacak dengan seed version/metadata.
- Perubahan struktur database ditangani melalui schema migration.
- Database tidak boleh dihapus atau dibuat ulang setiap kali aplikasi dibuka.

### 7.5 Aturan nilai

Komponen penilaian adalah CPMK 1–4. Bobot tiap CPMK, formula nilai akhir, dan konversi huruf mutu **belum ditentukan**. Sampai aturan resmi diberikan:
- Simpan dan tampilkan nilai per CPMK.
- Jangan mengarang bobot.
- Jangan menghitung nilai akhir atau huruf mutu seolah-olah resmi.

## 8. Kebutuhan UI/UX

- UI menggunakan Forui sebagai component library utama.
- Bottom navigation memiliki urutan Home, Jadwal, Mata Kuliah, Akun.
- Pemilihan komponen harus berdasarkan fungsi dan konteks interaksi, bukan hanya tampilan.
- Form nilai dibuka sebagai bottom sheet dari Detail Mata Kuliah.
- Bottom sheet harus cukup nyaman untuk empat field nilai dan tetap dapat di-scroll ketika keyboard terbuka.
- Daftar mahasiswa dan mata kuliah perlu memiliki empty state yang jelas.
- Form perlu menampilkan validasi dekat dengan field terkait.
- Operasi penyimpanan perlu memberikan feedback sukses/gagal dan mencegah submit berulang.
- Gunakan loading state saat operasi database membutuhkan waktu.
- Hindari informasi dekoratif atau statistik yang tidak memiliki sumber data.
- Detail visual mengikuti rancangan tim design; bila belum ditentukan, gunakan pola yang konsisten dan sederhana.

## 9. Kebutuhan Non-Fungsional

### Kemudahan penggunaan
- Alur input nilai harus selalu menunjukkan mata kuliah/kelas dan mahasiswa yang sedang dipilih.
- Aksi utama mudah ditemukan.
- Form dapat digunakan pada ukuran layar Android yang umum.

### Konsistensi data
- SQLite menjadi sumber data operasional tunggal.
- Semua perubahan data dilakukan melalui repository.
- Relasi database harus menjaga konsistensi antar mahasiswa, kelas, jadwal, dan nilai.

### Keandalan
- Operasi multi-tabel menggunakan transaksi.
- Error penyimpanan ditangani dan diberi pesan yang dapat dipahami.
- Seed tidak menyebabkan duplikasi atau overwrite data pengguna.

### Batasan keamanan
- Login hardcoded hanya untuk demonstrasi akademik.
- Aplikasi tidak boleh mengklaim mekanisme login ini aman untuk penggunaan produksi.
- Jangan menyimpan password demo ke database.

## 10. Di Luar Ruang Lingkup dan Keputusan yang Belum Ada

Hal berikut belum menjadi bagian dari spesifikasi final dan tidak boleh diasumsikan oleh implementer:
- Backend/API dan sinkronisasi data antarperangkat.
- Role administrator akademik.
- Pengelolaan KRS dan persetujuan pengambilan mata kuliah.
- Presensi mahasiswa.
- Bobot CPMK dan rumus nilai akhir.
- Konversi nilai angka menjadi huruf mutu.
- Ekspor PDF/Excel atau pencetakan nilai.
- Notifikasi push.
- Upload foto ke server.
- Pengelolaan pengumuman dari backend.

Jika salah satu kebutuhan tersebut diperlukan, minta keputusan pemilik produk sebelum mengimplementasikannya.

## 11. Kriteria Penerimaan Produk

Versi proyek dapat dianggap memenuhi ruang lingkup utama apabila:
- [x] Splash dan minimal tujuh screen fungsional tersedia.
- [x] Login demo dapat menerima kredensial valid dan menolak kredensial salah.
- [x] Login memetakan pengguna ke dosen yang benar.
- [x] Bottom navigation berisi Home, Jadwal, Mata Kuliah, Akun dalam urutan tersebut.
- [x] Profil menampilkan data dosen aktif dari SQLite.
- [x] Jadwal menampilkan data dosen aktif dan filter hari berfungsi.
- [x] Seed dosen, mahasiswa, mata kuliah, offering, enrollment, dan jadwal otomatis masuk ke SQLite pada instalasi awal.
- [x] Data seed tidak dimuat langsung oleh screen.
- [x] Dosen dapat menambah dan memperbarui biodata mahasiswa.
- [x] Dosen dapat menambah master mata kuliah jika diperlukan dan membuat offering/kelas.
- [x] Course Detail menampilkan mahasiswa yang terdaftar, termasuk yang belum memiliki nilai.
- [x] Dosen dapat menambahkan mahasiswa yang sudah ada ke offering.
- [x] Dosen dapat menginput dan memperbarui CPMK 1–4 melalui bottom sheet.
- [x] Validasi nilai CPMK menolak nilai di luar rentang 0–100.
- [x] Data baru dan perubahan tetap ada setelah aplikasi ditutup dan dibuka kembali.
- [x] Tidak ada duplikasi enrollment atau seed saat inisialisasi ulang.
- [x] Tidak ada nilai akhir/bobot CPMK yang dikarang.
- [ ] Laporan progress menyertakan nama project, anggota kelompok, deskripsi, dan screenshot aktual tahapan aplikasi.

## 12. Informasi yang Masih Perlu Dilengkapi

Informasi berikut belum ditetapkan dalam keputusan produk:
- Nama anggota kelompok.
- Identitas institusi dan aset logo final.
- Daftar kredensial demo dan pemetaan masing-masing ke dosen.
- Data dosen, mahasiswa, dan mata kuliah demo yang akan digunakan.
- Tahun akademik, semester, kelas, serta jadwal demo.
- Bobot CPMK dan aturan nilai akhir, jika memang diminta oleh dosen pengampu tugas.
- Detail visual final dari tim design.

Jangan mengarang informasi tersebut. Gunakan placeholder atau data demo yang secara eksplisit ditandai sebagai contoh sampai informasi final tersedia.
