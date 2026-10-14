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
import 'review_page.dart';

part 'diagnosis_result_sections.dart';

/// Halaman hasil diagnosis, mengikuti `UI-REFERENCE.md` §4.3.
///
/// Fitur yang tidak muncul di mockup tetap dipertahankan (`UI-REFERENCE.md`
/// §7): rute belajar lengkap, kartu penguatan, dan tombol menuju halaman
/// pembahasan (`review_page.dart`).
///
/// Seksi berat dipisah ke `diagnosis_result_sections.dart` supaya tiap
/// berkas tetap di bawah batas 500 baris (`AGENTS.md` §5).
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
          padding: EdgeInsets.all(AppSizes.spaceLg),
          child: EmptyState(
            icon: Icons.assignment_outlined,
            title: 'Belum ada hasil',
            message: 'Kerjakan tes diagnostik terlebih dahulu.',
          ),
        ),
      );
    }
    final ConceptNode? root = c.rootCause;
    final bool studied = root != null && c.isStudied(root.id);

    return Scaffold(
      appBar: remediAppBar(context, 'Hasil Diagnosis', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceLg,
            AppSizes.spaceLg,
            AppSizes.spaceLg,
            AppSizes.spaceXl,
          ),
          children: <Widget>[
            const _Heading(),
            const SizedBox(height: AppSizes.spaceLg),
            _ThetaCard(controller: c, result: r),
            const SizedBox(height: AppSizes.spaceLg),
            _StatsRow(result: r),
            const SizedBox(height: AppSizes.spaceLg),
            if (root == null)
              const EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'Tidak ada akar masalah',
                message: 'Seluruh sub-konsep sudah dikuasai (≥ 60%). '
                    'Pertahankan dan lanjutkan ke materi berikutnya!',
              )
            else ...<Widget>[
              _RootCauseCard(controller: c, root: root),
              const SizedBox(height: AppSizes.spaceLg),
              _StudyPlanCard(controller: c, root: root, studied: studied),
              if (r.learningPath.length > 1) ...<Widget>[
                const SizedBox(height: AppSizes.spaceLg),
                _RouteCard(controller: c, result: r, root: root),
              ],
              const SizedBox(height: AppSizes.spaceLg),
              const _EncourageCard(),
            ],
            const SizedBox(height: AppSizes.spaceLg),
            NeoButton(
              expand: true,
              color: AppColors.surface,
              icon: Icons.fact_check_outlined,
              label: 'Lihat pembahasan lengkap soal',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ReviewPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// §4.3 item 1–2: eyebrow dan judul bertitik pink.
class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        EyebrowLabel(label: 'Analisis diagnostik'),
        SizedBox(height: AppSizes.spaceMd),
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(text: 'Peta kemampuanmu'),
              TextSpan(
                text: '.',
                style: TextStyle(color: AppColors.accentPink),
              ),
            ],
          ),
          style: AppTextStyles.displayLg,
        ),
      ],
    );
  }
}

/// §4.3 item 3: kartu theta biru.
class _ThetaCard extends StatelessWidget {
  const _ThetaCard({required this.controller, required this.result});

  final AppController controller;
  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    final double fraction = ((result.theta + 3) / 6).clamp(0.0, 1.0);
    final TextStyle scale =
        AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900);
    return NeoCard(
      color: AppColors.accentBlue,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _StatusChip(mastered: controller.irt.isMastered(result.theta)),
          const SizedBox(height: AppSizes.spaceMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Skor kemampuan (θ)',
                        style: AppTextStyles.titleLg),
                    const SizedBox(height: AppSizes.spaceXs),
                    Text(
                      '${controller.content.topic} · '
                      '${result.diagnosticTotal} soal selesai',
                      style: AppTextStyles.labelMd,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spaceMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(Formatters.theta(result.theta),
                      style: AppTextStyles.displayNum),
                  Text(controller.irt.levelLabel(result.theta),
                      style: AppTextStyles.labelMd),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLg),
          NeoProgressBar(value: fraction, height: 20),
          const SizedBox(height: AppSizes.spaceSm),
          Row(
            children: <Widget>[
              Expanded(child: Text('Perlu pendampingan', style: scale)),
              Expanded(
                child: Text('Mandiri',
                    textAlign: TextAlign.end, style: scale),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chip status di dalam kartu theta.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.mastered});

  final bool mastered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceXs,
      ),
      decoration: BoxDecoration(
        color: mastered ? AppColors.accentGreen : AppColors.accentPink,
        borderRadius: AppSizes.radius(AppSizes.radiusChip),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            mastered ? Icons.check_circle_outline : Icons.tune,
            size: 16,
            color: AppColors.ink,
          ),
          const SizedBox(width: AppSizes.spaceXs),
          Text(
            mastered ? 'Tuntas' : 'Perlu penguatan',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
