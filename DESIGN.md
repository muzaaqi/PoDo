---
name: PoDo (Portal Dosen)
description: Portal akademik mobile dosen yang bersih, to the point, terstruktur rapi, dan playful dengan Forui
colors:
  primary: "#4338CA"
  primary-foreground: "#FFFFFF"
  neutral-bg: "#F8FAFC"
  neutral-surface: "#FFFFFF"
  neutral-border: "#E2E8F0"
  neutral-text: "#18181B"
  neutral-muted: "#64748B"
  accent-amber: "#FDE68A"
  accent-amber-fg: "#18181B"
  accent-violet: "#DDD6FE"
  accent-violet-fg: "#18181B"
  accent-sky: "#BAE6FD"
  accent-sky-fg: "#18181B"
  accent-emerald: "#A7F3D0"
  accent-emerald-fg: "#18181B"
  accent-coral: "#FECDD3"
  accent-coral-fg: "#18181B"
  accent-indigo: "#C7D2FE"
  accent-indigo-fg: "#18181B"
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
    backgroundColor: "{colors.neutral-surface}"
    textColor: "{colors.neutral-text}"
    rounded: "{rounded.lg}"
    padding: "16px 16px"
  badge-pill:
    backgroundColor: "{colors.accent-violet}"
    textColor: "{colors.accent-violet-fg}"
    rounded: "{rounded.pill}"
    padding: "4px 10px"
---

# Design System: PoDo (Portal Dosen)

## Overview

**Creative North Star: "The Playful Faculty Ledger"**

PoDo (Portal Dosen) adalah aplikasi operasional akademik untuk dosen yang memadukan ketegasan buku catatan perkuliahan (*academic ledger*) dengan sentuhan visual yang modern, ramah (*soft & approachable*), serta ceria (*playful*). Alih-alih antarmuka birokratis kampus yang kaku dan padat teks, PoDo dibangun dengan prinsip *clean, simple, to the point*, dan mudah dipindai dalam hitungan detik.

Kanvas utama didominasi warna kanvas lembut (`#F8FAFC`) dan kartu putih murni (`#FFFFFF`), memberikan panggung bagi kartu-kartu squircle lembut ber-radius 16dp dan permukaan pastel solid yang ceria tanpa border. Tipografi angka metrik dibuat percaya diri sehingga dosen langsung memahami prioritas hari itu tanpa beban kognitif berlebih.

Sistem desain ini berpijak pada komponen resmi Forui (`forui`) yang dikonfigurasi secara konsisten, mempertahankan fluiditas operasional Android asli, dan mengeliminasi ornamen dekoratif yang tidak bersumber dari data riil.

**Key Characteristics:**
- **High Scanability:** Informasi inti (jam, ruangan, kelas, nilai CPMK) langsung terlihat dalam sekali pandang.
- **Friendly Geometry:** Kartu bertepi membulat nyaman (12–16dp) dan chip berwujud pill penuh (100dp).
- **100% Solid Pastel Surfaces:** Warna pastel menggunakan nilai solid pekat (Tailwind 200), bukan tint samar atau opacity wash.
- **Borderless Pastels:** Seluruh permukaan dan komponen warna pastel bebas dari garis border/stroke di bagian manapun.
- **Unified Profile Header:** Sapaan, nama dosen, avatar, dan notifikasi menyatu dalam satu baris horisontal ringkas.
- **Zero Fluff:** Tidak ada emoji, ilustrasi berlebihan, atau teks panjang tak bermakna; setiap elemen memiliki fungsi nyata.

## Colors

Palet PoDo mengusung prinsip **80/20 Clean Canvas**: 80% permukaan adalah kanvas monokromatik netral yang bersih, dan 20% adalah aksen warna ceria yang terikat langsung pada status atau kategori operasional.

### Primary & Dark Neutral
- **Academic Indigo** (`#4338CA` Light / `#6366F1` Dark): Identitas brand utama PoDo untuk tombol aksi primer (`FButton`), tab aktif di `FBottomNavigationBar`, dan tautan interaktif (*Lihat Semua*).
- **Canvas Slate** (`#F8FAFC` Light / `#090A0F` Dark): Latar kanvas aplikasi yang tenang dan memberi kontras alami terhadap kartu.
- **Card Surface** (`#FFFFFF` Light / `#13151D` Dark): Permukaan kartu utama (`FCard`) yang bersih.
- **Charcoal Foreground** (`#18181B` Light / `#FAFAFA` Dark): Teks utama dan ikon berbobot tegas dengan kontras WCAG AAA.

### Neutral Supporting
- **Border Crisp** (`#E2E8F0` Light / `#1E2230` Dark): Garis pembatas kartu Forui, divider pemisah, dan garis input form.
- **Muted Foreground** (`#64748B` Light / `#94A3B8` Dark): Teks sekunder, label atribut, ikon pendukung, dan placeholder.

### Playful Functional Accents (100% Solid & Borderless)
Terinspirasi dari nuansa ceria modern (rujukan `references/random/playful.png`), warna aksen menggunakan warna pastel solid tanpa border dengan teks gelap tegas:
- **Warm Butter Yellow** (`#FDE68A` / Teks `#18181B`): Kartu hero jadwal mengajar hari ini, tenggat waktu, dan kartu pengingat aktif.
- **Lavender Violet** (`#DDD6FE` / Teks `#18181B`): Identitas akademik, kartu aksi Isi Biodata, badge kelas, dan kategori pengumuman akademik.
- **Fresh Mint Emerald** (`#A7F3D0` / Teks `#18181B`): Kartu aksi Input Nilai, status "Sudah Dinilai", dan empty state jadwal selesai.
- **Ice Sky Blue** (`#BAE6FD` / Teks `#18181B`): Kartu aksi Data Mahasiswa, badge SKS, dan kategori pengumuman kemahasiswaan.
- **Soft Peach Coral** (`#FECDD3` / Teks `#18181B`): Status "Belum Dinilai", indikator validasi error, dan tombol destruktif (Keluar).
- **Pastel Periwinkle Indigo** (`#C7D2FE` / Teks `#18181B`): Varian pastel dari warna brand utama.

### Named Rules
- **The Borderless Pastel Rule:** Seluruh kartu, container, squircle, atau pill badge yang menggunakan warna pastel solid **DILARANG MENGGUNAKAN BORDER DI BAGIAN MANAPUN**. Warna pastel sudah memiliki diferensiasi fisik yang cukup di atas kanvas.
- **The Zero-Alpha Rule:** Dilarang mengatur `opacity`, `alpha`, `withValues`, atau `withOpacity` untuk membuat permukaan warna pastel. Seluruh warna pastel harus solid 100% opaque (`0xFF...`).
- **The High-Contrast Foreground Rule:** Teks dan ikon di atas permukaan pastel terang di Light Mode selalu menggunakan solid dark charcoal `#18181B` (WCAG AAA), bukan teks berwarna pudar.
- **The Functional Playfulness Rule:** Warna aksen ceria HANYA digunakan untuk merepresentasikan data atau status riil (jadwal, SKS, mahasiswa, status penilaian). Dilarang menyebarkan warna-warni acak pada teks biasa atau latar belakang utama.

## Typography

**Display & Headline Font:** Roboto / System Sans (Clean, Geometric, Legible)
**Body & Label Font:** Roboto / System Sans (Tinggi keterbacaan pada ukuran kecil di layar ponsel Android)

**Character:** Tipografi lugas dan langsung pada intinya. Judul dan angka metrik tebal (*bold*) berkontras dengan teks tubuh yang ringan dan netral.

### Hierarchy
- **Display XL** (Bold, 30sp, line-height 1.2): Angka metrik statistik utama (contoh: `2 Kelas`, `6 SKS`, `5 Mahasiswa` pada StatCard).
- **Headline / Title** (Semi-bold / Bold, 20–22sp, line-height 1.25): Judul halaman saat di dalam konten (contoh: `Jadwal Mengajar`, `Daftar Mata Kuliah`, `Akun Dosen`).
- **Section Title** (Bold, 16–18sp, line-height 1.3): Judul seksi kartu atau kelompok daftar (contoh: `Menu Utama`, `Jadwal Berikutnya`, `Pengumuman Kampus`).
- **Body Regular** (Medium / Regular, 14–15sp, line-height 1.4): Teks konten, nama mata kuliah, nama mahasiswa, isi form.
- **Label / Caption** (Medium, 12–13sp, line-height 1.3): Label baris detail (NIM, Ruang, Jam), teks tab navigasi bawah, dan badge status.

### Named Rules
- **The Compact Appbar Rule:** Title pada AppBar berukuran kecil (14–15sp, Semi-bold), rata tengah (*center-aligned*), dan HANYA muncul ketika halaman di-scroll melewati batas offset 40dp. Pada posisi awal sebelum di-scroll, AppBar bersih tanpa title.
- **The Single-Row Header Rule:** Pada bagian atas layar beranda, avatar, teks sapaan "Selamat Datang,", nama dosen, dan tombol notifikasi dikomposisikan dalam satu baris horisontal ringkas setinggi ~46dp untuk menghindari tumpukan teks berulang.
- **The Big Metric Rule:** Nilai angka statistik pada `StatCard` selalu dibungkus `FittedBox` agar tidak terpotong saat dirender pada layar kompak atau bilangan panjang.

## Layout

- **Sistem Grid Mobile:** Menggunakan single-column layout adaptif berbasis `SingleChildScrollView` dan `ListView` dengan padding horizontal standar `16dp`.
- **Ritme Spasi Vertikal:**
  - Jarak antar seksi besar: `22dp` – `24dp`.
  - Jarak antar kartu dalam daftar: `10dp` – `12dp`.
  - Spasi internal kartu: `16dp`.
  - Jarak mikro antar ikon dan label: `8dp` – `10dp`.
- **Keyboard Safety:** Seluruh layar form dan modal sheet (`GradeInputBottomSheet`, `StudentBiodataFormScreen`) memiliki scroll container independen dan `viewInsets.bottom` padding agar input field tidak tertutup virtual keyboard.
- **Navigasi Utama:** Bar navigasi bawah Forui (`FBottomNavigationBar`) dengan tepat 4 tab permanen: **Home → Jadwal → Mata Kuliah → Akun**.

## Elevation & Depth

PoDo mengadopsi filosofi **Subtle Surface Contrast**:

- **Permukaan Diam (At Rest):** Kedalaman dibangun melalui kontras antara latar kanvas (`#F8FAFC`) dengan kartu putih (`#FFFFFF`) atau kartu pastel solid (`#FDE68A`, `#DDD6FE`, dll).
- **Interaksi & Sentuhan (Interactive/Tappable):** Komponen kartu aksi pastel merespons sentuhan dengan perubahan skala mikro atau efek tekan Forui `FTappable`.
- **Modal Sheet Depth:** Bottom sheet penilaian menggunakan barrier semi-transparan gelap (`#33000000`) dan rounded top corners `20dp` untuk fokus interaksi input nilai yang tegas.

## Shapes

- **Kartu Aksi Pastel:** Sudut membulat modern berukuran `16dp` (`rounded.lg`), tanpa border (*borderless*), memberikan siluet yang ramah, taktil, dan modern.
- **Kartu Kontainer Putih:** Sudut membulat `16dp` dengan border halus `#E2E8F0`.
- **Badge & Chip Status:** Menggunakan bentuk pill penuh (`rounded.pill` / radius `100dp`), borderless jika berwarna pastel.
- **Tombol Aksi (`FButton`):** Sudut membulat `10dp` – `12dp` (`rounded.md`) dengan target sentuh (*touch target*) minimal tinggi 48dp sesuai standar aksesibilitas Android.
- **Avatar Pengguna (`FAvatar`):** Lingkaran penuh (`circle`) dengan diameter 46dp di header beranda dan 64dp di halaman akun.

## Components

### 1. Buttons (`FButton`)
- **Primary:** Latar `Academic Indigo` (`#4338CA`), teks putih tebal, radius `12dp`. Dipakai untuk submit form, simpan nilai, dan aksi tambah data.
- **Destructive:** Latar merah/coral lembut atau border merah tegas untuk konfirmasi Logout.
- **Outline / Ghost:** Border `#E2E8F0` dengan teks netral untuk tombol Batal pada dialog.

### 2. Cards
- **Kartu Pastel Solid (Hero Jadwal, Menu Utama):** Latar solid pastel, borderless, padding `16dp`, radius `16dp`.
- **Kartu Kontainer Putih (Pengumuman):** Latar putih `#FFFFFF`, border halus `#E2E8F0`, padding `16dp`.
- `StatCard` memadukan ikon di kanan atas, label abu-abu di atas, dan angka metrik besar berskala otomatis (`FittedBox`).

### 3. Badges (`FBadge` & Solid Pills)
- Bentuk pill penuh tanpa border untuk chip kelas, SKS, dan kategori.
- Menggunakan tipografi tebal (w700, 11sp) dengan warna kontras tinggi `#18181B`.

### 4. Form & Text Fields (`FTextField`, `FTextFormField`)
- Kotak input dengan label di atas, border `#E2E8F0` saat diam, dan fokus jelas tanpa border berlebihan.
- Menampilkan pesan error validasi langsung di bawah input field terkait.

### 5. Dialog & Bottom Sheet (`FDialog`, `showFSheet`)
- `FDialog`: Dialog konfirmasi ringkas (seperti konfirmasi Keluar dari Akun) dengan dua tombol jelas: Batal (outline) dan Keluar (destructive).
- `GradeInputBottomSheet`: Overlay modal dari bawah untuk input 4 komponen CPMK tanpa perpindahan rute halaman.

## Do's and Don'ts

### Do:
- **Do** prioritaskan komponen Forui (`FScaffold`, `FCard`, `FButton`, `FBadge`, `FHeader.nested`, `FBottomNavigationBar`) di setiap implementasi UI.
- **Do** gunakan token warna dari `context.theme.colors` dan `context.appColors`.
- **Do** terapkan warna pastel sebagai warna pekat solid 100% tanpa opacity/alpha.
- **Do** terapkan aturan **borderless** pada semua komponen berwarna pastel.
- **Do** pastikan target sentuh tombol minimal 48x48dp.
- **Do** bungkus baris informasi detail dan avatar dengan `Semantics` yang deskriptif untuk pengguna pembaca layar (TalkBack).
- **Do** sembunyikan title pada AppBar saat halaman berada di posisi awal, dan tampilkan saat halaman di-scroll melewati 40dp.

### Don't:
- **Don't** beri border/stroke pada kartu, badge, atau squircle yang berlatar belakang pastel.
- **Don't** gunakan emoji di sembarang tempat pada antarmuka (dilarang keras).
- **Don't** meletakkan nama dosen di AppBar HomeScreen sebagai judul.
- **Don't** mengubah urutan 4 tab navigasi utama (harus tetap: Home → Jadwal → Mata Kuliah → Akun).
- **Don't** menambahkan komponen penilaian selain CPMK 1, 2, 3, dan 4 (tidak boleh ada UTS, UAS, atau kehadiran).
- **Don't** gunakan bayangan hitam pekat (*heavy drop shadows*).
- **Don't** gunakan opacity/alpha (`withValues`, `withOpacity`) untuk warna pastel.
