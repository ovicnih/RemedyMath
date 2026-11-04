part of 'diagnosis_result_page.dart';

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

/// Rute Belajar Lengkap (audit §5–§7): satu bagian utama, tanpa kartu
/// video terpisah. Item menunjukkan status urutan (terkunki · belum
/// dimulai · video selesai · tuntas) dan sumber persentase (§7):
/// hasil post-test bila pernah dikerjakan, else penguasaan awal
/// (diagnostik), else "Belum dinilai".
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
          for (int i = 0; i < result.learningPath.length; i++)
            _RouteItem(
              controller: controller,
              result: result,
              nodeId: result.learningPath[i],
              step: i + 1,
              isRoot: result.learningPath[i] == root.id,
            ),
        ],
      ),
    );
  }
}

/// Satu baris rute: status urutan + sumber persentase + tindakan.
class _RouteItem extends StatelessWidget {
  const _RouteItem({
    required this.controller,
    required this.result,
    required this.nodeId,
    required this.step,
    required this.isRoot,
  });

  final AppController controller;
  final DiagnosticResult result;
  final String nodeId;
  final int step;
  final bool isRoot;

  @override
  Widget build(BuildContext context) {
    final ConceptNode? node = controller.graph.node(nodeId);
    final bool studied = controller.isStudied(nodeId);
    final RemedialSession? session = controller.sessionFor(nodeId);
    final bool finished = controller.isFinished(nodeId);
    final bool locked = !controller.isRouteUnlocked(nodeId);

    // (§7) Sumber persentase: hasil post-test > penguasaan awal
    // (diagnostik) > belum dinilai. 0% tetap tampil sebagai 0%.
    final String masteryLine;
    final double? barValue;
    if (session != null) {
      barValue = session.score / 100;
      masteryLine = 'Hasil post-test: ${session.score}% · '
          '${session.passed ? 'lulus' : 'belum lulus'}';
    } else if (result.nodeMastery[nodeId] != null) {
      barValue = result.nodeMastery[nodeId];
      masteryLine = 'Penguasaan awal: ${Formatters.percent(barValue!)}';
    } else {
      barValue = null;
      masteryLine = 'Belum dinilai';
    }

    final String statusLine;
    final IconData statusIcon;
    if (!studied) {
      statusLine = 'Belum dimulai';
      statusIcon = Icons.circle_outlined;
    } else if (finished) {
      statusLine = 'Tuntas';
      statusIcon = Icons.check_circle;
    } else {
      statusLine = 'Video selesai · menunggu post-test';
      statusIcon = Icons.hourglass_top;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMd),
      child: NeoCard(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        onTap: () => Flows.openRemedial(context, nodeId),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  locked ? AppColors.surface : AppColors.accentYellow,
              child: locked
                  ? const Icon(Icons.lock, size: 14, color: AppColors.ink)
                  : Text('$step', style: AppTextStyles.caption),
            ),
            const SizedBox(width: AppSizes.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    node?.title ?? nodeId,
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.spaceXs),
                  Text(statusLine, style: AppTextStyles.labelMd),
                  Text(
                    isRoot ? 'Akar masalah · $masteryLine' : masteryLine,
                    style: AppTextStyles.labelMd,
                  ),
                  if (barValue != null) ...<Widget>[
                    const SizedBox(height: AppSizes.spaceXs),
                    NeoProgressBar(
                      value: barValue,
                      height: 6,
                      color: barValue >= AppConstants.masteryRatio
                          ? AppColors.accentGreen
                          : AppColors.accentPink,
                    ),
                  ],
                ],
              ),
            ),
            Icon(statusIcon, size: 20, color: AppColors.ink),
          ],
        ),
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
