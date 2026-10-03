import 'package:flutter/material.dart';

/// Palet warna RemedyMath — gaya neobrutalism.
///
/// Delapan warna, tanpa variasi, tanpa gradien. Nilai final; lihat
/// [UI-REFERENCE.md](UI-REFERENCE.md) §5.1.
///
/// Ciri palet ini: latar krem hangat, permukaan putih, tinta hampir
/// hitam, lalu empat warna aksen jenuh. Aksen hanya dipakai pada
/// elemen kecil seperti badge, pill, dan bar — bukan pada blok besar.
///
/// Mode gelap tidak dipergunakan. Alasannya teknis: warna aksen sangat
/// jenuh sementara tinta hampir hitam, sehingga pada latar gelap
/// bayangan tajam hilang dan kartu kehilangan bentuknya.
///
/// Token lama Material 3 indigo **sudah dihapus**, bukan dialias.
/// Lihat PLANNING.md §6 untuk daftar lengkap perubahan.
class AppColors {
  const AppColors._();

  /// Latar aplikasi — krem hangat.
  static const Color background = Color(0xFFF7F2EA);

  /// Kartu, header, track progress, tombol sekunder.
  static const Color surface = Color(0xFFFFFFFF);

  /// Semua teks, semua border, semua bayangan.
  static const Color ink = Color(0xFF070707);

  /// Logo, nav pill aktif, eyebrow, CTA utama, isi progress bar.
  static const Color accentYellow = Color(0xFFFDE300);

  /// Avatar, titik wordmark, kartu ajakan, kartu "perlu".
  static const Color accentPink = Color(0xFFF77ACF);

  /// Badge kelas, kartu IRT, kartu video, kartu pengajar.
  static const Color accentBlue = Color(0xFF69A9FE);

  /// Timer, petunjuk, kartu kunci, kartu tuntas.
  static const Color accentGreen = Color(0xFF00E990);

  /// Border radio tidak aktif **saja**. Tidak dipakai untuk kartu.
  static const Color radioBorder = Color(0xFF767676);
}