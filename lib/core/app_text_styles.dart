import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Skala tipografi RemedyMath. Font monospace dipakai untuk ekspresi
/// matematika agar sejajar dengan tampilan rumus pada desain.
class AppTextStyles {
  const AppTextStyles._();

  static const String sans = 'Roboto';
  static const List<String> monoFallback = <String>[
    'JetBrains Mono',
    'Courier New',
    'monospace',
  ];

  static const TextStyle displayLg = TextStyle(
    fontSize: 32,
    height: 1.22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLg = TextStyle(
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMd = TextStyle(
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMd = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSm = TextStyle(
    fontSize: 13.5,
    height: 1.45,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: 16,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 14,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 12.5,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle labelMd = TextStyle(
    fontSize: 11.5,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppColors.textMuted,
  );

  static const TextStyle mathDisplay = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: monoFallback,
    fontSize: 18,
    height: 1.55,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    color: AppColors.primaryDeep,
  );

  static const TextStyle mathInline = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: monoFallback,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle monoNumeric = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: monoFallback,
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
