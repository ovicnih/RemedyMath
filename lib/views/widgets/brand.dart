import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import 'pill.dart';

/// Logo aplikasi: kotak 40×40 dengan glif sigma.
///
/// Bentuk sesuai desain `UI-REFERENCE.md` §4.1 item 1: bg `#E2F16D`,
/// radius 10, border 3 px, bayangan `Offset(3, 3)`.
///
/// [bordered] dan [shadowed] bisa dimatikan untuk logo besar yang berdiri
/// sendiri — misalnya di halaman onboarding, yang tidak memakai border
/// keliling.
///
/// Glif pakai teks sigma, bukan `Icon(Icons...)`: logo adalah brand mark,
/// bukan ikon fungsional. Tabel ikon §5.4 memetakan peran "logo / mark"
/// ke `Icons.functions`, tapi lambang sigma jauh lebih terbaca sebagai
/// matematika pada ukuran 22 px.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 40,
    this.bordered = true,
    this.shadowed = true,
  });

  /// Nama aplikasi. Dipakai juga sebagai teks wordmark di `AppHeader`.
  ///
  /// Ejaan mengikuti nama folder dan paket, yaitu `RemedyMath`. Dokumen
  /// `1-Bahan/` menuliskan `RemediMath`; belum ada keputusan final.
  /// Lihat `DESIGN-AUDIT.md` §11.
  static const String brandName = 'RemedyMath';

  /// Sisi kotak. Default 40 sesuai desain.
  final double size;

  /// Border 3 px di sekeliling. Default `true`.
  final bool bordered;

  /// Bayangan `Offset(3, 3)`. Default `true`.
  final bool shadowed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accentYellow,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: bordered
            ? Border.all(color: AppColors.ink, width: AppSizes.borderThick)
            : null,
        boxShadow: shadowed ? AppSizes.shadowLogoOffset : null,
      ),
      // Ukuran mengikuti `size` yang berubah-ubah, jadi token dipakai
      // lewat `copyWith` — bukan `TextStyle` inline (TASK 2.7).
      child: Text(
        'Σ',
        style: AppTextStyles.mathDisplay.copyWith(fontSize: size * 0.55),
      ),
    );
  }
}

/// Avatar lingkaran: bg `#FF69B4`, border 3 px, inisial profil.
///
/// Default diameter 36 sesuai desain. Inisial diambil dari
/// [AppController] supaya pemanggil tidak perlu mengirimnya; [initials]
/// bisa dipakai untuk override di preview atau test.
/// Mendukung [photoPath] untuk menampilkan foto profil dari galeri.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.initials,
    this.size = 36,
    this.photoPath,
    this.onTap,
  });

  /// Inisial profil. Kalau `null`, dibaca dari [AppController].
  final String? initials;

  /// Diameter lingkaran. Default 36 sesuai desain.
  final double size;

  /// Path foto profil lokal (dari image_picker). Kalau null, tampilkan inisial.
  final String? photoPath;

  /// Callback saat avatar diketuk (mis. buka halaman Pengaturan).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String resolved = initials ??
        context.select<AppController, String>(
          (AppController c) => c.profile?.initials ?? '?',
        );

    Widget child;
    if (photoPath != null && photoPath!.isNotEmpty) {
      if (kIsWeb) {
        child = _buildWebImage(resolved);
      } else {
        child = ClipOval(
          child: Image.file(
            File(photoPath!),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialsWidget(resolved),
          ),
        );
      }
    } else {
      child = _initialsWidget(resolved);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.accentPink,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
        ),
        child: child,
      ),
    );
  }

  Widget _buildWebImage(String fallback) {
    // photoPath is base64 on web
    if (photoPath == null || photoPath!.isEmpty) {
      return _initialsWidget(fallback);
    }
    try {
      final bytes = base64Decode(photoPath!);
      return ClipOval(
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsWidget(fallback),
        ),
      );
    } catch (_) {
      return _initialsWidget(fallback);
    }
  }

  Widget _initialsWidget(String text) => Text(
        text,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900),
      );
}

/// AppBar standar.
///
/// ## Rencana
///
/// Bentuk `AppHeader` sudah sama persis dengan desain, tapi `AppBar`
/// Material masih membungkus isinya dengan tinggi toolbar 64 px dan
/// tombol kembali native. Pemindahan penuh ke `AppHeader` adalah
/// pekerjaan Tahap 4, jadi fungsi ini masih dipakai sembilan halaman
/// sebagai `Scaffold.appBar` sampai call site-nya siap.
PreferredSizeWidget remediAppBar(
  BuildContext context,
  String subtitle, {
  bool showBack = false,
}) {
  final String kelas = context.select<AppController, String>(
    (AppController c) => c.profile?.className ?? 'SMA Kelas 10',
  );
  return AppBar(
    automaticallyImplyLeading: showBack,
    titleSpacing: showBack ? 0 : 16,
    toolbarHeight: 64,
    title: Row(
      children: <Widget>[
        if (!showBack) ...<Widget>[
          const AppLogo(),
          const SizedBox(width: AppSizes.spaceMd),
        ],        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(AppLogo.brandName, style: AppTextStyles.titleLg),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMd,
              ),
            ],
          ),
        ),
      ],
    ),
    actions: <Widget>[
      Center(child: Pill(label: kelas)),
      const SizedBox(width: AppSizes.spaceSm),
      const ProfileAvatar(),
      const SizedBox(width: AppSizes.spaceLg),
    ],
  );
}
