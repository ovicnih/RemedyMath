import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';

// `ThetaScale` dan `SessionTile` dipindah ke berkas ini agar `common.dart`
// tidak melewati batas 500 baris (AGENTS.md §5). Diekspor ulang supaya
// pemanggil tetap cukup mengimpor satu berkas.
export 'analytics_widgets.dart';

/// Kartu dasar dengan sudut membulat.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.onTap,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: (border == null || border!.isUniform)
                ? BorderRadius.circular(16)
                : null,
            border: border,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(999),
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        expression,
        textAlign: TextAlign.center,
        style: AppTextStyles.mathDisplay.copyWith(fontSize: 22),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = AppColors.accentBlue,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              // Flexible wajib: tanpa ini `value` yang panjang (mis. "100%")
              // membuat Row meluber dari tile yang hanya ~1/3 lebar kartu.
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMd.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing, this.icon});
  final String title;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, color: AppColors.accentBlue, size: 22),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(title, style: AppTextStyles.titleLg)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Logo RemedyMath (Σ).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accentBlue,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Text(
        'Σ',
        // Ukuran mengikuti `size` yang berubah-ubah, jadi token dipakai
        // lewat `copyWith` — bukan `TextStyle` inline (TASK 2.7).
        style: AppTextStyles.mathDisplay.copyWith(fontSize: size * 0.55),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.radius = 20});
  final double radius;

  @override
  Widget build(BuildContext context) {
    final String initials =
        context.select<AppController, String>((c) => c.profile?.initials ?? '?');
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surface,
      child: Text(
        initials,
        style: AppTextStyles.titleMd.copyWith(color: AppColors.accentBlue),
      ),
    );
  }
}

/// AppBar standar: logo, nama aplikasi, subjudul, kelas & avatar.
PreferredSizeWidget remediAppBar(BuildContext context, String subtitle,
    {bool showBack = false}) {
  final String kelas = context
      .select<AppController, String>((c) => c.profile?.className ?? 'SMA Kelas 10');
  return AppBar(
    automaticallyImplyLeading: showBack,
    titleSpacing: showBack ? 0 : 16,
    toolbarHeight: 64,
    title: Row(
      children: <Widget>[
        if (!showBack) ...<Widget>[const AppLogo(), const SizedBox(width: 10)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('RemedyMath',
                  style: AppTextStyles.titleLg.copyWith(color: AppColors.accentBlue)),
              Text(subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
            ],
          ),
        ),
      ],
    ),
    actions: <Widget>[
      Center(child: Pill(label: kelas)),
      const SizedBox(width: 10),
      const ProfileAvatar(),
      const SizedBox(width: 16),
    ],
  );
}

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
    return AppCard(
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

