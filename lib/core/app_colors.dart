import 'package:flutter/material.dart';

/// Palet warna RemedyMath — gaya neobrutalism.
///
/// Delapan warna, tanpa variasi, tanpa gradien. Nilai final; lihat
/// [UI-REFERENCE.md](UI-REFERENCE.md) §5.1.
///
/// Ciri palet ini: latar krem hangat, permukaan putih, tinta hampir
/// hitam, lalu empat warna aksen. Aksen hanya dipakai pada elemen kecil
/// seperti badge, pill, dan bar — bukan pada blok besar.
///
/// Mode gelap tidak dipergunakan. Alasannya teknis: warna aksen sangat
/// jenuh sementara tinta hampir hitam, sehingga pada latar gelap
/// bayangan tajam hilang dan kartu kehilangan bentuknya.
///
/// Token lama Material 3 indigo **sudah dihapus**, bukan dialias.
/// Lihat PLANNING.md §6 untuk daftar lengkap perubahan.
///
/// Nilai di bawah mengikuti tabel pemetaan [DESIGN-AUDIT.md] §4. Enam
/// token berubah dari palet sebelumnya; `surface` dan `radioBorder`
/// sudah sama dengan spesifikasi.
class AppColors {
  const AppColors._();

  /// Latar aplikasi — krem hangat.
  static const Color background = Color(0xFFF6F5F1);

  /// Kartu, header, track progress, tombol sekunder.
  static const Color surface = Color(0xFFFFFFFF);

  /// Semua teks, semua border, semua bayangan.
  static const Color ink = Color(0xFF1A1A1A);

  /// Logo, nav pill aktif, eyebrow, CTA utama, isi progress bar.
  ///
  /// Dipilih `#E2F16D` dan bukan `#FFEE00` (keputusan §6.1): versi kuning
  /// murni menghasilkan kesan fluorescent di layar terang.
  static const Color accentYellow = Color(0xFFE2F16D);

  /// Avatar, titik wordmark, kartu ajakan, kartu "perlu".
  static const Color accentPink = Color(0xFFFF69B4);

  /// Badge kelas, kartu IRT, kartu video, kartu pengajar.
  static const Color accentBlue = Color(0xFF70B2FF);

  /// Timer, petunjuk, kartu kunci, kartu tuntas.
  ///
  /// Token ini **tidak boleh dipakai sebagai warna teks** di mana pun:
  /// kontrasnya terhadap `background` hanya 1.20, di bawah ambang 3.0.
  /// Pakai sebagai warna latar dan biarkan teksnya `ink`.
  static const Color accentGreen = Color(0xFFA3F3B6);

  /// Border radio tidak aktif **saja**. Tidak dipakai untuk kartu.
  ///
  /// Dipertahankan (keputusan §6.6): abu-abu netral, bukan warna aksen.
  /// Menggantinya dengan tinta membuat pilihan aktif tidak terbaca.
  static const Color radioBorder = Color(0xFF767676);
}