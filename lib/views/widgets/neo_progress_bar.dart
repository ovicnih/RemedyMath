import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';

/// Progress bar gaya neobrutalism.
///
/// Bentuknya persis seperti desain: **track putih radius penuh + border 3
/// px**, lalu **isi `#E2F16D` bersudut siku-siku + border 3 px**. Isi
/// didorong 3 px dari tepi track supaya border track tetap terlihat di
/// sekeliling isi.
///
/// `LinearProgressIndicator` Material tidak punya varian "track penuh +
/// isi siku-siku berborder" seperti ini, jadi diimplementasikan manual.
///
/// Spesifikasi asal: `UI-REFERENCE.md` §4.1 item 3, §4.2 item 2, dan
/// §4.3 item 3.
///
/// [value] dalam rentang 0..1. Nilai di luar itu di-clamp, jadi data IRT
/// yang sedikit meleset tidak akan membuat bar kosong atau meluber.
class NeoProgressBar extends StatelessWidget {
  const NeoProgressBar({
    super.key,
    required this.value,
    this.height = 16,
    this.width = double.infinity,
    this.color = AppColors.accentYellow,
    this.trackColor = AppColors.surface,
  });

  /// Proporsi terisi, 0..1. Akan di-clamp, dan `NaN` atau `null`
  /// dianggap 0 supaya data yang belum tersedia tidak membuat bar kosong
  /// atau meluber.
  final double? value;

  /// Tinggi track. Desain memakai 16 px; kartu theta §4.3 memakai 20 px.
  final double height;

  /// Lebar track. Default [double.infinity] supaya mengikuti lebar parent.
  final double width;

  /// Warna isi. Default kuning — satu-satunya warna yang dipakai desain
  /// untuk isi progress bar.
  final Color color;

  /// Warna track. Default putih.
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final double raw = value ?? 0;
    final double fraction = raw.isNaN ? 0 : raw.clamp(0.0, 1.0);
    final double inset = AppSizes.borderThick;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: AppSizes.radius(AppSizes.radiusPill),
          border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
        ),
        child: Padding(
          // Inset 3 px: isi tidak boleh menyentuh border track.
          padding: EdgeInsets.all(inset),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: fraction,
              child: DecoratedBox(
                // Isi siku-siku, berbeda dari track yang radius penuh.
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: AppColors.ink, width: inset),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
