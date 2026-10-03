import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Token bentuk, border, bayangan, dan spasi untuk gaya neobrutalism.
///
/// Nilai diambil dari [UI-REFERENCE.md](UI-REFERENCE.md) §5.3. Ciri
/// neobrutalism: border tebal, bayangan tajam tanpa blur, dan radius kecil.
///
/// Bayangan selalu memakai warna tinta ([AppColors.ink]) dan selalu
/// `blurRadius: 0` serta `spreadRadius: 0` — tidak pernah ada bayangan
/// lembut. Warna bayangan tidak boleh didefinisikan di luar
/// `app_colors.dart` (TASK 2.5).
class AppSizes {
  const AppSizes._();

  // --- Radius -------------------------------------------------------------

  /// Sudut kartu. Semua kartu memakai nilai ini.
  static const double radiusCard = 10;

  /// Sudut chip: eyebrow, badge kelas, badge huruf opsi.
  static const double radiusChip = 8;

  /// Sudut penuh untuk nav pill, progress track, dan avatar.
  static const double radiusPill = 999;

  /// Tanpa pembulatan sama sekali: isi progress bar, header, footer.
  static const double radiusSquare = 0;

  // --- Border -------------------------------------------------------------

  /// Border tebal: kartu, tombol, logo, avatar, progress track.
  static const double borderThick = 3;

  /// Border tipis: eyebrow, badge kelas, badge huruf, kartu poin kunci.
  static const double borderThin = 2;

  /// Border hairline: radio tidak aktif saja.
  static const double borderHairline = 1;

  // --- Bayangan ------------------------------------------------------------

  /// Offset bayangan standar untuk kartu dan tombol.
  static const Offset shadowOffset = Offset(4, 4);

  /// Offset bayangan logo.
  static const Offset shadowLogo = Offset(3, 3);

  /// Offset bayangan slot ilustrasi.
  static const Offset shadowArt = Offset(5, 5);

  /// Neobrutalism tidak pernah memakai blur.
  static const double shadowBlur = 0;

  /// Neobrutalism tidak pernah memakai spread.
  static const double shadowSpread = 0;

  // --- Spasi --------------------------------------------------------------

  /// Jarak antar-elemen kecil.
  static const double spaceXs = 4;

  /// Jarak di dalam chip.
  static const double spaceSm = 8;

  /// Jarak di dalam kartu kecil.
  static const double spaceMd = 12;

  /// Jarak antar-kolom, padding kartu sedang.
  static const double spaceLg = 16;

  /// Padding kartu besar.
  static const double spaceXl = 24;

  // --- Helper ---------------------------------------------------------------

  /// Bayangan neobrutalism standar untuk kartu dan tombol.
  ///
  /// [offset] boleh dioverride untuk bayangan yang lebih dekat seperti
  /// logo ([shadowLogo]) atau ilustrasi ([shadowArt]).
  static List<BoxShadow> shadow({Offset? offset}) => <BoxShadow>[
        BoxShadow(
          color: AppColors.ink,
          offset: offset ?? shadowOffset,
          blurRadius: shadowBlur,
          spreadRadius: shadowSpread,
        ),
      ];

  /// Bayangan Offset(4, 4) — bentuk default.
  static List<BoxShadow> get shadowCard => shadow();

  /// Bayangan Offset(3, 3) untuk logo.
  static List<BoxShadow> get shadowLogoOffset => shadow(offset: shadowLogo);

  /// Bayangan Offset(5, 5) untuk slot ilustrasi.
  static List<BoxShadow> get shadowArtOffset => shadow(offset: shadowArt);

  /// Sudut dengan nilai yang diminta, untuk dipakai pada
  /// `BorderRadius.circular`.
  static BorderRadius radius(double value) => BorderRadius.circular(value);
}