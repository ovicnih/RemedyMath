import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import '../../models/models.dart';
import '../flows.dart';
import '../widgets/common.dart';
import 'diagnosis_result_page.dart';

/// Materi perbaikan: kartu mikro-belajar (rumus + poin kunci) dan post-test.
///
/// Susunan visual mengikuti `UI-REFERENCE.md` §4.4. Fitur video YouTube
/// dilepas agar aplikasi sepenuhnya offline (lihat `HISTORY.md` v2.4.0);
/// penandaan "sudah dipelajari" kini lewat tombol eksplisit.
class RemedialPage extends StatelessWidget {
  const RemedialPage({super.key, required this.nodeId});
  final String nodeId;

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final ConceptNode? n = c.graph.node(nodeId);
    if (n == null) {
      return Scaffold(appBar: remediAppBar(context, 'Remedial', showBack: true));
    }
    final List<String> path = c.latestResult?.learningPath ?? <String>[];
    final int pos = path.indexOf(nodeId);
    final bool studied = c.isStudied(nodeId);
    final int ptCount = c.content.postTests[nodeId]?.length ?? 0;

    return Scaffold(
      appBar: remediAppBar(context, 'Remedial', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceLg,
            AppSizes.spaceLg,
            AppSizes.spaceLg,
            AppSizes.spaceXl,
          ),
          children: <Widget>[
            _StepHeading(
              label: pos >= 0
                  ? 'Langkah ${pos + 1} dari ${path.length} · Penguatan konsep'
                  : 'Penguatan konsep',
              title: n.shortTitle,
              subtitle: 'Materi perbaikan · ${c.content.topic}',
            ),
            const SizedBox(height: AppSizes.spaceLg),
            ConceptCard(
              formula: n.correctPattern,
              studied: studied,
            ),
            const SizedBox(height: AppSizes.spaceLg),
            _MisconceptionCard(node: n),
            const SizedBox(height: AppSizes.spaceLg),
            KeyPointList(points: n.keyPoints),
            const SizedBox(height: AppSizes.spaceLg),
            if (!studied) ...<Widget>[
              NeoButton(
                expand: true,
                icon: Icons.check_circle_outline,
                label: 'Tandai sudah dipelajari',
                onPressed: () => c.markStudied(nodeId),
              ),
              const SizedBox(height: AppSizes.spaceLg),
            ],
            _PostTestCta(
              studied: studied,
              count: ptCount,
              onStart: () => Flows.startPostTest(context, nodeId),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            const _IrtNote(),
            const SizedBox(height: AppSizes.spaceSm),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DiagnosisResultPage(),
                  ),
                ),
                child: Text(
                  'Lihat kembali hasil diagnosis',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// §4.4 item 1: eyebrow langkah, judul bertitik pink, dan sub materi.
class _StepHeading extends StatelessWidget {
  const _StepHeading({
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        EyebrowLabel(label: label),
        const SizedBox(height: AppSizes.spaceMd),
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(text: title),
              const TextSpan(
                text: '.',
                style: TextStyle(color: AppColors.accentPink),
              ),
            ],
          ),
          style: AppTextStyles.displayLg,
        ),
        const SizedBox(height: AppSizes.spaceXs),
        Text(
          subtitle,
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// §4.4 item 3 kiri: kartu analisis miskonsepsi putih.
class _MisconceptionCard extends StatelessWidget {
  const _MisconceptionCard({required this.node});

  final ConceptNode node;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const EyebrowLabel(
            label: 'Analisis miskonsepsi',
            color: AppColors.accentPink,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          Text(node.lessonTitle, style: AppTextStyles.titleMd),
          const SizedBox(height: AppSizes.spaceSm),
          Text(node.summary, style: AppTextStyles.bodyMd.copyWith(height: 1.74)),
        ],
      ),
    );
  }
}

/// §4.4 item 4: CTA post-test pink.
class _PostTestCta extends StatelessWidget {
  const _PostTestCta({
    required this.studied,
    required this.count,
    required this.onStart,
  });

  final bool studied;
  final int count;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.accentPink,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Siap uji pemahaman?', style: AppTextStyles.titleMd),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            studied
                ? 'Post-test adaptif $count soal memastikan tidak ada celah '
                    'konsep yang tertinggal.'
                : 'Pelajari konsep inti terlebih dahulu untuk membuka post-test.',
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: AppSizes.spaceLg),
          NeoButton(
            expand: true,
            color: AppColors.surface,
            icon: studied ? Icons.arrow_forward : Icons.lock_outline,
            label: 'Mulai post-test',
            onPressed: studied && count > 0 ? onStart : null,
          ),
        ],
      ),
    );
  }
}

/// Catatan IRT di bawah CTA.
class _IrtNote extends StatelessWidget {
  const _IrtNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.trending_up, size: 16, color: AppColors.accentBlue),
        SizedBox(width: AppSizes.spaceSm),
        Flexible(
          child: Text(
            'Selesaikan post-test untuk memperbarui Skor Kemampuan IRT kamu',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMd,
          ),
        ),
      ],
    );
  }
}
