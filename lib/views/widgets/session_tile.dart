import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import 'neo_card.dart';
import 'pill.dart';

/// Baris riwayat sesi: ikon status, judul, tanggal, skor, dan tombol aksi.
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
    return NeoCard(
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: passed ? AppColors.surface : AppColors.accentPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(passed ? Icons.functions : Icons.calculate_outlined,
                    color: passed ? AppColors.accentBlue : AppColors.accentPink),
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
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Pill(
                label: passed ? 'Tuntas' : 'Perlu Perbaikan',
                icon: passed ? Icons.check : null,
                background: passed ? AppColors.accentGreen : AppColors.accentPink,
                foreground: passed ? AppColors.ink : AppColors.ink,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                          style: AppTextStyles.labelMd),
                      TextSpan(
                          text: '$score',
                          style: AppTextStyles.mathInline
                              .copyWith(fontWeight: FontWeight.w700)),
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
