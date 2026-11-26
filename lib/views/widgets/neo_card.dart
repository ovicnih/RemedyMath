import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
class NeoCard extends StatefulWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.padding = const EdgeInsets.all(AppSizes.spaceLg),
    this.onTap,
    this.borderColor = AppColors.ink,
    this.borderWidth = AppSizes.borderThick,
    this.elevated = true,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Warna border. [AppColors.ink] adalah bentuk default; warna aksen hanya
  /// untuk menandai state, misalnya opsi jawaban yang sedang terpilih.
  final Color borderColor;

  /// Ketebalan border. Default [AppSizes.borderThick] (3 px) untuk kartu utama;
  /// gunakan [AppSizes.borderThin] (2 px) untuk kartu sekunder/terkunci.
  final double borderWidth;

  /// Kartu tanpa bayangan. Referensi memakainya untuk panel Petunjuk di
  /// Halaman2 dan panel ringkasan di Halaman3 (`UI-REFERENCE.md` §4.2, §4.3).
  final bool elevated;

  /// Border seragam untuk kartu.
  ///
  /// Dipisah dari [build] supaya lebar dan warna border punya satu tempat
  /// yang bisa diuji langsung, bukan hanya lewat piksel.
  static Border borderFor(
    Color color, {
    double width = AppSizes.borderThick,
  }) =>
      Border.all(
        color: color,
        width: width,
      );

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard> {
  bool _pressed = false;

  void _handleHighlight(bool value) {
    if (widget.onTap == null || !widget.elevated || _pressed == value) return;
    if (value) HapticFeedback.selectionClick();
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = AppSizes.radius(AppSizes.radiusCard);
    final bool reduced = MediaQuery.disableAnimationsOf(context);
    final bool pushed = _pressed && widget.onTap != null && widget.elevated;

    return Listener(
      behavior: HitTestBehavior.translucent,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: pushed ? 3.0 : 0.0),
        duration: reduced ? Duration.zero : const Duration(milliseconds: 85),
        curve: Curves.easeOut,
        child: Material(
          type: MaterialType.transparency,
          borderRadius: radius,
          // Clip hanya dibutuhkan untuk membatasi ripple. Tanpa clip,
          // `Material` tidak pernah memotong isi kartu.
          clipBehavior: widget.onTap == null ? Clip.none : Clip.antiAlias,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            onHighlightChanged: widget.onTap == null ? null : _handleHighlight,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
        builder: (_, double delta, Widget? child) => Transform.translate(
          offset: Offset(delta, delta),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: radius,
              border: NeoCard.borderFor(
                widget.borderColor,
                width: widget.borderWidth,
              ),
              boxShadow:
                  (widget.elevated && delta < 1.5) ? AppSizes.shadowCard : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
