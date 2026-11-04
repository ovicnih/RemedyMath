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
            _ThetaNoteCard(controller: c, result: r),
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
      color: AppColors.accentBlue,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Skor diagnostik',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLg,
                ),
              ),
              Text('$score/100', style: AppTextStyles.displayNum),
            ],
          ),
          const SizedBox(height: AppSizes.spaceXs),
          Text(
            '${result.diagnosticCorrect} dari '
            '${result.diagnosticTotal} soal benar',
            style: AppTextStyles.labelMd,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          NeoProgressBar(value: result.accuracy, height: 12),
          const SizedBox(height: AppSizes.spaceMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceMd,
              vertical: AppSizes.spaceXs,
            ),
            decoration: BoxDecoration(
              color: strong ? AppColors.accentGreen : AppColors.accentPink,
              borderRadius: AppSizes.radius(AppSizes.radiusChip),
              border: Border.all(
                  color: AppColors.ink, width: AppSizes.borderThin),
            ),
            child: Text(
              strong
                  ? 'Konsep dasar sudah kuat'
                  : 'Perlu penguatan konsep dasar',
              style:
                  AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

/// Informasi tambahan θ (audit §8): tetap akurat, disertai penjelasan
/// singkat, tidak lagi menjadi kartu utama.
class _ThetaNoteCard extends StatelessWidget {
  const _ThetaNoteCard({required this.controller, required this.result});

  final AppController controller;
  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    final double fraction = ((result.theta + 3) / 6).clamp(0.0, 1.0);
    final TextStyle scale =
        AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900);
    return NeoCard(
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'θ = ${Formatters.theta(result.theta)} · '
            '${controller.irt.levelLabel(result.theta)}',
            style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSizes.spaceXs),
          const Text(
            'Theta adalah estimasi kemampuan berdasarkan model IRT. '
            'Nilai negatif bukan berarti poinmu dikurangi.',
            style: AppTextStyles.labelMd,
          ),
          const SizedBox(height: AppSizes.spaceSm),
          NeoProgressBar(value: fraction, height: 10),
          const SizedBox(height: AppSizes.spaceSm),
          Row(
            children: <Widget>[
              Expanded(child: Text('Perlu pendampingan', style: scale)),
              Expanded(
                child: Text('Mandiri', textAlign: TextAlign.end, style: scale),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
