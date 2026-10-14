import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';

/// Kotak ekspresi matematika pada kartu soal.
///
/// Bentuk sesuai `UI-REFERENCE.md` §4.2 item 3: bg `#E2F16D`, radius 10,
/// border 3 px, bayangan `Offset(4, 4)`, rumus 26 w700 di tengah.
class MathBox extends StatelessWidget {
  const MathBox(this.expression, {super.key});
  final String expression;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceLg,
        vertical: AppSizes.spaceXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentYellow,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
        boxShadow: AppSizes.shadowCard,
      ),
      child: Text(
        expression,
        textAlign: TextAlign.center,
        style: AppTextStyles.mathFormula,
      ),
    );
  }
}
