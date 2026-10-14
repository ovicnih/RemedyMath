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
                  Icon(Icons.verified_outlined, size: 16, color: AppColors.accentGreen),
                  SizedBox(width: 4),
                  Text('Semester Ganjil'),
                ]),
              ],
            ),
            const SizedBox(height: 16),
            Text('Halo, ${c.profile?.firstName ?? 'Siswa'} 👋', style: AppTextStyles.titleLg),
            const SizedBox(height: 4),
            Text('Siap memperkuat pemahaman matematikamu hari ini?',
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink)),
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
              color: AppColors.surface,
              onTap: () => Flows.openRemedial(context, rec.id),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      // Tanpa gradien (TASK 2.2).
                      color: AppColors.accentYellow,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppSizes.shadowCard,
                    ),
                    child: const Icon(Icons.play_circle_fill, color: AppColors.ink, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Row(children: <Widget>[
                          Icon(Icons.tips_and_updates_outlined,
                              size: 18, color: AppColors.accentBlue),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text('Rekomendasi Belajar Hari Ini',
                                style: AppTextStyles.titleSm),
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
              color: AppColors.surface,
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.lightbulb_outline, color: AppColors.accentBlue),
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
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
                    const SizedBox(height: 4),
                    Text.rich(TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: r == null ? 'θ = –' : 'θ = ${Formatters.theta(theta)}',
                          style: AppTextStyles.statValue),
                      const TextSpan(text: ' / 3.00', style: AppTextStyles.mathInline),
                    ])),
                    const SizedBox(height: 8),
                    Pill(
                      label: r == null
                          ? 'Belum ada diagnosis'
                          : 'Tingkat Kemahiran: ${controller.irt.proficiencyLabel(theta)}',
                      background: AppColors.surface,
                      foreground: AppColors.ink,
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
                        backgroundColor: AppColors.surface,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(r == null ? '–' : Formatters.percent(pct),
                            style: AppTextStyles.titleMd),
                        Text('Relatif Kelas', style: AppTextStyles.labelMd.copyWith(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            color: AppColors.surface,
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
                    const Text('Status Diagnostik Terakhir', style: AppTextStyles.labelMd),
                    if (r == null)
                      const Pill(label: 'Belum Tes', icon: Icons.info_outline)
                    else if (root != null)
                      const Pill(
                        label: 'Akar Masalah Terdeteksi',
                        icon: Icons.error_outline,
                        background: AppColors.accentPink,
                        foreground: AppColors.ink,
                      )
                    else
                      const Pill(
                        label: 'Semua Konsep Tuntas',
                        icon: Icons.check_circle_outline,
                        background: AppColors.accentGreen,
                        foreground: AppColors.ink,
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Σ', style: AppTextStyles.titleLg),
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
                            style: AppTextStyles.labelMd,
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
                child: StatCard(
                  color: AppColors.accentGreen,
                  value: '${controller.masteredCount}',
                  label: 'Topik tuntas',
                ),
              ),
              const SizedBox(width: AppSizes.spaceLg),
              Expanded(
                child: StatCard(
                  color: AppColors.accentPink,
                  value: '${controller.remedialCount}',
                  label: 'Perlu remedial',
                ),
              ),
              const SizedBox(width: AppSizes.spaceLg),
              Expanded(
                child: StatCard(
                  color: AppColors.surface,
                  value: Formatters.percent(controller.averageAccuracy),
                  label: 'Akurasi rata-rata',
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
        // Tanpa gradien (TASK 2.2). Hero memakai warna solid aksen.
        color: AppColors.accentBlue,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppSizes.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.ink.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.radio_button_checked, color: AppColors.accentYellow),
            ),
            const SizedBox(width: 10),
            // Expanded wajib: tanpa ini teks eyebrow yang panjang meluber
            // dari Container hero di layar sempit.
            Expanded(
              child: Text(
                'DIAGNOSIS ADAPTIF',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMd
                    .copyWith(color: AppColors.ink.withAlpha(220)),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Text('Mulai Tes Diagnostik Presisi',
              style: AppTextStyles.titleLg.copyWith(color: AppColors.ink, fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            'Identifikasi miskonsepsi & kelemahan materi aljabar dalam $durationMinutes menit dengan analisis butir otomatis.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink.withAlpha(210)),
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
              NeoButton(
                icon: Icons.arrow_forward,
                label: 'Mulai',
                onPressed: onStart,
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
          Icon(i, size: 16, color: AppColors.ink),
          const SizedBox(width: 4),
          Text(t, style: AppTextStyles.titleSm.copyWith(color: AppColors.ink)),
        ],
      );
}
