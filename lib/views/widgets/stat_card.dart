import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';

/// Kartu statistik: angka besar + label, gaya neobrutalism.
///
/// Menggantikan `StatTile` yang lama. Perbedaannya bukan kosmetik —
/// `StatTile` memakai radius 8 tanpa border, sedangkan desain memakai
/// radius 10 **dengan** border 3 px dan bayangan `Offset(4, 4)`.
///
/// Spesifikasi asal: `UI-REFERENCE.md` §4.1 item 5 (tiga stat card
/// Beranda) dan §4.3 item 4 (tiga stat hasil diagnosis).
///
/// ## Ukuran angka
///
/// Desain memakai dua ukuran dan menyatukannya secara eksplisit:
/// Beranda `statNumber` 28 px, hasil diagnosis `statValue` 24 px dengan
/// catatan "diseragamkan". Default widget ini `statNumber`; halaman
/// hasil diagnosis mengoper `statValue`.
///
/// Catatan: `accentGreen` **tidak boleh** jadi warna teks (kontras 1.20
/// terhadap latar). Angka dan label selalu `ink`; warna kartu tidak
/// pernah ikut mengubah warna teksnya.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.surface,
    this.valueStyle,
    this.labelStyle,
    this.icon,
  });

  /// Angka atau nilai yang ditampilkan, mis. `3`, `68%`, `−0.80`.
  final String value;

  /// Label kecil di bawah angka, mis. `Topik tuntas`.
  final String label;

  /// Warna latar kartu. Desain memakai hijau, pink, putih, dan kuning.
  final Color color;

  /// Gaya angka. Default [AppTextStyles.statNumber] (28 w900).
  final TextStyle? valueStyle;

  /// Gaya label. Default [AppTextStyles.labelSm] (13 w700).
  final TextStyle? labelStyle;

  /// Ikon opsional di atas angka. Tidak dipakai pada stat card di desain,
  /// tapi disediakan supaya halaman tidak perlu token warna sendiri.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
        boxShadow: AppSizes.shadowCard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 20, color: AppColors.ink),
            const SizedBox(height: AppSizes.spaceXs),
          ],
          FittedBox(
            // `FittedBox` + `maxLines: 1` supaya `−0.80` atau `100%` yang
            // panjang tetap muat di kartu selebar ~1/3 layar tanpa
            // memaksa kartu ikut melebar.
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: valueStyle ?? AppTextStyles.statNumber,
            ),
          ),
          const SizedBox(height: AppSizes.spaceXs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: labelStyle ?? AppTextStyles.labelSm,
          ),
        ],
      ),
    );
  }
}
