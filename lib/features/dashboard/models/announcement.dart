class Announcement {
  final String id;
  final String title;
  final String date;
  final String category;
  final String summary;

  const Announcement({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.summary,
  });

  static const List<Announcement> demoAnnouncements = [
    Announcement(
      id: 'ANN001',
      title: 'Batas Akhir Penginputan Nilai CPMK Semester Ganjil',
      date: '10 Nov 2026',
      category: 'Akademik',
      summary:
          'Seluruh dosen diimbau menyelesaikan pengisian nilai CPMK 1-4 sebelum periode evaluasi ditutup.',
    ),
    Announcement(
      id: 'ANN002',
      title: 'Workshop Penguatan Asesmen Pembelajaran OBE',
      date: '14 Nov 2026',
      category: 'Kegiatan',
      summary:
          'Pelatihan pemanfaatan sistem portal dosen untuk evaluasi kurikulum berbasis outcome.',
    ),
    Announcement(
      id: 'ANN003',
      title: 'Sinkronisasi Jadwal Perkuliahan & Penggunaan Lab',
      date: '18 Nov 2026',
      category: 'Pengumuman',
      summary:
          'Pembaruan alokasi ruang perkuliahan dan laboratorium terintegrasi dengan jadwal semester aktif.',
    ),
  ];
}
