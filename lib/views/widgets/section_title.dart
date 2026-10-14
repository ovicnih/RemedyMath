import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';

/// Judul bagian dengan aksen garis dan slot opsional di kanan.
class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
    this.trailing,
    this.icon,
    this.style,
  });
  final String title;
  final Widget? trailing;
  final IconData? icon;

  /// Gaya judul. Default [AppTextStyles.titleLg] (22 w900). Halaman yang
  /// mengikuti `UI-REFERENCE.md` §4.1 item 6 memakai [AppTextStyles.titleMd]
  /// (19 w900) agar cocok dengan ukuran judul bagian di desain.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 18, color: AppColors.accentBlue),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style ?? AppTextStyles.titleLg,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
