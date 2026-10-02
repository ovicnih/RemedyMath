import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';

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
    this.background = AppColors.secondaryContainer,
    this.foreground = AppColors.onSecondaryContainer,
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
      child: Text.rich(
        TextSpan(children: <InlineSpan>[
          if (icon != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(icon, size: 14, color: foreground),
              ),
            ),
          TextSpan(text: label),
        ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelMd.copyWith(color: foreground, letterSpacing: 0.2),
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
        color: AppColors.surfaceContainerLow,
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
    this.iconColor = AppColors.primary,
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
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(value, style: AppTextStyles.headlineMd),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
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
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(title, style: AppTextStyles.headlineMd)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Logo RemediMath (Σ).
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
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Text(
        'Σ',
        style: TextStyle(
          color: AppColors.onPrimary,
          fontSize: size * 0.55,
          fontWeight: FontWeight.w700,
        ),
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
      backgroundColor: AppColors.surfaceContainerHighest,
      child: Text(
        initials,
        style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
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
              Text('RemediMath',
                  style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary)),
              Text(subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
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
          Icon(icon, size: 48, color: AppColors.secondaryStrong),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.titleMd),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
          if (action != null) ...<Widget>[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// Skala θ -3..+3 dengan penanda posisi.
class ThetaScale extends StatelessWidget {
  const ThetaScale({super.key, required this.theta, required this.masteryTheta});
  final double theta;
  final double masteryTheta;

  @override
  Widget build(BuildContext context) {
    final double pos = ((theta + 3) / 6).clamp(0.0, 1.0);
    final double mPos = ((masteryTheta + 3) / 6).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('-3.0 (Dasar)', style: AppTextStyles.mathInline.copyWith(fontSize: 12)),
            Expanded(
              child: Text(
                'θ ${theta.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: AppTextStyles.mathInline
                    .copyWith(fontSize: 12, color: AppColors.primary),
              ),
            ),
            Text('+3.0 (Mahir)', style: AppTextStyles.mathInline.copyWith(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 28,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double w = c.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: AppColors.thetaScaleGradient,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Positioned(
                    left: (w * mPos - 1).clamp(0.0, w - 2),
                    child: Container(width: 2, height: 16, color: AppColors.surface),
                  ),
                  Positioned(
                    left: (w * pos - 14).clamp(0.0, w - 28),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 3),
                      ),
                      child: const Icon(Icons.person, size: 14, color: AppColors.onPrimary),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Expanded(
              child: Text('Perlu Pendampingan',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
            ),
            Expanded(
              child: Text('Batas Tuntas (θ ≥ ${masteryTheta.toStringAsFixed(1)})',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.secondaryStrong)),
            ),
            Expanded(
              child: Text('Mandiri',
                  textAlign: TextAlign.end,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Riwayat sesi remedial (dipakai di Beranda & Progres).
class SessionTile extends StatelessWidget {
  const SessionTile({
    super.key,
    required this.title,
    required this.dateLabel,
    required this.subtitle,
    required this.score,
    required this.passed,
    this.onAction,
  });

  final String title;
  final String dateLabel;
  final String subtitle;
  final int score;
  final bool passed;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = passed ? AppColors.success : AppColors.danger;
    return AppCard(
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: passed ? AppColors.surfaceContainer : AppColors.dangerSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(passed ? Icons.functions : Icons.calculate_outlined,
                    color: passed ? AppColors.primary : AppColors.danger),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMd),
                    const SizedBox(height: 4),
                    Text('$dateLabel • $subtitle',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Pill(
                label: passed ? 'Tuntas' : 'Perlu Perbaikan',
                icon: passed ? Icons.check : null,
                background: passed ? AppColors.successContainer : AppColors.dangerContainer,
                foreground: passed ? AppColors.onSuccessContainer : AppColors.onDangerContainer,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: <Widget>[
                const Text('Skor Post-test: ', style: AppTextStyles.bodySm),
                Text('$score',
                    style: AppTextStyles.mathInline
                        .copyWith(color: scoreColor, fontWeight: FontWeight.w700)),
                Text('/100', style: AppTextStyles.mathInline.copyWith(fontSize: 12)),
                const Spacer(),
                if (onAction != null)
                  TextButton.icon(
                    onPressed: onAction,
                    icon: Icon(passed ? Icons.visibility_outlined : Icons.refresh, size: 16),
                    label: Text(passed ? 'Lihat Materi' : 'Ulangi Remedial'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
