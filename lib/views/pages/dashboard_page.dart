import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../flows.dart';
import '../widgets/common.dart';
import 'diagnosis_result_page.dart';

part 'dashboard_sections.dart';

/// Beranda siswa — gaya Hybrid Swiss Grid × Playful Bento Neo-Brutalism.
///
/// Susunan: `AppHeader`, sapaan Swiss ringkas, 1 Hero Bento CTA berwarna Lime
/// yang adaptif terhadap state belajar, 2×2 Playful Bento Grid (θ, Ketuntasan,
/// Akar Masalah, Skor Terakhir), lalu riwayat sesi terbaru.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final DiagnosticResult? r = c.latestResult;
    final ConceptNode? root = c.rootCause;
    final ConceptNode? nextNode = _nextRemedialNode(c, r);

    final int totalNodes = c.graph.ordered.length;
    final int passedCount =
        c.graph.ordered.where((ConceptNode n) => c.isPassed(n.id)).length;

    return Scaffold(
      body: Column(
        children: <Widget>[
          const AppHeader(),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spaceLg,
                  AppSizes.spaceLg,
                  AppSizes.spaceLg,
                  AppSizes.spaceXl,
                ),
                children: <Widget>[
                  _SwissGreeting(
                    name: c.profile?.firstName ?? 'Siswa',
                    hasResult: r != null,
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  _HeroBentoCta(
                    result: r,
                    nextNode: nextNode,
                    questionCount: c.content.diagnosticQuestions.length,
                    durationMinutes: c.content.durationMinutes,
                    onStartDiagnostic: () => Flows.startDiagnostic(context),
                    onOpenRemedial: nextNode == null
                        ? null
                        : () => Flows.openRemedial(context, nextNode.id),
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  _BentoStatsGrid(
                    controller: c,
                    result: r,
                    root: root,
                    passedCount: passedCount,
                    totalNodes: totalNodes,
                  ),
                  const SizedBox(height: AppSizes.spaceXl),
                  _HistorySection(controller: c),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ConceptNode? _nextRemedialNode(AppController c, DiagnosticResult? r) {
    if (r == null || r.learningPath.isEmpty) return null;
    for (final String id in r.learningPath) {
      if (!c.isPassed(id)) return c.graph.node(id);
    }
    return null;
  }
}
