---
name: PoDo (Portal Dosen)
description: Portal akademik mobile dosen yang bersih, to the point, terstruktur rapi, dan playful dengan Forui
colors:
  primary: "#4338CA"
  primary-foreground: "#FFFFFF"
  neutral-bg: "#F8FAFC"
  neutral-surface: "#FFFFFF"
  neutral-border: "#E2E8F0"
  neutral-text: "#0F172A"
  neutral-muted: "#64748B"
  accent-amber: "#F59E0B"
  accent-amber-subtle: "#FEF3C7"
  accent-violet: "#8B5CF6"
  accent-violet-subtle: "#EDE9FE"
  accent-sky: "#0EA5E9"
  accent-sky-subtle: "#E0F2FE"
  accent-emerald: "#10B981"
  accent-emerald-subtle: "#D1FAE5"
  accent-coral: "#EF4444"
  accent-coral-subtle: "#FEE2E2"
typography:
  display:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "30px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 700
    lineHeight: 1.25
  title:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "18px"
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 500
    lineHeight: 1.3
rounded:
  xs: "6px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  pill: "9999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
  xl2: "32px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.primary-foreground}"
    rounded: "{rounded.md}"
    padding: "12px 20px"
  button-secondary:
    backgroundColor: "{colors.neutral-surface}"
    textColor: "{colors.neutral-text}"
    rounded: "{rounded.md}"
    padding: "12px 20px"
  card-default:
    backgroundColor: "{colors.neutral-bg}"
    textColor: "{colors.neutral-text}"
    rounded: "{rounded.lg}"
    padding: "16px 16px"
  badge-pill:
    backgroundColor: "{colors.accent-violet-subtle}"
    textColor: "{colors.accent-violet}"
    rounded: "{rounded.pill}"
    padding: "4px 10px"
---

# Design System: PoDo (Portal Dosen)

## Overview

**Creative North Star: "The Playful Faculty Ledger"**

PoDo (Portal Dosen) adalah aplikasi operasional akademik untuk dosen yang memadukan ketegasan buku catatan perkuliahan (*academic ledger*) dengan sentuhan visual yang modern, ramah (*soft & approachable*), serta ceria (*playful*). Alih-alih antarmuka birokratis kampus yang kaku dan padat teks, PoDo dibangun dengan prinsip *clean, simple, to the point*, dan mudah dipindai dalam hitungan detik.

Kanvas utama didominasi warna putih bersih dan abu-abu netral yang tenang, memberikan panggung bagi kartu-kartu ber-radius lembut (*generous squircle*) dan badge status berwarna pastel cerah. Tipografi angka metrik dibuat berukuran besar dan percaya diri (misalnya jumlah jam mengajar, total mahasiswa, SKS) sehingga dosen langsung memahami prioritas hari itu tanpa beban kognitif berlebih.

Sistem desain ini berpijak pada komponen resmi Forui (`forui`) yang dikonfigurasi secara konsisten, mempertahankan fluiditas operasional Android asli, dan mengeliminasi ornamen dekoratif yang tidak bersumber dari data riil.

**Key Characteristics:**
- **High Scanability:** Informasi inti (jam, ruangan, kelas, nilai CPMK) langsung terlihat dalam sekali pandang.
- **Friendly Geometry:** Kartu bertepi membulat nyaman (12–16dp) dan chip berwujud pill penuh (100dp).
- **Playful Tonal Accents:** Aksen warna pastel fungsional (amber, violet, sky, emerald, coral) untuk membedakan kategori dan status secara intuitif.
- **Zero Fluff:** Tidak ada emoji, ilustrasi berlebihan, atau teks panjang tak bermakna; setiap elemen memiliki fungsi nyata.

## Colors

Palet PoDo mengusung prinsip **80/20 Clean Canvas**: 80% permukaan adalah kanvas monokromatik netral yang bersih, dan 20% adalah aksen warna ceria yang terikat langsung pada status atau kategori operasional.

### Primary & Dark Neutral
- **Deep Slate** (`#0F172A`): Dipakai untuk teks judul utama, teks angka metrik display, dan tombol aksi primer (`FButton`). Memberikan kesan otoritas akademik yang solid.
- **Pure White** (`#FFFFFF`): Latar belakang utama aplikasi dan permukaan kartu (`FCard`).

### Neutral Supporting
- **Surface Muted** (`#F8FAFC`): Latar belakang sekunder untuk kontainer filter hari atau kolom input non-fokus.
- **Border Crisp** (`#E2E8F0`): Garis pembatas kartu Forui, divider pemisah, dan garis input form.
- **Muted Foreground** (`#64748B`): Teks sekunder, label atribut, ikon pendukung, dan placeholder.

### Playful Functional Accents
Terinspirasi dari nuansa ceria modern (rujukan `references/random/playful.png`), warna aksen selalu berpasangan antara teks pekat dengan kontainer lembut (*subtle tint*):
- **Warm Amber** (`#F59E0B` / Container `#FEF3C7`): Aksen jadwal mengajar hari ini, tenggat waktu, dan kartu pengingat aktif.
- **Lavender Violet** (`#8B5CF6` / Container `#EDE9FE`): Identitas akademik, badge total SKS, dan badge gelar dosen.
- **Sky Breeze** (`#0EA5E9` / Container `#E0F2FE`): Entitas mahasiswa, quick action biodata, dan navigasi aktif.
- **Fresh Emerald** (`#10B981` / Container `#D1FAE5`): Status "Sudah Dinilai", konfirmasi sukses, dan penyelesaian tugas.
- **Soft Coral** (`#EF4444` / Container `#FEE2E2`): Status "Belum Dinilai", indikator validasi error, dan tombol destruktif (Keluar).

### Named Rules
- **The Functional Playfulness Rule:** Warna aksen ceria HANYA digunakan untuk merepresentasikan data atau status riil (jadwal, SKS, mahasiswa, status penilaian). Dilarang menyebarkan warna-warni acak pada teks biasa atau latar belakang utama.
- **The Contrast Pair Rule:** Teks aksen selalu menggunakan warna jenuh di atas latar kontainer lembutnya (misal teks `#8B5CF6` di atas `#EDE9FE`), tidak pernah menempatkan teks putih di atas pastel pucat.

## Typography

**Display & Headline Font:** Roboto / System Sans (Clean, Geometric, Legible)
**Body & Label Font:** Roboto / System Sans (Tinggi keterbacaan pada ukuran kecil di layar ponsel Android)

**Character:** Tipografi lugas dan langsung pada intinya. Judul dan angka metrik tebal (*bold*) berkontras dengan teks tubuh yang ringan dan netral.

### Hierarchy
- **Display XL** (Bold, 30sp, line-height 1.2): Angka metrik statistik utama (contoh: `2 Kelas`, `6 SKS`, `5 Mahasiswa` pada StatCard).
- **Headline / Title** (Semi-bold / Bold, 20–22sp, line-height 1.25): Judul halaman saat di dalam konten (contoh: `Jadwal Mengajar`, `Daftar Mata Kuliah`, `Akun Dosen`).
- **Section Title** (Bold, 16–18sp, line-height 1.3): Judul seksi kartu atau kelompok daftar (contoh: `Ringkasan Akademik`, `Jadwal Hari Ini`).
- **Body Regular** (Medium / Regular, 14–15sp, line-height 1.4): Teks konten, nama mata kuliah, nama mahasiswa, isi form.
- **Label / Caption** (Medium, 12–13sp, line-height 1.3): Label baris detail (NIM, Ruang, Jam), teks tab navigasi bawah, dan badge status.

### Named Rules
- **The Compact Appbar Rule:** Title pada AppBar berukuran kecil (14–15sp, Semi-bold), rata tengah (*center-aligned*), dan HANYA muncul ketika halaman di-scroll melewati batas offset 40dp. Pada posisi awal sebelum di-scroll, AppBar bersih tanpa title.
- **The Big Metric Rule:** Nilai angka statistik pada `StatCard` selalu dibungkus `FittedBox` agar tidak terpotong saat dirender pada layar kompak atau bilangan panjang.

## Layout

- **Sistem Grid Mobile:** Menggunakan single-column layout adaptif berbasis `SingleChildScrollView` dan `ListView` dengan padding horizontal standar `16dp`.
- **Ritme Spasi Vertikal:**
  - Jarak antar seksi besar: `24dp` – `32dp`.
  - Jarak antar kartu dalam daftar: `10dp` – `12dp`.
  - Spasi internal kartu (`FCard`): `14dp` – `16dp`.
  - Jarak mikro antar ikon dan label: `8dp` – `10dp`.
- **Keyboard Safety:** Seluruh layar form dan modal sheet (`GradeInputBottomSheet`, `StudentBiodataFormScreen`) memiliki scroll container independen dan `viewInsets.bottom` padding agar input field tidak tertutup virtual keyboard.
- **Navigasi Utama:** Bar navigasi bawah Forui (`FBottomNavigationBar`) dengan tepat 4 tab permanen: **Home → Jadwal → Mata Kuliah → Akun**.

## Elevation & Depth

PoDo mengadopsi filosofi **Subtle Lifted**:

- **Permukaan Diam (At Rest):** Datar (*flat*) dan bersih. Kedalaman dibangun melalui garis batas Forui (`#E2E8F0`) dan kontras warna antara latar belakang kanvas (`#FFFFFF` / `#F8FAFC`) dengan kartu.
- **Interaksi & Sentuhan (Interactive/Tappable):** Kartu jadwal yang dapat ditekan menuju detail mata kuliah, kartu kelas, dan modal overlay menggunakan aksen elevasi bayangan halus (*ambient soft shadow*):
  - `box-shadow: 0 4px 12px rgba(15, 23, 42, 0.04)`
- **Modal Sheet Depth:** Bottom sheet penilaian menggunakan barrier semi-transparan gelap (`#33000000`) dan rounded top corners `20dp` untuk fokus interaksi input nilai yang tegas.

## Shapes

- **Kartu Kontainer (`FCard`):** Sudut membulat modern berukuran `14dp` – `16dp` (`rounded.lg`), memberikan siluet yang ramah (*soft*) dan tidak runcing.
- **Badge & Chip Status:** Menggunakan bentuk pill penuh (`rounded.pill` / radius `100dp`) untuk membedakan status nilai ("Sudah Dinilai", "Belum Dinilai") dan pill filter hari.
- **Tombol Aksi (`FButton`):** Sudut membulat `10dp` – `12dp` (`rounded.md`) dengan target sentuh (*touch target*) minimal tinggi 48dp sesuai standar aksesibilitas Android.
- **Avatar Pengguna (`FAvatar`):** Lingkaran penuh (`circle`) dengan diameter 64dp di halaman akun dan 40dp di daftar mahasiswa/header.

## Components

### 1. Buttons (`FButton`)
- **Primary:** Latar `Deep Slate` (`#0F172A`), teks putih tebal, radius `12dp`. Dipakai untuk submit form, simpan nilai, dan aksi tambah data.
- **Destructive:** Latar merah/coral lembut atau border merah tegas untuk konfirmasi Logout.
- **Outline / Ghost:** Border `#E2E8F0` dengan teks netral untuk tombol Batal pada dialog.

### 2. Cards (`FCard` & `StatCard`)
- Latar putih dengan border halus `#E2E8F0` dan padding `16dp`.
- `StatCard` memadukan ikon di kanan atas, label abu-abu di atas, dan angka metrik besar berskala otomatis (`FittedBox`).
- Kartu jadwal menyertakan ikon kalender/jam, label ruangan, badge kelas, serta panah navigasi (*chevron*) di sebelah kanan untuk menunjukkan affordance interaktivitas.

### 3. Badges (`FBadge`)
- Bentuk pill dengan varian warna berpasangan (misal: Hijau Emerald untuk sudah dinilai, Coral untuk belum dinilai, Violet untuk SKS).
- Digunakan sebagai penanda status ringkas yang mudah dipindai mata dosen.

### 4. Form & Text Fields (`FTextField`, `FTextFormField`)
- Kotak input dengan label di atas, border `#E2E8F0` saat diam, dan fokus jelas tanpa border berlebihan.
- Menampilkan pesan error validasi langsung di bawah input field terkait.

### 5. Dialog & Bottom Sheet (`FDialog`, `showFSheet`)
- `FDialog`: Dialog konfirmasi ringkas (seperti konfirmasi Keluar dari Akun) dengan dua tombol jelas: Batal (outline) dan Keluar (destructive).
- `GradeInputBottomSheet`: Overlay modal dari bawah untuk input 4 komponen CPMK tanpa perpindahan rute halaman.

## Do's and Don'ts

### Do:
- **Do** prioritaskan komponen Forui (`FScaffold`, `FCard`, `FButton`, `FBadge`, `FHeader.nested`, `FBottomNavigationBar`) di setiap implementasi UI.
- **Do** gunakan token warna dari `context.theme.colors` dan tipografi dari `context.theme.typography`.
- **Do** berikan affordance jelas (seperti ikon panah kanan / chevron) pada kartu yang dapat ditekan untuk navigasi.
- **Do** pastikan target sentuh tombol minimal 48x48dp.
- **Do** bungkus baris informasi detail dan avatar dengan `Semantics` yang deskriptif untuk pengguna pembaca layar (TalkBack).
- **Do** sembunyikan title pada AppBar saat halaman berada di posisi awal, dan tampilkan saat halaman di-scroll melewati 40dp.

### Don't:
- **Don't** gunakan emoji di sembarang tempat pada antarmuka (dilarang keras).
- **Don't** meletakkan nama dosen di AppBar HomeScreen sebagai judul.
- **Don't** mengubah urutan 4 tab navigasi utama (harus tetap: Home → Jadwal → Mata Kuliah → Akun).
- **Don't** menambahkan komponen penilaian selain CPMK 1, 2, 3, dan 4 (tidak boleh ada UTS, UAS, atau kehadiran).
- **Don't** membuat custom button/card dari `Container` mentah jika padanan Forui tersedia.
- **Don't** gunakan bayangan hitam pekat (*heavy drop shadows*); jaga elevasi tetap halus dan lembut (*subtle lifted*).
