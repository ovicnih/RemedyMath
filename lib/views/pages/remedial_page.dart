import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/models.dart';
import '../flows.dart';
import '../widgets/common.dart';

/// Materi perbaikan: video mikro-learning, poin kunci, dan post-test.
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
    await c.markWatched(n.id);
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Tidak dapat membuka YouTube. Periksa koneksi internet.'),
      ));
    }
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
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: <Widget>[
            Text(
              pos >= 0
                  ? '• LANGKAH ${pos + 1} DARI ${path.length}: PENGUATAN KONSEP'
                  : '• PENGUATAN KONSEP',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.accentBlue),
            ),
            const SizedBox(height: 4),
            Text('Materi Perbaikan: ${n.shortTitle}', style: AppTextStyles.titleLg),
            const SizedBox(height: 14),
            _VideoCard(node: n, watched: watched, onPlay: () => _openVideo(context, n)),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      const Pill(
                        label: 'Analisis Miskonsepsi',
                        background: AppColors.accentPink,
                        foreground: AppColors.ink,
                      ),
                      if (pos >= 0)
                        Text('Prioritas Remedial #${pos + 1}', style: AppTextStyles.labelMd),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(n.videoTitle, style: AppTextStyles.titleLg),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: <Widget>[
                        const CircleAvatar(
                          backgroundColor: AppColors.surface,
                          child: Icon(Icons.person, color: AppColors.accentBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(n.instructor, style: AppTextStyles.titleSm),
                              Text('${n.instructorRole} • Durasi: ${n.videoDurationLabel}',
                                  style: AppTextStyles.labelMd),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(n.summary,
                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openVideo(context, n),
                    icon: const Icon(Icons.smart_display, color: AppColors.accentPink),
                    label: const Text('Buka di Aplikasi YouTube'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SectionTitle(
                    'Poin Kunci Ketuntasan',
                    icon: Icons.fact_check_outlined,
                    trailing: Pill(label: 'Penting Diingat'),
                  ),
                  const SizedBox(height: 12),
                  for (final KeyPoint k in n.keyPoints)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.check_circle_outline, color: AppColors.accentGreen),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(k.title, style: AppTextStyles.titleSm),
                                const SizedBox(height: 4),
                                Text(k.detail,
                                    style: AppTextStyles.labelMd
                                        .copyWith(color: AppColors.ink)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                // Tanpa gradien (TASK 2.2). CTA utama warna kuning.
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: AppColors.ink.withAlpha(40),
                    child: const Icon(Icons.psychology_outlined, color: AppColors.ink),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Siap Uji Pemahaman?',
                            style: AppTextStyles.titleMd.copyWith(color: AppColors.ink)),
                        Text(
                          watched
                              ? 'Post-test dirancang adaptif $ptCount soal untuk memastikan tidak ada celah konsep yang tertinggal.'
                              : 'Tonton video terlebih dahulu untuk membuka post-test.',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink.withAlpha(220)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: watched && ptCount > 0 ? () => Flows.startPostTest(context, nodeId) : null,
              icon: Icon(watched ? Icons.arrow_forward : Icons.lock_outline),
              label: Text('Mulai Post-Test Ketuntasan ($ptCount Soal)'),
            ),
            if (!watched)
              TextButton(
                onPressed: () => c.markWatched(nodeId),
                child: const Text('Saya sudah menonton video ini'),
              ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.trending_up, size: 16, color: AppColors.accentBlue),
                SizedBox(width: 6),
                Flexible(
                  child: Text('Selesaikan post-test untuk memperbarui Skor Kemampuan IRT kamu',
                      textAlign: TextAlign.center, style: AppTextStyles.labelMd),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.node, required this.watched, required this.onPlay});
  final ConceptNode node;
  final bool watched;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final String caption =
        node.keyPoints.isNotEmpty ? node.keyPoints.first.detail : node.summary;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Material(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPlay,
          child: Container(
            decoration: const BoxDecoration(
              // Tanpa gradien (TASK 2.2).
              color: AppColors.accentGreen,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.circle, size: 8, color: AppColors.accentYellow),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('RemedyMath Micro-Learning',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
                    ),
                    if (watched)
                      const Pill(
                        label: 'Ditonton',
                        icon: Icons.check,
                        background: AppColors.accentGreen,
                        foreground: AppColors.ink,
                      ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (node.correctPattern.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FittedBox(
                              child: Text(node.correctPattern,
                                  style: AppTextStyles.mathDisplay
                                      .copyWith(color: AppColors.ink)),
                            ),
                          ),
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.ink,
                          child: Icon(Icons.play_arrow, size: 32, color: AppColors.ink),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withAlpha(150),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '"$caption"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
