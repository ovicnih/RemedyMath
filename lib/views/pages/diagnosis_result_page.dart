import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
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
class DiagnosisResultPage extends StatefulWidget {
  const DiagnosisResultPage({super.key});

  @override
  State<DiagnosisResultPage> createState() => _DiagnosisResultPageState();
}

class _DiagnosisResultPageState extends State<DiagnosisResultPage> {
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
            _ScoreCard(controller: c, result: r),
            const SizedBox(height: AppSizes.spaceMd),
            _SummaryBentoRow(controller: c, result: r),
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
              _RouteCard(controller: c, result: r, root: root),
              const SizedBox(height: AppSizes.spaceLg),
              const _EncourageCard(),
            ],
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

/// §4.3 item 3: kartu skor diagnostik (audit §8).
///
/// Hierarki (audit §8): skor diagnostik `x/100`, jumlah benar, kesimpulan
/// sederhana. Skor = `(benar / total) × 100` dibulatkan — rumus tetap
/// [DiagnosticResult.accuracy], tidak dicampur dengan theta.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.controller, required this.result});

  final AppController controller;
  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    final int score = Formatters.score(result.accuracy);
    final bool strong = controller.irt.isMastered(result.theta);
    return NeoCard(
      color: AppColors.accentYellow,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('SKOR DIAGNOSTIK', style: AppTextStyles.eyebrow),
                    SizedBox(height: AppSizes.spaceXs),
                    Text(
                      'Hasil Evaluasi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLg,
                    ),
                  ],
                ),
              ),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: score),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (_, int value, __) =>
                    Text('$value/100', style: AppTextStyles.displayNum),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),
          NeoProgressBar(
            value: result.accuracy,
            height: 12,
            color: strong ? AppColors.accentGreen : AppColors.accentBlue,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          Pill(
            label: strong
                ? 'Konsep dasar sudah kuat'
                : 'Perlu penguatan konsep dasar',
            icon: strong ? Icons.verified_outlined : Icons.trending_up,
            background: strong ? AppColors.accentGreen : AppColors.accentPink,
            bordered: true,
          ),
        ],
      ),
    );
  }
}

/// 2-Kolom Bento Ringkasan: Soal Benar (kiri) & Skor IRT θ (kanan).
class _SummaryBentoRow extends StatelessWidget {
  const _SummaryBentoRow({required this.controller, required this.result});

  final AppController controller;
  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: NeoCard(
              color: AppColors.surface,
              borderWidth: AppSizes.borderThin,
              padding: const EdgeInsets.all(AppSizes.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('JAWABAN BENAR', style: AppTextStyles.eyebrow),
                  const SizedBox(height: AppSizes.spaceSm),
                  Text(
                    '${result.diagnosticCorrect}/${result.diagnosticTotal}',
                    style: AppTextStyles.displayNum,
                  ),
                  const Spacer(),
                  const SizedBox(height: AppSizes.spaceXs),
                  Text(
                    'Akurasi ${Formatters.percent(result.accuracy)}',
                    style: AppTextStyles.labelMd,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: NeoCard(
              color: AppColors.accentBlue,
              borderWidth: AppSizes.borderThin,
              padding: const EdgeInsets.all(AppSizes.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('SKOR IRT (θ)', style: AppTextStyles.eyebrow),
                  const SizedBox(height: AppSizes.spaceSm),
                  Text(
                    Formatters.theta(result.theta),
                    style: AppTextStyles.displayNum,
                  ),
                  const Spacer(),
                  const SizedBox(height: AppSizes.spaceXs),
                  Text(
                    '${controller.irt.levelLabel(result.theta)} · Estimasi adaptif',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
