import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../flows.dart';
import '../widgets/common.dart';

/// Tab Remedial: rute belajar personal dan peta materi.
class RemedialTabPage extends StatelessWidget {
  const RemedialTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final DiagnosticResult? r = c.latestResult;
    final List<String> path = r?.learningPath ?? <String>[];

    return Scaffold(
      appBar: remediAppBar(context, 'Remedial'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: <Widget>[
            const SectionTitle('Rute Belajar Personal', icon: Icons.route),
            const SizedBox(height: 10),
            if (r == null)
              EmptyState(
                icon: Icons.assignment_outlined,
                title: 'Belum ada rute belajar',
                message: 'Kerjakan tes diagnostik agar RemedyMath dapat menyusun rute remedialmu.',
                action: NeoButton(
                  expand: true,
                  icon: Icons.play_arrow,
                  label: 'Mulai Tes Diagnostik',
                  onPressed: () => Flows.startDiagnostic(context),
                ),
              )
            else if (path.isEmpty)
              const EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'Semua konsep tuntas!',
                message: 'Tidak ada materi yang perlu diremedial saat ini.',
              )
            else
              for (int i = 0; i < path.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NodeTile(
                    node: c.graph.node(path[i])!,
                    mastery: r.nodeMastery[path[i]],
                    step: i + 1,
                    isRoot: path[i] == r.rootCauseId,
                    watched: c.isWatched(path[i]),
                  ),
                ),
            const SizedBox(height: 16),
            const SectionTitle('Peta Materi (Knowledge Graph)', icon: Icons.hub_outlined),
            const SizedBox(height: 4),
            Text(c.content.chapter,
                style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
            const SizedBox(height: 10),
            for (final ConceptNode n in c.graph.ordered)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _NodeTile(
                  node: n,
                  mastery: r?.nodeMastery[n.id],
                  watched: c.isWatched(n.id),
                  prerequisites: n.prerequisites
                      .map((p) => c.graph.node(p)?.shortTitle ?? p)
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  const _NodeTile({
    required this.node,
    required this.mastery,
    required this.watched,
    this.step,
    this.isRoot = false,
    this.prerequisites = const <String>[],
  });

  final ConceptNode node;
  final double? mastery;
  final bool watched;
  final int? step;
  final bool isRoot;
  final List<String> prerequisites;

  @override
  Widget build(BuildContext context) {
    final bool ok = mastery != null && mastery! >= AppConstants.masteryRatio;
    return NeoCard(
      onTap: () => Flows.openRemedial(context, node.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundColor: isRoot ? AppColors.accentPink : AppColors.surface,
                child: step != null
                    ? Text('$step', style: AppTextStyles.titleSm)
                    : Text('L${node.level}', style: AppTextStyles.labelMd),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(node.title, style: AppTextStyles.titleSm),
                    const SizedBox(height: 2),
                    Text(
                      <String>[
                        if (isRoot) 'Akar masalah',
                        '${node.videoDurationLabel} video',
                        if (watched) 'sudah ditonton',
                        if (prerequisites.isNotEmpty) 'Prasyarat: ${prerequisites.join(', ')}',
                      ].join(' • '),
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.ink),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          if (mastery != null) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: NeoProgressBar(
                    value: mastery,
                    height: 8,
                    color: ok ? AppColors.accentGreen : AppColors.accentPink,
                  ),
                ),
                const SizedBox(width: 10),
                Text(Formatters.percent(mastery!), style: AppTextStyles.labelMd),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
