import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../flows.dart';
import '../widgets/common.dart';
import 'diagnosis_result_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final DiagnosticResult? r = c.latestResult;
    final ConceptNode? root = c.rootCause;
    final String nextNodeId =
        r != null && r.learningPath.isNotEmpty ? r.learningPath.first : c.graph.ordered.first.id;
    final ConceptNode rec = c.graph.node(nextNodeId)!;

    return Scaffold(
      appBar: remediAppBar(context, 'Beranda'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Pill(label: '• ${c.profile?.className ?? 'SMA Kelas 10'} • Matematika Wajib'),
                const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Icon(Icons.verified_outlined, size: 16, color: AppColors.success),
                  SizedBox(width: 4),
                  Text('Semester Ganjil'),
                ]),
              ],
            ),
            const SizedBox(height: 16),
            Text('Halo, ${c.profile?.firstName ?? 'Siswa'} 👋', style: AppTextStyles.headlineLg),
            const SizedBox(height: 4),
            Text('Siap memperkuat pemahaman matematikamu hari ini?',
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            _MetricCard(controller: c, result: r, root: root),
            const SizedBox(height: 20),
            _HeroCta(
              durationMinutes: c.content.durationMinutes,
              count: c.content.diagnosticQuestions.length,
              onStart: () => Flows.startDiagnostic(context),
            ),
            const SizedBox(height: 20),
            AppCard(
              color: AppColors.surfaceContainer,
              onTap: () => Flows.openRemedial(context, rec.id),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.play_circle_fill, color: AppColors.onPrimary, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(children: <Widget>[
                          const Icon(Icons.tips_and_updates_outlined,
                              size: 18, color: AppColors.secondaryStrong),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('Rekomendasi Belajar Hari Ini',
                                style: AppTextStyles.titleSm
                                    .copyWith(color: AppColors.secondaryStrong)),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text('${rec.videoTitle} (${rec.videoDurationLabel})',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMd),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionTitle(
              'Riwayat Sesi Remedial',
              trailing: TextButton(
                onPressed: () => c.setTab(3),
                child: const Text('Lihat Semua ›'),
              ),
            ),
            const SizedBox(height: 8),
            if (c.sessions.isEmpty)
              const EmptyState(
                icon: Icons.history_edu,
                title: 'Belum ada sesi remedial',
                message: 'Selesaikan tes diagnostik lalu ikuti rute belajarmu untuk mengisi riwayat.',
              )
            else
              for (final RemedialSession s in c.sessions.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SessionTile(
                    title: s.title,
                    dateLabel: Formatters.shortDate(s.date),
                    subtitle: s.label,
                    score: s.score,
                    passed: s.passed,
                    onAction: () => Flows.openRemedial(context, s.nodeId),
                  ),
                ),
            const SizedBox(height: 12),
            AppCard(
              color: AppColors.surfaceContainerLow,
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: Icon(Icons.lightbulb_outline, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '“Kesalahan aljabar hari ini adalah pijakan ketelitianmu untuk materi trigonometri esok.”',
                      style: AppTextStyles.bodyMd.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.controller, required this.result, required this.root});
  final AppController controller;
  final DiagnosticResult? result;
  final ConceptNode? root;

  @override
  Widget build(BuildContext context) {
    final DiagnosticResult? r = result;
    final double theta = r?.theta ?? 0;
    final double pct = r == null ? 0 : controller.irt.classPercentile(theta);
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('METRIK DIAGNOSTIK IRT',
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text.rich(TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: r == null ? 'θ = –' : 'θ = ${Formatters.theta(theta)}',
                          style: AppTextStyles.monoNumeric),
                      const TextSpan(text: ' / 3.00', style: AppTextStyles.mathInline),
                    ])),
                    const SizedBox(height: 8),
                    Pill(
                      label: r == null
                          ? 'Belum ada diagnosis'
                          : 'Tingkat Kemahiran: ${controller.irt.proficiencyLabel(theta)}',
                      background: AppColors.surfaceContainerLow,
                      foreground: AppColors.textPrimary,
                      icon: Icons.circle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 8,
                        backgroundColor: AppColors.surfaceContainer,
                        color: AppColors.secondaryStrong,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(r == null ? '–' : Formatters.percent(pct),
                            style: AppTextStyles.titleMd.copyWith(color: AppColors.primary)),
                        Text('Relatif Kelas', style: AppTextStyles.bodySm.copyWith(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            color: AppColors.surfaceContainerLow,
            onTap: r == null
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const DiagnosisResultPage())),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    const Text('Status Diagnostik Terakhir', style: AppTextStyles.bodySm),
                    if (r == null)
                      const Pill(label: 'Belum Tes', icon: Icons.info_outline)
                    else if (root != null)
                      const Pill(
                        label: 'Akar Masalah Terdeteksi',
                        icon: Icons.error_outline,
                        background: AppColors.dangerContainer,
                        foreground: AppColors.onDangerContainer,
                      )
                    else
                      const Pill(
                        label: 'Semua Konsep Tuntas',
                        icon: Icons.check_circle_outline,
                        background: AppColors.successContainer,
                        foreground: AppColors.onSuccessContainer,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Σ', style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(root?.title ?? controller.content.chapter,
                              style: AppTextStyles.titleMd),
                          Text(
                            r == null
                                ? 'Ikuti tes diagnostik untuk menemukan akar masalahmu.'
                                : root != null
                                    ? root!.misconception
                                    : 'Tidak ada miskonsepsi yang terdeteksi. Pertahankan!',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: StatTile(
                  icon: Icons.check_circle_outline,
                  value: '${controller.masteredCount}',
                  label: 'Topik Tuntas',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.sync_problem,
                  iconColor: AppColors.danger,
                  value: '${controller.remedialCount}',
                  label: 'Perlu Remedial',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.trending_up,
                  value: Formatters.percent(controller.averageAccuracy),
                  label: 'Akurasi Rerata',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCta extends StatelessWidget {
  const _HeroCta({required this.durationMinutes, required this.count, required this.onStart});
  final int durationMinutes;
  final int count;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.radio_button_checked, color: AppColors.tertiaryFixed),
            ),
            const SizedBox(width: 10),
            Text('DIAGNOSIS ADAPTIF',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.onPrimary.withAlpha(220))),
          ]),
          const SizedBox(height: 14),
          Text('Mulai Tes Diagnostik Presisi',
              style: AppTextStyles.headlineMd.copyWith(color: AppColors.onPrimary, fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            'Identifikasi miskonsepsi & kelemahan materi aljabar dalam $durationMinutes menit dengan analisis butir otomatis.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onPrimary.withAlpha(210)),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: <Widget>[
                    _meta(Icons.schedule, '$durationMinutes Menit'),
                    _meta(Icons.format_list_numbered, '$count Soal'),
                  ],
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(110, 50),
                  backgroundColor: AppColors.tertiaryFixed,
                  foregroundColor: AppColors.onSuccessContainer,
                ),
                onPressed: onStart,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Mulai'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData i, String t) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(i, size: 16, color: AppColors.onPrimary),
          const SizedBox(width: 4),
          Text(t, style: AppTextStyles.titleSm.copyWith(color: AppColors.onPrimary)),
        ],
      );
}
