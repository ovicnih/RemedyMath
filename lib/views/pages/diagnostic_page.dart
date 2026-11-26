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
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceLg,
            AppSizes.spaceXs,
            AppSizes.spaceLg,
            AppSizes.spaceXl,
          ),
          children: <Widget>[
            NeoCard(
              padding: const EdgeInsets.all(AppSizes.spaceXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Pill(
                      label: 'Tes Diagnostik Adaptif',
                      icon: Icons.assignment_outlined,
                      bordered: true,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceMd),
                  Text(c.content.diagnosticTitle, style: AppTextStyles.titleLg),
                  const SizedBox(height: AppSizes.spaceXs),
                  Text(c.content.chapter,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink)),
                  const SizedBox(height: AppSizes.spaceLg),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: StatCard(
                          color: AppColors.background,
                          value: '${c.content.diagnosticQuestions.length}',
                          label: 'Soal',
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceMd),
                      Expanded(
                        child: StatCard(
                          color: AppColors.background,
                          value: '${c.content.durationMinutes}',
                          label: 'Menit',
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceMd),
                      Expanded(
                        child: StatCard(
                          color: AppColors.background,
                          value: '${c.graph.nodes.length}',
                          label: 'Sub-konsep',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  for (final String t in const <String>[
                    'Jawab setiap soal dengan jujur — tebakan membuat diagnosis kurang akurat.',
                    'Gunakan fitur Coretan untuk menulis langkah pengerjaan.',
                    'Tandai “Ragu-ragu” untuk soal yang ingin ditinjau ulang.',
                    'Kemampuanmu (θ) dihitung dengan Model Rasch & akar masalah ditelusuri lewat peta prasyarat.',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spaceSm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen,
                              borderRadius:
                                  AppSizes.radius(AppSizes.radiusChip),
                              border: Border.all(
                                color: AppColors.ink,
                                width: AppSizes.borderHairline,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 13,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceSm),
                          Expanded(child: Text(t, style: AppTextStyles.bodyMd)),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSizes.spaceSm),
                  NeoButton(
                    expand: true,
                    icon: Icons.play_arrow,
                    label: r == null
                        ? 'Mulai Tes Diagnostik'
                        : 'Ulangi Tes Diagnostik',
                    onPressed: () => Flows.startDiagnostic(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            if (r != null)
              NeoCard(
                color: AppColors.surface,
                borderWidth: AppSizes.borderThin,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const DiagnosisResultPage())),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue,
                        borderRadius: AppSizes.radius(AppSizes.radiusChip),
                        border: Border.all(
                          color: AppColors.ink,
                          width: AppSizes.borderThin,
                        ),
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: AppColors.ink,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Hasil terakhir • ${Formatters.shortDate(r.date)}',
                            style: AppTextStyles.labelMd,
                          ),
                          const SizedBox(height: AppSizes.spaceXs),
                          Text(
                            'Skor ${Formatters.score(r.accuracy)}/100 • θ = ${Formatters.theta(r.theta)}',
                            style: AppTextStyles.titleMd,
                          ),
                          Text(
                            c.rootCause?.title ?? 'Tidak ada akar masalah',
                            style: AppTextStyles.labelMd
                                .copyWith(color: AppColors.ink),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.ink),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
