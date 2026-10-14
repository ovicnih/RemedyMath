import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remedy_math/core/app_colors.dart';
import 'package:remedy_math/core/app_text_styles.dart';

/// Relatif luminans linier satu kanal warna 8-bit.
///
/// Rumus WCAG 2.1: kanal sRGB dinormalisasi ke rentang 0.0-1.0, lalu
/// `c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ^ 2.4`.
///
/// Catatan: `Color.r` di Flutter 3.27 mengembalikan `double` 0.0-1.0,
/// bukan `int` 0-255. Itu sebabnya kanal dikali 255 lebih dulu.
double _channelLuminance(double normalized) {
  final double c = normalized;
  return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

/// Relatif luminans total satu warna, rumus WCAG 2.1.
///
/// Nilai 0.0 untuk hitam, 1.0 untuk putih.
double relativeLuminance(Color color) {
  return 0.2126 * _channelLuminance(color.r) +
      0.7152 * _channelLuminance(color.g) +
      0.0722 * _channelLuminance(color.b);
}

/// Rasio kontras WCAG 2.1 antara dua warna.
///
/// Nilainya 1.0 kalau kedua warna identik, dan tidak pernah di bawah 1.0.
/// Ambang: 4.5 untuk teks normal, 3.0 untuk teks besar dan untuk
/// komponen UI seperti border ikon.
double contrastRatio(Color a, Color b) {
  final double la = relativeLuminance(a);
  final double lb = relativeLuminance(b);
  final double lighter = math.max(la, lb);
  final double darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Warna sebagai `#RRGGBB` untuk pesan kegagalan.
String _hex(Color color) {
  String channel(double normalized) =>
      (normalized * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#${channel(color.r)}${channel(color.g)}${channel(color.b)}';
}

/// Semua token warna aksen.
const List<Color> _accents = <Color>[
  AppColors.accentYellow,
  AppColors.accentBlue,
  AppColors.accentPink,
  AppColors.accentGreen,
];

/// Semua latar yang boleh dipakai sebagai latar teks.
const List<Color> _surfaces = <Color>[
  AppColors.background,
  AppColors.surface,
  AppColors.accentYellow,
  AppColors.accentBlue,
  AppColors.accentPink,
  AppColors.accentGreen,
];

/// Semua token tipografi. Dicek satu per satu supaya tidak ada token
/// baru yang lolos tanpa diperiksa.
final List<TextStyle> _tokens = <TextStyle>[
  AppTextStyles.displayLg,
  AppTextStyles.displayNum,
  AppTextStyles.mathDisplay,
  AppTextStyles.mathFormula,
  AppTextStyles.mathInline,
  AppTextStyles.titleLg,
  AppTextStyles.titleMd,
  AppTextStyles.titleSm,
  AppTextStyles.statNumber,
  AppTextStyles.statValue,
  AppTextStyles.bodyLg,
  AppTextStyles.bodyMd,
  AppTextStyles.labelStrong,
  AppTextStyles.labelMd,
  AppTextStyles.labelSm,
  AppTextStyles.eyebrow,
  AppTextStyles.caption,
];

void main() {
  group('relativeLuminance', () {
    test('batas ekstrem 0 dan 1', () {
      expect(relativeLuminance(const Color(0xFF000000)), closeTo(0.0, 1e-9));
      expect(relativeLuminance(const Color(0xFFFFFFFF)), closeTo(1.0, 1e-9));
    });

    test('warna sama dengan dirinya sendiri menghasilkan rasio 1', () {
      expect(contrastRatio(AppColors.ink, AppColors.ink), closeTo(1.0, 1e-9));
    });

    test('black dan white menghasilkan rasio 21', () {
      expect(
        contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21.0, 0.01),
      );
    });
  });

  group('kontras palet neobrutalism', () {
    test('tinta di atas setiap latar lolos ambang AA 4.5', () {
      for (final Color bg in _surfaces) {
        expect(
          contrastRatio(AppColors.ink, bg),
          greaterThanOrEqualTo(4.5),
          reason: 'teks tinta di atas ${_hex(bg)} harus mencapai AA 4.5, '
              'sekarang ${contrastRatio(AppColors.ink, bg).toStringAsFixed(2)}',
        );
      }
    });

    test('setiap aksen punya kontras <= 3.0 di atas background', () {
      // Pengaman: aksen tidak boleh masuk ke warna teks. Kalau palet
      // diganti ke warna yang lebih gelap, test ini akan gagal.
      for (final Color accent in _accents) {
        expect(
          contrastRatio(accent, AppColors.background),
          lessThanOrEqualTo(3.0),
          reason: 'aksen ${_hex(accent)} tidak boleh jadi warna teks, '
              'kontrasnya ${contrastRatio(accent, AppColors.background).toStringAsFixed(2)}',
        );
      }
    });

    test('radioBorder minimal 3.0 terhadap surface', () {
      // Radio mati harus tetap terlihat. Tanpa ini opsi jawaban tidak
      // bisa dibedakan sebelum dipilih.
      expect(
        contrastRatio(AppColors.radioBorder, AppColors.surface),
        greaterThanOrEqualTo(3.0),
      );
    });
  });

  group('token AppTextStyles', () {
    test('semua token memakai warna tinta', () {
      for (final TextStyle style in _tokens) {
        expect(
          style.color,
          AppColors.ink,
          reason: 'token ukuran ${style.fontSize} memakai '
              '${_hex(style.color ?? const Color(0x00000000))}, harus tinta',
        );
      }
    });

    test('tidak ada token yang memakai warna aksen', () {
      for (final TextStyle style in _tokens) {
        expect(
          _accents.contains(style.color),
          isFalse,
          reason: 'aksen tidak boleh jadi warna teks',
        );
      }
    });

    test('setiap token punya ukuran font yang eksplisit', () {
      for (final TextStyle style in _tokens) {
        expect(style.fontSize, isNotNull,
            reason: 'token tanpa fontSize akan memakai ukuran default tema');
      }
    });
  });
}
