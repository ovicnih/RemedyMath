import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import '../../models/models.dart';
import '../flows.dart';
import '../widgets/common.dart';
import 'diagnosis_result_page.dart';

/// Materi perbaikan: video mikro-learning, poin kunci, dan post-test.
///
/// Susunan visual mengikuti `UI-REFERENCE.md` §4.4. Tombol buka YouTube dan
/// tombol "Saya sudah menonton video ini" tetap dipertahankan (§7).
class RemedialPage extends StatelessWidget {
  const RemedialPage({super.key, required this.nodeId});
  final String nodeId;

  Future<void> _openVideo(BuildContext context, ConceptNode n) async {
    final AppController c = context.read<AppController>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final Uri uri = Uri.parse(n.videoUrl);
    bool ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    // Hanya tandai ditonton kalau video benar-benar terbuka. Versi lama
    // menandainya tanpa syarat, sehingga post-test tetap terbuka walau
    // YouTube tidak pernah dibuka — lihat `TODO.md` "Perbaiki penandaan
    // video yang terlalu optimistis".
    if (ok) {
      await c.markWatched(n.id);
      return;
    }
    messenger.showSnackBar(const SnackBar(
      content: Text('Tidak dapat membuka YouTube. Periksa koneksi internet.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final ConceptNode? n = c.graph.node(nodeId);
    if (n == null) {
      return Scaffold(appBar: remediAppBar(context, 'Remedial', showBack: true));
    }
    final List<String> path = c.latestResult?.learningPath ?? <String>[];
    final int pos = path.indexOf(nodeId);
    final bool watched = c.isWatched(nodeId);
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
            VideoPlayerCard(
              formula: n.correctPattern,
              watched: watched,
              onPlay: () => _openVideo(context, n),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            _MisconceptionCard(
              node: n,
              onYouTube: () => _openVideo(context, n),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            KeyPointList(points: n.keyPoints),
            const SizedBox(height: AppSizes.spaceLg),
            _PostTestCta(
              watched: watched,
              count: ptCount,
              onStart: () => Flows.startPostTest(context, nodeId),
            ),
            if (!watched)
              TextButton(
                onPressed: () => c.markWatched(nodeId),
                child: const Text('Saya sudah menonton video ini'),
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
  const _MisconceptionCard({required this.node, required this.onYouTube});

  final ConceptNode node;
  final VoidCallback onYouTube;

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
          Text(node.videoTitle, style: AppTextStyles.titleMd),
          const SizedBox(height: AppSizes.spaceSm),
          Text(node.summary, style: AppTextStyles.bodyMd.copyWith(height: 1.74)),
          const SizedBox(height: AppSizes.spaceLg),
          _CoachChip(node: node),
          const SizedBox(height: AppSizes.spaceSm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onYouTube,
              icon: const Icon(Icons.smart_display, size: 18),
              label: const Text('Buka di YouTube'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip pengajar: bg biru, radius 10, border 3 px, teks 14 w700.
class _CoachChip extends StatelessWidget {
  const _CoachChip({required this.node});

  final ConceptNode node;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.accentBlue,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.person, size: 20, color: AppColors.ink),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              '${node.instructor} · ${node.instructorRole} · '
              '${node.videoDurationLabel}',
              style: AppTextStyles.labelMd,
            ),
          ),
        ],
      ),
    );
  }
}

/// §4.4 item 4: CTA post-test pink.
class _PostTestCta extends StatelessWidget {
  const _PostTestCta({
    required this.watched,
    required this.count,
    required this.onStart,
  });

  final bool watched;
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
            watched
                ? 'Post-test adaptif $count soal memastikan tidak ada celah '
                    'konsep yang tertinggal.'
                : 'Tonton video terlebih dahulu untuk membuka post-test.',
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: AppSizes.spaceLg),
          NeoButton(
            expand: true,
            color: AppColors.surface,
            icon: watched ? Icons.arrow_forward : Icons.lock_outline,
            label: 'Mulai post-test',
            onPressed: watched && count > 0 ? onStart : null,
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
