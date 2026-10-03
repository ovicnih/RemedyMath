import 'package:flutter/material.dart';

/// Palet warna RemedyMath (mengacu pada DESIGN.md).
class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);
  static const Color surfaceTint = Color(0xFFE6FBF1);
  static const Color dangerSurface = Color(0xFFFFEDEA);

  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryDeep = Color(0xFF00236F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondaryStrong = Color(0xFF0058BE);
  static const Color secondaryContainer = Color(0xFFDCE1FF);
  static const Color onSecondaryContainer = Color(0xFF00236F);

  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color success = Color(0xFF00875A);
  static const Color successContainer = Color(0xFFCFF3E3);
  static const Color onSuccessContainer = Color(0xFF00311F);

  static const Color danger = Color(0xFFBA1A1A);
  static const Color dangerContainer = Color(0xFFFFDAD6);
  static const Color onDangerContainer = Color(0xFF93000A);

  static const Color textPrimary = Color(0xFF131B2E);
  static const Color textSecondary = Color(0xFF444651);
  static const Color textMuted = Color(0xFF757682);
  static const Color border = Color(0xFFC5C5D3);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF14295F), Color(0xFF1E3A8A)],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF1E3A8A), Color(0xFF2170E4)],
  );

  static const LinearGradient thetaScaleGradient = LinearGradient(
    colors: <Color>[
      Color(0xFFF2A0A0),
      Color(0xFFADC6FF),
      Color(0xFF6FE7B7),
    ],
  );
}
