import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';

/// Kartu dasar neobrutalism: border tinta, bayangan tajam, radius kecil.
///
/// Nilai diambil dari `UI-REFERENCE.md` §5.3: radius 10, border 3 px, bayangan
/// `Offset(4, 4)` tanpa blur dan tanpa spread.
///
/// Border kartu di referensi selalu seragam. Flutter menolak `borderRadius`
/// pada `Border` yang warna sisinya berbeda, jadi warna border harus lewat
/// [borderColor] dan tidak pernah per sisi.
///
/// Bayangan digambar oleh [DecoratedBox] luar, bukan oleh [Material] di
/// dalam. Kalau `Material` yang memegang clip membungkus `boxShadow`, bayangan
/// terpotong persis di sisi yang di-clip. Struktur sekarang memisahkannya:
/// `DecoratedBox` (border + bayangan, tanpa clip) membungkus `Material`
/// (ripple, clip hanya saat kartu punya [onTap]).
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.padding = const EdgeInsets.all(AppSizes.spaceLg),
    this.onTap,
    this.borderColor = AppColors.ink,
    this.elevated = true,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Warna border. [AppColors.ink] adalah bentuk default; warna aksen hanya
  /// untuk menandai state, misalnya opsi jawaban yang sedang terpilih.
  final Color borderColor;

  /// Kartu tanpa bayangan. Referensi memakainya untuk panel Petunjuk di
  /// Halaman2 dan panel ringkasan di Halaman3 (`UI-REFERENCE.md` §4.2, §4.3).
  final bool elevated;

  /// Border seragam untuk kartu.
  ///
  /// Dipisah dari [build] supaya lebar dan warna border punya satu tempat
  /// yang bisa diuji langsung, bukan hanya lewat piksel.
  static Border borderFor(Color color) => Border.all(
        color: color,
        width: AppSizes.borderThick,
      );

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = AppSizes.radius(AppSizes.radiusCard);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: borderFor(borderColor),
        boxShadow: elevated ? AppSizes.shadowCard : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        // Clip hanya dibutuhkan untuk membatasi ripple. Tanpa clip,
        // `Material` tidak pernah memotong isi kartu.
        clipBehavior: onTap == null ? Clip.none : Clip.antiAlias,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
