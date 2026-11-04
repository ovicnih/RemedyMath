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

/// Halaman materi (audit §5): semua yang dibutuhkan mempelajari satu konsep
/// dalam satu tempat — video pembelajaran, ringkasan, rumus inti, poin
/// kunci, klik Mulai Post-Test, dan informasi hasil bila sudah pernah
/// dikerjakan. Diarahkan dari Rute Belajar Lengkap dan tab Remedial.
class RemedialPage extends StatelessWidget {
  const RemedialPage({super.key, required this.nodeId});
  final String nodeId;

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final ConceptNode? n = c.graph.node(nodeId);
    if (n == null) {
      return Scaffold(appBar: remediAppBar(context, 'Materi', showBack: true));
    }
    final List<String> path = c.latestResult?.learningPath ?? <String>[];
    final int pos = path.indexOf(nodeId);
    final bool studied = c.isStudied(nodeId);
    final RemedialSession? session = c.sessionFor(nodeId);
    final int ptCount = c.content.postTests[nodeId]?.length ?? 0;

    return Scaffold(
      appBar: remediAppBar(context, 'Materi', showBack: true),
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
            VideoLessonPlayer(
              nodeId: n.id,
              videoId: n.videoId,
              lessonTitle: n.lessonTitle,
              summary: n.summary,
              completed: studied,
              onCompleted: () => c.markStudied(n.id),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            KeyPointList(points: n.keyPoints),
            const SizedBox(height: AppSizes.spaceLg),
            if (!studied && (n.videoId == null || n.videoId!.isEmpty)) ...<Widget>[
              NeoButton(
                expand: true,
                icon: Icons.check_circle_outline,
                label: 'Tandai sudah dipelajari',
                onPressed: () => c.markStudied(n.id),
              ),
              const SizedBox(height: AppSizes.spaceLg),
            ],
            _PostTestCta(
              studied: studied,
              count: ptCount,
              session: session,
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

/// Header langkah: eyebrow langkah, judul bertitik pink, sub materi.
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

/// CTA post-test (audit §5–§6): terkunci sampai video selesai; setelah
/// post-test pernah dikerjakan, strip hasil menampilkan skor & status.
class _PostTestCta extends StatelessWidget {
  const _PostTestCta({
    required this.studied,
    required this.count,
    required this.session,
    required this.onStart,
  });

  final bool studied;
  final int count;
  final RemedialSession? session;
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
                : 'Tonton video sampai selesai untuk membuka post-test.',
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
          if (session != null) ...<Widget>[
            const SizedBox(height: AppSizes.spaceLg),
            _EstoResult(session: session!),
          ],
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

/// Strip hasil post-test terakhir di dalam CTA (audit §5 item 6).
class _EstoResult extends StatelessWidget {
  const _EstoResult({required this.session});

  final RemedialSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.accentYellow,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThin),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            session.passed
                ? Icons.verified_outlined
                : Icons.replay_circle_filled_outlined,
            size: 24,
            color: session.passed ? AppColors.accentGreen : AppColors.accentPink,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hasil post-test terakhir: ${session.score}%',
                  style: AppTextStyles.labelMd
                      .copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  session.passed
                      ? 'Tuntas (ambang 60% lulus) — materi sudah boleh '
                          'dilewati.'
                      : 'Belum tuntas (ambang 60%) — pelajari ulang lalu coba '
                          'lagi.',
                  style: AppTextStyles.labelMd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
