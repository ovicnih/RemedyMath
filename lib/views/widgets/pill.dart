import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';

/// Label kecil berbentuk kapsul.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.background = AppColors.accentYellow,
    this.foreground = AppColors.ink,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(icon, size: 14, color: foreground),
            ),
          // Flexible supaya `overflow: ellipsis` benar-benar bekerja saat
          // Pill dibaritkan pada Row/pages Action yang lebarnya terbatas.
          // Pada konteks tak terbatas (mis. di dalam Wrap) Pill tetap
          // memakai lebar intrinsiknya karena MainAxisSize.min.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMd
                  .copyWith(color: foreground, letterSpacing: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
