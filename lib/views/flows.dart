import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/models.dart';
import 'pages/diagnosis_result_page.dart';
import 'pages/quiz_page.dart';
import 'pages/remedial_page.dart';

/// Alur lintas halaman.
class Flows {
  const Flows._();

  static Future<void> startDiagnostic(BuildContext context) async {
    final AppController c = context.read<AppController>();
    final NavigatorState nav = Navigator.of(context);
    final List<int?>? answers = await nav.push<List<int?>>(MaterialPageRoute<List<int?>>(
      builder: (_) => QuizPage(
        title: 'Diagnostik',
        badge: '${c.content.topic} • ${c.profile?.className ?? 'SMA Kelas 10'}',
        questions: c.content.diagnosticQuestions,
        duration: Duration(minutes: c.content.durationMinutes),
        showHints: true,
      ),
    ));
    if (answers == null) return;
    await c.submitDiagnostic(answers);
    await nav.push(MaterialPageRoute<void>(builder: (_) => const DiagnosisResultPage()));
  }

  static Future<void> openRemedial(BuildContext context, String nodeId) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RemedialPage(nodeId: nodeId)),
      );

  static Future<void> startPostTest(BuildContext context, String nodeId) async {
    final AppController c = context.read<AppController>();
    final NavigatorState nav = Navigator.of(context);
    final List<Question> qs = c.content.postTests[nodeId] ?? <Question>[];
    if (qs.isEmpty) return;
    final ConceptNode? node = c.graph.node(nodeId);
    final List<int?>? answers = await nav.push<List<int?>>(MaterialPageRoute<List<int?>>(
      builder: (_) => QuizPage(
        title: 'Post-Test',
        badge: 'Post-Test • ${node?.shortTitle ?? ''}',
        questions: qs,
        duration: const Duration(minutes: 5),
        showHints: false,
      ),
    ));
    if (answers == null) return;
    final RemedialSession s = await c.submitPostTest(nodeId, answers);
    if (!nav.mounted) return;
    await showDialog<void>(
      context: nav.context,
      builder: (BuildContext ctx) => AlertDialog(
        icon: Icon(
          s.passed ? Icons.verified : Icons.replay_circle_filled_outlined,
          size: 48,
          color: s.passed ? AppColors.accentGreen : AppColors.accentPink,
        ),
        title: Text(s.passed ? 'Konsep Tuntas!' : 'Belum Tuntas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Skor post-test', style: AppTextStyles.bodyMd),
            Text('${s.score}/100', style: AppTextStyles.statValue),
            const SizedBox(height: 8),
            Text(
              'Skor Kemampuan IRT terbaru: θ = ${c.latestResult?.theta.toStringAsFixed(2) ?? '-'}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd,
            ),
            const SizedBox(height: 8),
            Text(
              s.passed
                  ? 'Hebat! Lanjutkan ke materi berikutnya pada rute belajarmu.'
                  : 'Pelajari ulang konsep dan poin kunci, lalu coba lagi.',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
    c.setTab(0);
    nav.popUntil((Route<dynamic> r) => r.isFirst);
  }
}
