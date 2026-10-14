import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';

/// Label kecil untuk pengategorian konten, gaya neobrutalism.
///
/// Bentuk: bg kuning, radius 8, border 2 px, teks 12 w900, `letterSpacing`
/// 0.30. Token yang dipakai: [AppTextStyles.eyebrow], [AppSizes.radiusChip],
/// [AppSizes.borderThin].
///
/// Teks otomatis jadi huruf kapital karena semua pemakaiannya di desain
/// memakai kapital (`DASHBOARD SISWA`, `ANALISIS DIAGNOSTIK`,
/// `PENALARAN ALJABAR`).
///
/// Spesifikasi asal: `UI-REFERENCE.md` §4.1 item 2, §4.2 item 1 dan 3,
/// §4.3 item 1, dan §4.4 item 1.
class EyebrowLabel extends StatelessWidget {
  const EyebrowLabel({
    super.key,
    required this.label,
    this.color = AppColors.accentYellow,
    this.icon,
    this.uppercase = true,
  });

  /// Teks label. Tidak perlu menulis kapital manual — widget ini
  /// menyediakan [uppercase] kalau=false.
  final String label;

  /// Warna latar. Default kuning; semua pemakaian di desain begitu.
  final Color color;

  /// Ikon opsional di kiri label. Tidak dipakai pada eyebrow di desain,
  /// tapi disediakan agar token tidak perlu di-hardcode di halaman.
  final IconData? icon;

  /// Kalau `false`, teks dipakai apa adanya (tanpa `toUpperCase`).
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppSizes.radius(AppSizes.radiusChip),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: AppColors.ink),
            const SizedBox(width: AppSizes.spaceXs),
          ],
          Flexible(
            child: Text(
              uppercase ? label.toUpperCase() : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.eyebrow,
            ),
          ),
        ],
      ),
    );
  }
}
