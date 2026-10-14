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
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: <Widget>[
            EyebrowLabel(
              label: pos >= 0
                  ? 'Langkah ${pos + 1} dari ${path.length}: Penguatan Konsep'
                  : 'Penguatan Konsep',
            ),
            const SizedBox(height: 4),
            Text('Materi Perbaikan: ${n.shortTitle}', style: AppTextStyles.titleLg),
            const SizedBox(height: 14),
            VideoPlayerCard(
              formula: n.correctPattern,
              watched: watched,
              onPlay: () => _openVideo(context, n),
            ),
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
            KeyPointList(
              points: n.keyPoints,
              trailing: const Pill(label: 'Penting Diingat'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // Tanpa gradien (TASK 2.2). CTA utama warna kuning.
        color: AppColors.accentYellow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppSizes.shadowCard,
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
            NeoButton(
              expand: true,
              color: AppColors.surface,
              icon: watched ? Icons.arrow_forward : Icons.lock_outline,
              label: 'Mulai Post-Test Ketuntasan ($ptCount Soal)',
              onPressed: watched && ptCount > 0
                  ? () => Flows.startPostTest(context, nodeId)
                  : null,
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
