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

/// §4.3 item 6: kartu rencana belajar kuning.
class _StudyPlanCard extends StatelessWidget {
  const _StudyPlanCard({
    required this.controller,
    required this.root,
    required this.watched,
  });

  final AppController controller;
  final ConceptNode root;
  final bool watched;

  @override
  Widget build(BuildContext context) {
    final int postCount = controller.content.postTests[root.id]?.length ?? 5;
    return NeoCard(
      color: AppColors.accentYellow,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionTitle(
            'Rencana belajar cepat tuntas',
            icon: Icons.checklist,
            style: AppTextStyles.titleMd,
            trailing: Text(
              '${watched ? 2 : 1}/2 Langkah',
              style: AppTextStyles.labelMd,
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),
          _StepTile(
            marker: 'LANGKAH 01',
            title: 'Tonton konsep inti',
            subtitle: 'Video singkat · ${root.videoDurationLabel}',
            done: watched,
            enabled: true,
            onTap: () => Flows.openRemedial(context, root.id),
          ),
          const SizedBox(height: AppSizes.spaceMd),
          _StepTile(
            marker: 'LANGKAH 02',
            title: 'Kerjakan post-test',
            subtitle: watched
                ? '$postCount soal setelah video selesai'
                : 'Buka setelah video selesai',
            done: false,
            enabled: watched,
            onTap: () => Flows.startPostTest(context, root.id),
          ),
          const SizedBox(height: AppSizes.spaceLg),
          NeoButton(
            expand: true,
            color: AppColors.surface,
            icon: Icons.arrow_forward,
            label: 'Mulai belajar',
            onPressed: () => Flows.openRemedial(context, root.id),
          ),
        ],
      ),
    );
  }
}

/// Kartu langkah putih tanpa bayangan: marker + judul + sub.
class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.marker,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.enabled,
    required this.onTap,
  });

  final String marker;
  final String title;
  final String subtitle;
  final bool done;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IconData state = !enabled
        ? Icons.lock_outline
        : done
            ? Icons.check_circle
            : Icons.chevron_right;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSizes.radius(AppSizes.radiusCard),
          border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
        ),
        child: InkWell(
          borderRadius: AppSizes.radius(AppSizes.radiusCard),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(marker, style: AppTextStyles.eyebrow),
                      const SizedBox(height: AppSizes.spaceXs),
                      Text(title, style: AppTextStyles.titleSm),
                      Text(subtitle, style: AppTextStyles.labelSm),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Icon(state, color: AppColors.ink),
              ],
            ),
          ),
        ),
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
  const _EncourageCard({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        children: <Widget>[
          const Icon(Icons.psychology_alt_outlined,
              size: 24, color: AppColors.accentBlue),
          const SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Normal & wajar!', style: AppTextStyles.titleSm),
                Text(
                  'Banyak siswa kelas 10 mengalami kendala serupa di awal '
                  'semester. Tuntaskan dalam $minutes menit ke depan.',
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
