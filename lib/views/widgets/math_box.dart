import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';

/// Kotak ekspresi matematika (font mono).
class MathBox extends StatelessWidget {
  const MathBox(this.expression, {super.key});
  final String expression;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        boxShadow: AppSizes.shadowCard,
      ),
      child: Text(
        expression,
        textAlign: TextAlign.center,
        style: AppTextStyles.mathDisplay.copyWith(fontSize: 22),
      ),
    );
  }
}
