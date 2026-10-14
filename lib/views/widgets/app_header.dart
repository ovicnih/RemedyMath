import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import 'brand.dart';

/// Header aplikasi: logo + wordmark + badge kelas + avatar.
///
/// Bentuknya diputuskan di `DESIGN-AUDIT.md` §6.4a: header **hanya memuat
/// identitas**, bukan nav pill. Alasannya terukur — empat nav pill +
/// logo + badge + avatar membutuhkan sekitar 630 dp, sedangkan lebar
/// Android minimum yang wajar 360 dp. Navigasi tetap di bawah.
///
/// Spesifikasi asal: `UI-REFERENCE.md` §4.1 item 1 — bg putih, border
/// bawah dan samping 3 px `#1A1A1A`, tanpa radius.
///
/// ## Ejaan
///
/// Wordmark memakai `RemedyMath`, mengikuti nama folder dan
/// [AppLogo.brandName]. Dokumen `1-Bahan/` menuliskan `RemediMath`; kedua
/// ejaan masih belum direkonsiliasi. Lihat `DESIGN-AUDIT.md` §11.
///
/// ## Titik pink pada wordmark
///
/// `RemedyMath` + `.` pink. Satu glyph dua warna tidak bisa pakai `Text`
/// biasa, jadi memakai `Text.rich` dengan dua `TextSpan`. Pink di sini
/// aman walau kontrasnya rendah, karena WCAG 1.4.3 mengecualikan
/// logotype. Lihat `DESIGN-AUDIT.md` §6.5.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.showBorder = true});

  /// Kalau `false`, border bawah dan samping dihilangkan. Dipakai pada
  /// halaman yang scroll-nya menyatu dengan header.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    const BorderSide ink = BorderSide(
      color: AppColors.ink,
      width: AppSizes.borderThick,
    );
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      // `foregroundDecoration` dipakai supaya border tidak ikut ter-*paint*
      // di atas isi. `Container` akan menolak `decoration` dan
      // `foregroundDecoration` bersama-sama.
      foregroundDecoration: showBorder
          ? const BoxDecoration(
              border: Border(bottom: ink, left: ink, right: ink),
            )
          : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceLg,
        vertical: AppSizes.spaceMd,
      ),
      child: const SafeArea(
        bottom: false,
        child: Row(
          children: <Widget>[
            AppLogo(),
            SizedBox(width: AppSizes.spaceMd),
            Expanded(child: _Wordmark()),
            SizedBox(width: AppSizes.spaceSm),
            ClassBadge(),
            SizedBox(width: AppSizes.spaceSm),
            ProfileAvatar(),
          ],
        ),
      ),
    );
  }
}

/// Wordmark aplikasi: teks tinta + titik pink.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    // `maxLines` + `ellipsis` diwarisi `Text.rich`, jadi tidak ada
    // regresi layout di layar 360 dp.
    return const Text.rich(
      TextSpan(
        text: AppLogo.brandName,
        children: <InlineSpan>[
          TextSpan(
            text: '.',
            style: TextStyle(color: AppColors.accentPink),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.titleLg,
    );
  }
}

/// Badge kelas: bg `#70B2FF`, radius 8, border 2 px, 11 px.
///
/// Teksnya dibaca dari [AppController] supaya pemanggil tidak perlu
/// mengirimnya. [label] dipakai untuk override di preview atau test.
class ClassBadge extends StatelessWidget {
  const ClassBadge({super.key, this.label});

  /// Teks badge, mis. `SMA Kelas 10`. Kalau `null`, dibaca dari
  /// [AppController].
  final String? label;

  @override
  Widget build(BuildContext context) {
    final String resolved = label ??
        context.select<AppController, String>(
          (AppController c) => c.profile?.className ?? 'SMA Kelas 10',
        );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSm,
        vertical: AppSizes.spaceXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentBlue,
        borderRadius: AppSizes.radius(AppSizes.radiusChip),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThin),
      ),
      child: Text(
        resolved,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption,
      ),
    );
  }
}
