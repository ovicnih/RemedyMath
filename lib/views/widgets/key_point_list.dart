import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import '../../models/models.dart';
import 'neo_card.dart';

/// Kartu "Poin Kunci Ketuntasan" berisi daftar poin.
///
/// Bentuk sesuai desain §4.4 item 3: kartu luar **hijau** `#A3F3B6`
/// radius 10 border 3 px bayangan `Offset(4, 4)`, judul 19 w900 + ikon
/// 23 px, lalu **tiga** kartu poin **putih** radius 10 border **2** px
/// padding 12, ikon 19 px + teks 14 w700.
///
/// Menggantikan loop `Container` manual di `remedial_page.dart`, yang
/// sebelumnya tidak punya border sama sekali dan memakai radius 12.
///
/// Spesifikasi asal: `UI-REFERENCE.md` §4.4 item 3.
class KeyPointList extends StatelessWidget {
  const KeyPointList({
    super.key,
    required this.points,
    this.title = 'Poin Kunci Ketuntasan',
    this.trailing,
  });

  /// Daftar poin dari model. Boleh kosong — widget lalu menampilkan
  /// pesan kosong, bukan crash.
  final List<KeyPoint> points;

  /// Judul kartu. Ada ikon kunang-kunang di sampingnya.
  final String title;

  /// Widget opsional di kanan judul, mis. `Pill`.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.accentGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.lightbulb_rounded, size: 23, color: AppColors.ink),
              const SizedBox(width: AppSizes.spaceSm),
              Expanded(child: Text(title, style: AppTextStyles.titleMd)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),
          if (points.isEmpty)
            const Text(
              'Belum ada poin kunci untuk konsep ini.',
              style: AppTextStyles.labelMd,
            )
          else
            for (final KeyPoint k in points) ...<Widget>[
              KeyPointTile(point: k),
              if (k != points.last) const SizedBox(height: AppSizes.spaceSm),
            ],
        ],
      ),
    );
  }
}

/// Satu poin: kartu putih radius 10, border 2 px, padding 12, ikon
/// centang + judul + detail.
class KeyPointTile extends StatelessWidget {
  const KeyPointTile({super.key, required this.point});

  /// Data satu poin dari [ConceptNode.keyPoints].
  final KeyPoint point;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.check_circle_rounded, size: 19, color: AppColors.ink),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(point.title, style: AppTextStyles.labelMd),
                const SizedBox(height: AppSizes.spaceXs),
                Text(point.detail, style: AppTextStyles.labelMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
