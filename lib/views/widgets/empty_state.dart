import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import 'neo_card.dart';

/// Tampilan kosong: ikon, judul, penjelasan, dan aksi opsional.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 48, color: AppColors.accentBlue),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.titleMd),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink)),
          if (action != null) ...<Widget>[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
