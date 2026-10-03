import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Skala tipografi RemedyMath — gaya neobrutalism.
///
/// Font **Arial** dengan fallback berurutan `Helvetica Neue` lalu
/// `sans-serif`. Hanya tiga weight yang dipakai: **w900** (display,
/// judul, tombol, angka), **w700** (label, caption, meta), dan
/// **w500** (paragraf). Neobrutalism tidak memakai font tipis.
///
/// Rumus matematika memakai **font yang sama dengan weight 700**, bukan
/// font monospace terpisah — lihat PLANNING.md §7.
///
/// ## Peringatan: Arial tidak ada di Android stock
///
/// Android stock memakai Roboto. Kalau `fontFamily: 'Arial'` tidak
/// di-bundle, Android akan berjalan ke fallback pertama yang tersedia.
/// Aplikasi tetap terbaca, hanya tampilannya bukan Arial.
///
/// Keputusan penanganan font ada di [TODO.md](TODO.md) — font Android
/// belum diputuskan. Lihat PLANNING.md §7 untuk detail.
class AppTextStyles {
  const AppTextStyles._();

  /// Font utama. Di Android tanpa bundling, ini jatuh ke fallback.
  static const String sans = 'Arial';

  /// Fallback berurutan. Dicoba satu per satu, per-glyph, sesuai
  /// perilaku `TextStyle.fontFamilyFallback` di Flutter.
  static const List<String> fallback = <String>[
    'Helvetica Neue',
    'sans-serif',
  ];

  // --- Display ------------------------------------------------------------

  /// Sapaan beranda, judul halaman.
  static const TextStyle displayLg = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 34,
    height: 1.15,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  /// Skor theta besar, rumus hero.
  static const TextStyle displayNum = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 40,
    height: 1.16,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  // --- Matematika ---------------------------------------------------------

  /// Rumus besar kartu video.
  static const TextStyle mathDisplay = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 40,
    height: 1.11,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  /// Rumus di kartu soal.
  static const TextStyle mathFormula = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 26,
    height: 1.36,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  /// Rumus pola keliru atau benar.
  static const TextStyle mathInline = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 18,
    height: 1.56,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  // --- Judul --------------------------------------------------------------

  /// Judul kartu, "Skor kemampuan".
  static const TextStyle titleLg = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 22,
    height: 1.42,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  /// Judul bagian, judul kartu besar.
  static const TextStyle titleMd = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 19,
    height: 1.47,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  /// Judul langkah.
  static const TextStyle titleSm = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 17,
    height: 1.65,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  // --- Angka stat ---------------------------------------------------------

  /// Angka stat card.
  static const TextStyle statNumber = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 28,
    height: 1.28,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  /// Angka stat card yang diseragamkan ukurannya.
  static const TextStyle statValue = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  // --- Paragraf -----------------------------------------------------------

  /// Deskripsi utama.
  static const TextStyle bodyLg = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 16,
    height: 1.64,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  );

  /// Deskripsi kartu, paragraf.
  static const TextStyle bodyMd = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 15,
    height: 1.68,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  );

  // --- Label --------------------------------------------------------------

  /// Teks opsi, label tombol.
  static const TextStyle labelStrong = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 15,
    height: 1.58,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  /// Caption meta, poin kunci.
  static const TextStyle labelMd = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 14,
    height: 1.50,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  /// Caption kecil, sub-judul.
  static const TextStyle labelSm = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 13,
    height: 1.53,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  /// Eyebrow uppercase. Satu-satunya token dengan `letterSpacing`.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.30,
    color: AppColors.ink,
  );

  /// Caption terkecil.
  static const TextStyle caption = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    fontSize: 11,
    height: 1.38,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
}