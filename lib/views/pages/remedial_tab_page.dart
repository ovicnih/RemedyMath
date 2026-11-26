import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_sizes.dart';
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
                    studied: c.isStudied(path[i]),
                    session: c.sessionFor(path[i]),
                    locked: !c.isRouteUnlocked(path[i]),
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
                  studied: c.isStudied(n.id),
                  session: c.sessionFor(n.id),
                  locked: !c.isRouteUnlocked(n.id),
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
    required this.studied,
    this.session,
    this.step,
    this.isRoot = false,
    this.prerequisites = const <String>[],
    this.locked = false,
  });

  final ConceptNode node;
  final double? mastery;
  final bool studied;
  final RemedialSession? session;
  final int? step;
  final bool isRoot;
  final List<String> prerequisites;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    // (§7) Sumber persentase pada tile: hasil post-test bila sudah pernah
    // dikerjakan, selain itu penguasaan awal dari diagnostik.
    final RemedialSession? sess = session;
    final double? barValue = sess != null ? sess.score / 100 : mastery;
    final bool ok = barValue != null && barValue >= AppConstants.masteryRatio;
    final bool passed = sess != null && sess.passed;

    final String statusLabel;
    final Color statusBg;
    final IconData statusIcon;
    if (locked) {
      statusLabel = 'Terkunci';
      statusBg = AppColors.surface;
      statusIcon = Icons.lock_outline;
    } else if (passed) {
      statusLabel = 'Tuntas';
      statusBg = AppColors.accentGreen;
      statusIcon = Icons.check_circle_outline;
    } else if (sess != null && !sess.passed) {
      statusLabel = 'Belum tuntas';
      statusBg = AppColors.accentPink;
      statusIcon = Icons.replay_outlined;
    } else if (studied) {
      statusLabel = 'Video selesai · Menunggu post-test';
      statusBg = AppColors.accentYellow;
      statusIcon = Icons.quiz_outlined;
    } else {
      statusLabel = 'Belum dimulai';
      statusBg = AppColors.accentBlue;
      statusIcon = Icons.play_circle_outline;
    }

    final Color badgeBg = locked
        ? AppColors.surface
        : (passed
            ? AppColors.accentGreen
            : (isRoot ? AppColors.accentPink : AppColors.accentYellow));

    return NeoCard(
      onTap: () => Flows.openRemedial(context, node.id),
      color: locked ? AppColors.background : AppColors.surface,
      borderWidth: locked ? AppSizes.borderThin : AppSizes.borderThick,
      elevated: !locked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: AppSizes.radius(AppSizes.radiusChip),
                  border: Border.all(
                    color: AppColors.ink,
                    width: AppSizes.borderThin,
                  ),
                ),
                child: locked
                    ? const Icon(Icons.lock, size: 16, color: AppColors.ink)
                    : passed
                        ? const Icon(Icons.check, size: 18, color: AppColors.ink)
                        : step != null
                            ? Text('$step', style: AppTextStyles.titleSm)
                            : Text('L${node.level}',
                                style: AppTextStyles.labelMd),
              ),
              const SizedBox(width: AppSizes.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(node.title, style: AppTextStyles.titleSm),
                    const SizedBox(height: AppSizes.spaceXs),
                    Wrap(
                      spacing: AppSizes.spaceXs,
                      runSpacing: AppSizes.spaceXs,
                      children: <Widget>[
                        Pill(
                          label: statusLabel,
                          icon: statusIcon,
                          background: statusBg,
                          bordered: true,
                        ),
                        if (isRoot)
                          const Pill(
                            label: 'Akar masalah',
                            background: AppColors.accentPink,
                            bordered: true,
                          ),
                      ],
                    ),
                    if (prerequisites.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSizes.spaceXs),
                      Text(
                        'Prasyarat: ${prerequisites.join(', ')}',
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.ink),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                locked ? Icons.lock_outline : Icons.chevron_right,
                color: AppColors.ink,
              ),
            ],
          ),
          if (barValue != null) ...<Widget>[
            const SizedBox(height: AppSizes.spaceMd),
            Row(
              children: <Widget>[
                Expanded(
                  child: NeoProgressBar(
                    value: barValue,
                    height: 10,
                    color: ok ? AppColors.accentGreen : AppColors.accentPink,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceMd),
                Text(
                  sess != null ? '${sess.score}%' : Formatters.percent(barValue),
                  style: AppTextStyles.labelStrong,
                ),
              ],
            ),
          ] else ...<Widget>[
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              'Belum dinilai • ${node.keyPoints.length} poin kunci',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.ink),
            ),
          ],
        ],
      ),
    );
  }
}
