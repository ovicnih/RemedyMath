import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../flows.dart';
import '../widgets/common.dart';
import 'review_page.dart';

class DiagnosisResultPage extends StatelessWidget {
  const DiagnosisResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final DiagnosticResult? r = c.latestResult;
    if (r == null) {
      return Scaffold(
        appBar: remediAppBar(context, 'Hasil Diagnosis', showBack: true),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: EmptyState(
            icon: Icons.assignment_outlined,
            title: 'Belum ada hasil',
            message: 'Kerjakan tes diagnostik terlebih dahulu.',
          ),
        ),
      );
    }
    final ConceptNode? root = c.rootCause;
    final bool mastered = c.irt.isMastered(r.theta);
    final bool watched = root != null && c.isWatched(root.id);

    return Scaffold(
      appBar: remediAppBar(context, 'Hasil Diagnosis', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: <Widget>[
            AppCard(
              color: AppColors.surface,
              child: Row(
                children: <Widget>[
                  const Icon(Icons.analytics_outlined, color: AppColors.accentBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('HASIL ANALISIS DIAGNOSTIK',
                            style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
                        Text(c.content.diagnosticTitle, style: AppTextStyles.titleMd),
                      ],
                    ),
                  ),
                  const Pill(label: 'Metode IRT'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
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
                            Pill(
                              icon: mastered ? Icons.check_circle_outline : Icons.tune,
                              label: mastered ? 'Tuntas' : 'Membutuhkan Penguatan',
                              background:
                                  mastered ? AppColors.accentGreen : AppColors.accentPink,
                              foreground: mastered
                                  ? AppColors.ink
                                  : AppColors.ink,
                            ),
                            const SizedBox(height: 8),
                            const Text('Skor Kemampuan (θ Theta)', style: AppTextStyles.titleLg),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(Formatters.theta(r.theta),
                              style: AppTextStyles.statValue.copyWith(color: AppColors.accentBlue)),
                          Text(c.irt.levelLabel(r.theta), style: AppTextStyles.labelMd),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ThetaScale(theta: r.theta, masteryTheta: AppConstants.masteryTheta),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: <Widget>[
                        _stat('Materi', c.content.topic),
                        _stat('Selesai', '${r.diagnosticTotal} Soal'),
                        _stat('Akurasi', Formatters.percent(r.accuracy),
                            color: r.accuracy >= AppConstants.masteryRatio
                                ? AppColors.accentGreen
                                : AppColors.accentPink),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (root == null)
              const EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'Tidak ada akar masalah',
                message: 'Seluruh sub-konsep sudah dikuasai (≥ 60%). Pertahankan dan lanjutkan ke materi berikutnya!',
              )
            else ...<Widget>[
              _RootCauseCard(controller: c, root: root),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SectionTitle(
                      'Rencana Belajar Cepat Menuju Tuntas',
                      icon: Icons.checklist,
                      trailing: Text('${watched ? 2 : 1}/2 Langkah',
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.accentBlue)),
                    ),
                    const SizedBox(height: 12),
                    _StepTile(
                      number: 1,
                      title: 'Tonton Konsep Inti: ${root.shortTitle}',
                      subtitle: 'Durasi ${root.videoDurationLabel} • Mikro-animasi',
                      done: watched,
                      enabled: true,
                      onTap: () => Flows.openRemedial(context, root.id),
                    ),
                    const SizedBox(height: 10),
                    _StepTile(
                      number: 2,
                      title: 'Post-Test Adaptif ${c.content.postTests[root.id]?.length ?? 5} Soal',
                      subtitle: watched
                          ? 'Target θ ≥ ${AppConstants.masteryTheta.toStringAsFixed(1)}'
                          : 'Buka setelah video selesai',
                      done: false,
                      enabled: watched,
                      onTap: () => Flows.startPostTest(context, root.id),
                    ),
                  ],
                ),
              ),
              if (r.learningPath.length > 1) ...<Widget>[
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SectionTitle('Rute Belajar Lengkap', icon: Icons.route),
                      const SizedBox(height: 8),
                      for (final String id in r.learningPath)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            id == root.id ? Icons.flag : Icons.circle_outlined,
                            color: id == root.id ? AppColors.accentPink : AppColors.ink,
                          ),
                          title: Text(c.graph.node(id)?.title ?? id, style: AppTextStyles.bodyMd),
                          subtitle: Text(
                              'Penguasaan ${Formatters.percent(r.nodeMastery[id] ?? 0)}',
                              style: AppTextStyles.labelMd),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Flows.openRemedial(context, id),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AppCard(
                color: AppColors.surface,
                child: Row(
                  children: <Widget>[
                    const CircleAvatar(
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.psychology_alt_outlined, color: AppColors.accentBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Normal & Wajar!',
                              style: AppTextStyles.titleMd.copyWith(color: AppColors.accentBlue)),
                          Text(
                            'Banyak siswa kelas 10 mengalami kendala serupa di awal semester. Tuntaskan dalam ${root.videoDurationMinutes} menit ke depan.',
                            style: AppTextStyles.bodyMd,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Flows.openRemedial(context, root.id),
                icon: const Icon(Icons.play_arrow),
                label: Text('Tonton Video Penjelasan (${root.videoDurationLabel})'),
              ),
            ],
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => const ReviewPage())),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Lihat Pembahasan Lengkap Soal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) => Expanded(
        child: Column(
          children: <Widget>[
            Text(label, style: AppTextStyles.labelMd),
            const SizedBox(height: 2),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMd.copyWith(color: color)),
          ],
        ),
      );
}

class _RootCauseCard extends StatelessWidget {
  const _RootCauseCard({required this.controller, required this.root});
  final AppController controller;
  final ConceptNode root;

  @override
  Widget build(BuildContext context) {
    final List<ConceptNode> chain = controller.graph.chainTo(root.id);
    return AppCard(
      border: const Border(top: BorderSide(color: AppColors.accentPink, width: 5)),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SectionTitle('Akar Masalah Terdeteksi', icon: Icons.troubleshoot),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('KONSEP SPESIFIK',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
                const SizedBox(height: 6),
                Text(root.title,
                    style: AppTextStyles.titleMd.copyWith(color: AppColors.accentBlue, fontSize: 18)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < chain.length; i++) ...<Widget>[
                      Pill(
                        label: chain[i].shortTitle,
                        background: AppColors.surface,
                        foreground: AppColors.ink,
                      ),
                      if (i < chain.length - 1)
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.ink),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.lightbulb_outline, color: AppColors.accentBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Analisis Cara Berpikirmu', style: AppTextStyles.titleMd),
                    const SizedBox(height: 4),
                    Text(root.misconception,
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _pattern(false, root.wrongPattern)),
              const SizedBox(width: 10),
              Expanded(child: _pattern(true, root.correctPattern)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pattern(bool correct, String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: correct ? AppColors.surface : AppColors.accentPink,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Icon(correct ? Icons.check : Icons.close,
                  size: 14, color: correct ? AppColors.accentGreen : AppColors.accentPink),
              const SizedBox(width: 4),
              Flexible(
                child: Text(correct ? 'SOLUSI TEPAT' : 'POLA KELIRUMU',
                    style: AppTextStyles.labelMd
                        .copyWith(color: correct ? AppColors.accentGreen : AppColors.accentPink)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(
              text,
              style: AppTextStyles.mathInline.copyWith(
                color: correct ? AppColors.ink : AppColors.ink,
                decoration: correct ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      );
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.enabled,
    required this.onTap,
  });

  final int number;
  final String title;
  final String subtitle;
  final bool done;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: AppCard(
        color: AppColors.surface,
        onTap: enabled ? onTap : null,
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 18,
              backgroundColor: enabled ? AppColors.ink : AppColors.surface,
              child: done
                  ? const Icon(Icons.check, color: AppColors.ink, size: 18)
                  : Text('$number',
                      style: AppTextStyles.titleSm.copyWith(
                          color: enabled ? AppColors.ink : AppColors.ink)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.titleSm),
                  Text(subtitle, style: AppTextStyles.labelMd),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!enabled)
              const Icon(Icons.lock_outline, color: AppColors.ink)
            else
              Pill(
                label: done ? 'Selesai' : 'Mulai',
                background: AppColors.accentGreen,
                foreground: AppColors.ink,
              ),
          ],
        ),
      ),
    );
  }
}
