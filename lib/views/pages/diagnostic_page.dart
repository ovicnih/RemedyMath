import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../flows.dart';
import '../widgets/common.dart';
import 'diagnosis_result_page.dart';

/// Tab Diagnostik: informasi tes dan hasil terakhir.
class DiagnosticPage extends StatelessWidget {
  const DiagnosticPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final DiagnosticResult? r = c.latestResult;
    return Scaffold(
      appBar: remediAppBar(context, 'Diagnostik'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: <Widget>[
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Pill(label: 'Tes Diagnostik Adaptif', icon: Icons.assignment_outlined),
                  const SizedBox(height: 12),
                  Text(c.content.diagnosticTitle, style: AppTextStyles.titleLg),
                  const SizedBox(height: 6),
                  Text(c.content.chapter,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink)),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: StatCard(
                          color: AppColors.surface,
                          value: '${c.content.diagnosticQuestions.length}',
                          label: 'Soal',
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceLg),
                      Expanded(
                        child: StatCard(
                          color: AppColors.surface,
                          value: '${c.content.durationMinutes}',
                          label: 'Menit',
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceLg),
                      Expanded(
                        child: StatCard(
                          color: AppColors.surface,
                          value: '${c.graph.nodes.length}',
                          label: 'Sub-konsep',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final String t in <String>[
                    'Jawab setiap soal dengan jujur — tebakan membuat diagnosis kurang akurat.',
                    'Gunakan fitur Coretan untuk menulis langkah pengerjaan.',
                    'Tandai “Ragu-ragu” untuk soal yang ingin ditinjau ulang.',
                    'Kemampuanmu (θ) dihitung dengan Model Rasch & akar masalah ditelusuri lewat peta prasyarat.',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.accentGreen),
                          const SizedBox(width: 8),
                          Expanded(child: Text(t, style: AppTextStyles.bodyMd)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  NeoButton(
                    expand: true,
                    icon: Icons.play_arrow,
                    label: r == null ? 'Mulai Tes Diagnostik' : 'Ulangi Tes Diagnostik',
                    onPressed: () => Flows.startDiagnostic(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (r != null)
              AppCard(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const DiagnosisResultPage())),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.analytics_outlined, color: AppColors.accentBlue, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Hasil terakhir • ${Formatters.shortDate(r.date)}',
                              style: AppTextStyles.labelMd),
                          Text('θ = ${Formatters.theta(r.theta)} • Akurasi ${Formatters.percent(r.accuracy)}',
                              style: AppTextStyles.titleMd),
                          Text(c.rootCause?.title ?? 'Tidak ada akar masalah',
                              style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
