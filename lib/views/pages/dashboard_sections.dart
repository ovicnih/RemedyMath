part of 'dashboard_page.dart';

/// Sapaan Swiss ringkas tanpa tombol duplikat.
class _SwissGreeting extends StatelessWidget {
  const _SwissGreeting({
    required this.name,
    required this.hasResult,
  });

  final String name;
  final bool hasResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(text: 'Halo, $name'),
              const TextSpan(
                text: '!',
                style: TextStyle(color: AppColors.accentPink),
              ),
            ],
          ),
          style: AppTextStyles.displayLg,
        ),
        const SizedBox(height: AppSizes.spaceXs),
        Text(
          hasResult
              ? 'Lanjutkan rute remedialmu atau cek progres belajar.'
              : 'Mulai dengan tes diagnostik singkat untuk petakan kelemahanmu.',
          style: AppTextStyles.bodyMd,
        ),
      ],
    );
  }
}

/// Satu Hero Bento Card dominan warna Lime (#E2F16D) yang adaptif.
class _HeroBentoCta extends StatelessWidget {
  const _HeroBentoCta({
    required this.result,
    required this.nextNode,
    required this.questionCount,
    required this.durationMinutes,
    required this.onStartDiagnostic,
    required this.onOpenRemedial,
  });

  final DiagnosticResult? result;
  final ConceptNode? nextNode;
  final int questionCount;
  final int durationMinutes;
  final VoidCallback onStartDiagnostic;
  final VoidCallback? onOpenRemedial;

  @override
  Widget build(BuildContext context) {
    final bool hasRemedial = result != null && nextNode != null;
    final bool allDone = result != null && nextNode == null;

    final String eyebrow = hasRemedial
        ? 'Lanjutkan Remedial'
        : (allDone ? 'Semua Konsep Tuntas' : 'Langkah Pertama');
    final String title = hasRemedial
        ? nextNode!.lessonTitle
        : (allDone
            ? 'Semua materi dasar sudah dikuasai!'
            : 'Tes Diagnostik Adaptif');
    final String subtitle = hasRemedial
        ? '${nextNode!.keyPoints.length} poin kunci · Video pembelajaran & post-test'
        : (allDone
            ? 'Pertahankan penguasaanmu atau ulangi diagnostik untuk evaluasi baru.'
            : '$questionCount soal pilihan ganda · $durationMinutes menit · Model IRT');

    return NeoCard(
      color: AppColors.accentYellow,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: EyebrowLabel(
              label: eyebrow,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),
          Text(title, style: AppTextStyles.titleLg),
          const SizedBox(height: AppSizes.spaceXs),
          Text(subtitle, style: AppTextStyles.bodyMd),
          const SizedBox(height: AppSizes.spaceLg),
          NeoButton(
            expand: true,
            color: AppColors.surface,
            icon: hasRemedial ? Icons.arrow_forward : Icons.play_arrow,
            label: hasRemedial
                ? 'Buka Materi Sekarang'
                : (allDone ? 'Ulangi Diagnostik' : 'Mulai Tes Diagnostik'),
            onPressed: hasRemedial ? onOpenRemedial : onStartDiagnostic,
          ),
          if (hasRemedial) ...<Widget>[
            const SizedBox(height: AppSizes.spaceXs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onStartDiagnostic,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Ulangi diagnostik'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 2×2 Playful Bento Stat Grid dengan angka besar Swiss Grid.
class _BentoStatsGrid extends StatelessWidget {
  const _BentoStatsGrid({
    required this.controller,
    required this.result,
    required this.root,
    required this.passedCount,
    required this.totalNodes,
  });

  final AppController controller;
  final DiagnosticResult? result;
  final ConceptNode? root;
  final int passedCount;
  final int totalNodes;

  @override
  Widget build(BuildContext context) {
    final DiagnosticResult? r = result;
    final double ratio = totalNodes == 0 ? 0 : passedCount / totalNodes;

    return Column(
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: NeoCard(
                  color: AppColors.accentBlue,
                  padding: const EdgeInsets.all(AppSizes.spaceLg),
                  onTap: () => controller.setTab(3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('SKOR IRT (θ)', style: AppTextStyles.eyebrow),
                      const SizedBox(height: AppSizes.spaceSm),
                      Text(
                        r == null ? '–' : Formatters.theta(r.theta),
                        style: AppTextStyles.displayNum,
                      ),
                      const Spacer(),
                      const SizedBox(height: AppSizes.spaceXs),
                      Text(
                        r == null
                            ? 'Belum dinilai'
                            : controller.irt.proficiencyLabel(r.theta),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMd,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceMd),
              Expanded(
                child: NeoCard(
                  color: AppColors.accentGreen,
                  padding: const EdgeInsets.all(AppSizes.spaceLg),
                  onTap: () => controller.setTab(2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('MATERI TUNTAS', style: AppTextStyles.eyebrow),
                      const SizedBox(height: AppSizes.spaceSm),
                      Text(
                        '$passedCount/$totalNodes',
                        style: AppTextStyles.displayNum,
                      ),
                      const Spacer(),
                      const SizedBox(height: AppSizes.spaceSm),
                      NeoProgressBar(
                        value: ratio,
                        height: 10,
                        color: AppColors.accentYellow,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spaceMd),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: NeoCard(
                  color: root != null ? AppColors.accentPink : AppColors.surface,
                  borderWidth:
                      root != null ? AppSizes.borderThick : AppSizes.borderThin,
                  padding: const EdgeInsets.all(AppSizes.spaceLg),
                  onTap: root == null
                      ? null
                      : () => Flows.openRemedial(context, root!.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('AKAR MASALAH', style: AppTextStyles.eyebrow),
                      const SizedBox(height: AppSizes.spaceSm),
                      Text(
                        root?.shortTitle ??
                            (r == null ? 'Belum dicek' : 'Tidak ada'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMd,
                      ),
                      const Spacer(),
                      const SizedBox(height: AppSizes.spaceXs),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              root != null ? 'Buka materi' : 'Siap lanjut',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ),
                          if (root != null)
                            const Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: AppColors.ink,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceMd),
              Expanded(
                child: NeoCard(
                  color: AppColors.surface,
                  borderWidth: AppSizes.borderThin,
                  padding: const EdgeInsets.all(AppSizes.spaceLg),
                  onTap: r == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const DiagnosisResultPage(),
                            ),
                          ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('SKOR TERAKHIR', style: AppTextStyles.eyebrow),
                      const SizedBox(height: AppSizes.spaceSm),
                      Text(
                        r == null
                            ? '–'
                            : '${Formatters.score(r.accuracy)}/100',
                        style: AppTextStyles.titleLg,
                      ),
                      const Spacer(),
                      const SizedBox(height: AppSizes.spaceXs),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              r == null
                                  ? 'Belum ada tes'
                                  : Formatters.shortDate(r.date),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ),
                          if (r != null)
                            const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: AppColors.ink,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Riwayat sesi remedial terbaru (maksimal 3 entri di Beranda).
class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final List<RemedialSession> recent = controller.sessions.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionTitle('Riwayat Belajar', icon: Icons.history),
        const SizedBox(height: AppSizes.spaceMd),
        if (recent.isEmpty)
          const EmptyState(
            icon: Icons.history_edu,
            title: 'Belum ada riwayat sesi',
            message: 'Sesi post-test remedial yang kamu selesaikan akan tampil di sini.',
          )
        else
          for (final RemedialSession s in recent)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceMd),
              child: SessionTile(
                title: s.title,
                dateLabel: Formatters.shortDate(s.date),
                subtitle: s.label,
                score: s.score,
                passed: s.passed,
                onAction: () => Flows.openRemedial(context, s.nodeId),
              ),
            ),
      ],
    );
  }
}
