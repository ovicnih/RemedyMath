part of 'diagnosis_result_page.dart';

/// §4.3 item 4: tiga stat card kuning/pink/hijau.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.result});

  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: StatCard(
            color: AppColors.accentYellow,
            value: '${result.diagnosticTotal}',
            label: 'Soal selesai',
            valueStyle: AppTextStyles.statValue,
            labelStyle: AppTextStyles.labelMd,
          ),
        ),
        const SizedBox(width: AppSizes.spaceLg),
        Expanded(
          child: StatCard(
            color: AppColors.accentPink,
            value: Formatters.percent(result.accuracy),
            label: 'Akurasi',
            valueStyle: AppTextStyles.statValue,
            labelStyle: AppTextStyles.labelMd,
          ),
        ),
        const SizedBox(width: AppSizes.spaceLg),
        Expanded(
          child: StatCard(
            color: AppColors.accentGreen,
            value: Formatters.theta(result.theta),
            label: 'Skor theta',
            valueStyle: AppTextStyles.statValue,
            labelStyle: AppTextStyles.labelMd,
          ),
        ),
      ],
    );
  }
}

/// §4.3 item 5: kartu akar masalah, callout konsep, dan dua pola.
class _RootCauseCard extends StatelessWidget {
  const _RootCauseCard({required this.controller, required this.root});

  final AppController controller;
  final ConceptNode root;

  @override
  Widget build(BuildContext context) {
    final List<ConceptNode> chain = controller.graph.chainTo(root.id);
    return NeoCard(
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SectionTitle(
            'Akar masalah terdeteksi',
            icon: Icons.troubleshoot,
            style: AppTextStyles.titleMd,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(
              color: AppColors.accentYellow,
              borderRadius: AppSizes.radius(AppSizes.radiusCard),
              border:
                  Border.all(color: AppColors.ink, width: AppSizes.borderThick),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('KONSEP SPESIFIK', style: AppTextStyles.eyebrow),
                const SizedBox(height: AppSizes.spaceXs),
                Text(root.title, style: AppTextStyles.titleMd),
                if (chain.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSizes.spaceMd),
                  Wrap(
                    spacing: AppSizes.spaceSm,
                    runSpacing: AppSizes.spaceSm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      for (int i = 0; i < chain.length; i++) ...<Widget>[
                        Pill(
                          label: chain[i].shortTitle,
                          background: AppColors.surface,
                        ),
                        if (i < chain.length - 1)
                          const Icon(Icons.chevron_right,
                              size: 16, color: AppColors.ink),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceLg),
          const Text('Analisis cara berpikirmu', style: AppTextStyles.titleSm),
          const SizedBox(height: AppSizes.spaceXs),
          Text(root.misconception, style: AppTextStyles.bodyMd),
          const SizedBox(height: AppSizes.spaceLg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _PatternPanel(correct: false, text: root.wrongPattern),
              ),
              const SizedBox(width: AppSizes.spaceLg),
              Expanded(
                child: _PatternPanel(correct: true, text: root.correctPattern),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Panel pola keliru (pink) dan solusi tepat (hijau), tanpa bayangan.
class _PatternPanel extends StatelessWidget {
  const _PatternPanel({required this.correct, required this.text});

  final bool correct;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: correct ? AppColors.accentGreen : AppColors.accentPink,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(correct ? Icons.check : Icons.close,
                  size: 18, color: AppColors.ink),
              const SizedBox(width: AppSizes.spaceXs),
              Flexible(
                child: Text(
                  correct ? 'Solusi tepat' : 'Pola keliru',
                  style: AppTextStyles.labelMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            text,
            style: AppTextStyles.mathInline.copyWith(
              decoration: correct ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}

/// §4.3 item 6: kartu video pembelajaran (menggantikan rencana belajar).
class _VideoLessonCard extends StatefulWidget {
  const _VideoLessonCard({
    required this.controller,
    required this.root,
    required this.studied,
    required this.onVideoCompleted,
  });

  final AppController controller;
  final ConceptNode root;
  final bool studied;
  final VoidCallback onVideoCompleted;

  @override
  State<_VideoLessonCard> createState() => _VideoLessonCardState();
}

class _VideoLessonCardState extends State<_VideoLessonCard> {
  late final YoutubePlayerController _videoController;
  bool _videoCompleted = false;
  Timer? _stateCheckTimer;

  @override
  void initState() {
    super.initState();
    final String? videoId = widget.root.videoId;
    _videoController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
    if (videoId != null && videoId.isNotEmpty) {
      _videoController.loadVideoById(videoId: videoId);
    }
    _startStateChecking();
  }

  void _startStateChecking() {
    _stateCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_videoCompleted &&
          _videoController.value.playerState == PlayerState.ended) {
        timer.cancel();
        setState(() => _videoCompleted = true);
        // Mark as studied when video ends
        widget.controller.markStudied(widget.root.id);
        // Notify parent to rebuild
        widget.onVideoCompleted();
      }
    });
  }

  @override
  void dispose() {
    _stateCheckTimer?.cancel();
    _videoController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int postCount = widget.controller.content.postTests[widget.root.id]?.length ?? 5;
    final String? videoId = widget.root.videoId;
    final bool isStudied = widget.studied || _videoCompleted;

    return NeoCard(
      color: AppColors.accentYellow,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionTitle(
            'Video pembelajaran',
            icon: Icons.play_circle_outline,
            style: AppTextStyles.titleMd,
            trailing: videoId != null
                ? const _VideoBadge()
                : Text(
                    'Video belum tersedia',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.ink.withValues(alpha: 0.6)),
                  ),
          ),
          const SizedBox(height: AppSizes.spaceMd),
          if (videoId != null) ...<Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: AppSizes.radius(AppSizes.radiusCard),
                child: YoutubePlayer(
                  controller: _videoController,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              widget.root.lessonTitle,
              style: AppTextStyles.titleSm,
            ),
            const SizedBox(height: AppSizes.spaceXs),
            Text(
              widget.root.summary,
              style: AppTextStyles.bodyMd,
            ),
            if (_videoCompleted) ...<Widget>[
              const SizedBox(height: AppSizes.spaceMd),
              const Text(
                '✓ Video selesai ditonton! Post-test sudah bisa dibuka.',
                style: AppTextStyles.labelMd,
                textAlign: TextAlign.center,
              ),
            ],
          ] else ...<Widget>[
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSizes.radius(AppSizes.radiusCard),
                border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.video_library_outlined, size: 48, color: AppColors.ink),
                    SizedBox(height: 8),
                    Text('Video belum ditautkan untuk konsep ini', style: AppTextStyles.bodyMd),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spaceLg),
          // CTA Post-test
          NeoCard(
            color: AppColors.accentPink,
            padding: const EdgeInsets.all(AppSizes.spaceXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('Siap uji pemahaman?', style: AppTextStyles.titleMd),
                const SizedBox(height: AppSizes.spaceSm),
                Text(
                  isStudied
                      ? 'Post-test adaptif $postCount soal memastikan tidak ada celah konsep yang tertinggal.'
                      : 'Tonton video sampai selesai untuk membuka post-test.',
                  style: AppTextStyles.bodyMd,
                ),
                const SizedBox(height: AppSizes.spaceLg),
                NeoButton(
                  expand: true,
                  color: AppColors.surface,
                  icon: isStudied ? Icons.arrow_forward : Icons.lock_outline,
                  label: 'Mulai post-test',
                  onPressed: isStudied && postCount > 0
                      ? () => Flows.startPostTest(context, widget.root.id)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge kecil "Video" di sebelah judul.
class _VideoBadge extends StatelessWidget {
  const _VideoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentBlue,
        borderRadius: AppSizes.radius(AppSizes.radiusChip),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.play_arrow, size: 12, color: AppColors.ink),
          const SizedBox(width: AppSizes.spaceXs),
          Text('Video', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

/// Fitur lama yang dipertahankan (§7): rute belajar lengkap.
class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.controller,
    required this.result,
    required this.root,
  });

  final AppController controller;
  final DiagnosticResult result;
  final ConceptNode root;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle(
            'Rute belajar lengkap',
            icon: Icons.route,
            style: AppTextStyles.titleMd,
          ),
          const SizedBox(height: AppSizes.spaceSm),
          for (final String id in result.learningPath)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                id == root.id ? Icons.flag : Icons.circle_outlined,
                color: id == root.id ? AppColors.accentPink : AppColors.ink,
              ),
              title: Text(
                controller.graph.node(id)?.title ?? id,
                style: AppTextStyles.bodyMd,
              ),
              subtitle: Text(
                'Penguasaan ${Formatters.percent(result.nodeMastery[id] ?? 0)}',
                style: AppTextStyles.labelMd,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Flows.openRemedial(context, id),
            ),
        ],
      ),
    );
  }
}

/// Fitur lama yang dipertahankan (§7): kartu penguatan.
class _EncourageCard extends StatelessWidget {
  const _EncourageCard();

  @override
  Widget build(BuildContext context) {
    return const NeoCard(
      child: Row(
        children: <Widget>[
          Icon(Icons.psychology_alt_outlined,
              size: 24, color: AppColors.accentBlue),
          SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Normal & wajar!', style: AppTextStyles.titleSm),
                Text(
                  'Banyak siswa kelas 10 mengalami kendala serupa di awal '
                  'semester. Pelajari rumus inti dan poin kuncinya, lalu uji '
                  'dengan post-test.',
                  style: AppTextStyles.bodyMd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
