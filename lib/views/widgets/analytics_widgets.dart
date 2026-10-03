import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import 'common.dart';

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
              // `c.maxWidth` bisa 0 (constraint belum selesai), sangat kecil,
              // atau tak hingga. Guard di sini menjaga `clamp` tidak pernah
              // dipanggil dengan lower > upper, yang melempar ArgumentError.
              final double w = c.maxWidth.isFinite && c.maxWidth > 0 ? c.maxWidth : 0.0;
              final double lineWidth = 2;
              final double knob = 28;

              // Batas kiri yang valid per penanda. Kalau track lebih sempit
              // dari penandanya, batasi ke 0 supaya tidak ada rentang negatif.
              final double lineMax = (w - lineWidth).clamp(0.0, double.infinity);
              final double knobMax = (w - knob).clamp(0.0, double.infinity);

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
                    left: (w * mPos - lineWidth / 2).clamp(0.0, lineMax),
                    child: Container(
                      width: lineWidth,
                      height: 16,
                      color: AppColors.surface,
                    ),
                  ),
                  Positioned(
                    left: (w * pos - knob / 2).clamp(0.0, knobMax),
                    child: Container(
                      width: knob,
                      height: knob,
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
                // Kelompok teks dirapikan ke dalam satu Flexible supaya hanya
                // tombol aksi yang punya lebar tetap. Sebelum ini keempat
                // Text adalah anak rigid dan Row bisa meluber di layar sempit.
                Flexible(
                  child: Text.rich(
                    TextSpan(children: <InlineSpan>[
                      const TextSpan(
                          text: 'Skor Post-test: ',
                          style: AppTextStyles.bodySm),
                      TextSpan(
                          text: '$score',
                          style: AppTextStyles.mathInline.copyWith(
                              color: scoreColor, fontWeight: FontWeight.w700)),
                      TextSpan(
                          text: '/100',
                          style: AppTextStyles.mathInline.copyWith(fontSize: 12)),
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
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
