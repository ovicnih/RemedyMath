import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_text_styles.dart';

/// Tema Material 3 aplikasi, gaya neobrutalism.
///
/// Ringkas saja: aplikasi memakai `AppTextStyles` dan widget
/// kustom secara langsung, jadi `textTheme` di sini hanya untuk
/// memetakan slot Material standar ke token kita. Semua slot ada
/// isinya supaya tidak ada teks yang jatuh ke default.
///
/// Light-only. Tidak ada `dark()` dan tidak ada `ThemeMode.system` —
/// lihat PLANNING.md §6.
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accentBlue,
      primary: AppColors.accentBlue,
      onPrimary: AppColors.ink,
      secondary: AppColors.accentGreen,
      onSecondary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.accentPink,
      onError: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Font default untuk seluruh subtree, termasuk widget Material yang
      // tidak diberi style eksplisit. Token di `AppTextStyles` sudah
      // menyebut family-nya sendiri, tapi baris ini menutup sisanya.
      fontFamily: AppTextStyles.sans,
      fontFamilyFallback: AppTextStyles.fallback,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLg,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLg,
        displayMedium: AppTextStyles.displayNum,
        headlineLarge: AppTextStyles.titleLg,
        headlineMedium: AppTextStyles.titleMd,
        headlineSmall: AppTextStyles.titleSm,
        titleLarge: AppTextStyles.titleLg,
        titleMedium: AppTextStyles.titleMd,
        titleSmall: AppTextStyles.titleSm,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        bodySmall: AppTextStyles.labelMd,
        labelLarge: AppTextStyles.labelStrong,
        labelMedium: AppTextStyles.labelMd,
        labelSmall: AppTextStyles.labelSm,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.ink,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentYellow,
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(50),
          textStyle: AppTextStyles.labelStrong,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            side: const BorderSide(
              color: AppColors.ink,
              width: AppSizes.borderThick,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.surface,
          minimumSize: const Size.fromHeight(50),
          textStyle: AppTextStyles.labelStrong,
          side: const BorderSide(
            color: AppColors.ink,
            width: AppSizes.borderThick,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          textStyle: AppTextStyles.labelStrong,
          minimumSize: const Size(48, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceLg,
          vertical: AppSizes.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          borderSide: const BorderSide(
            color: AppColors.ink,
            width: AppSizes.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          borderSide: const BorderSide(
            color: AppColors.ink,
            width: AppSizes.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          borderSide: const BorderSide(
            color: AppColors.ink,
            width: AppSizes.borderThick,
          ),
        ),
        labelStyle: AppTextStyles.bodyMd,
        hintStyle: AppTextStyles.labelMd,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.accentYellow
                  : AppColors.surface,
        ),
        checkColor: const WidgetStatePropertyAll<Color>(AppColors.ink),
        // `AppSizes.borderThick` (3) terlalu berat untuk kotak kecil
        // CHECKBox, dan `borderHairline` (1) terlalu tipis di DPI 3. 2 px
        // adalah token terdekat yang tetap bulat di semua densitas.
        side: const BorderSide(
          color: AppColors.ink,
          width: AppSizes.borderThin,
        ),
      ),
      // Token `radioBorder` tidak bisa dipasang lewat RadioThemeData
      // karena `RadioThemeData` tidak punya parameter `side`. Border-nya
      // dipasang di level widget `Radio` — lihat UI-REFERENCE §5.1.
      radioTheme: const RadioThemeData(
        fillColor: WidgetStatePropertyAll<Color>(AppColors.surface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accentYellow,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) => AppTextStyles.labelMd.copyWith(
            color: AppColors.ink,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w900
                : FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          side: const BorderSide(
            color: AppColors.ink,
            width: AppSizes.borderThin,
          ),
        ),
      ),
    );
  }
}