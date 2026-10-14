import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/models.dart';
import '../widgets/common.dart';

/// Pembahasan lengkap soal diagnostik.
class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final DiagnosticResult? r = c.latestResult;
    final List<Question> qs = c.content.diagnosticQuestions;
    final Map<String, int?> byId = <String, int?>{};
    if (r != null) {
      for (int i = 0; i < r.questionIds.length; i++) {
        byId[r.questionIds[i]] = i < r.answers.length ? r.answers[i] : null;
      }
    }

    return Scaffold(
      appBar: remediAppBar(context, 'Pembahasan Soal', showBack: true),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: qs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int i) {
            final Question q = qs[i];
            final int? a = byId[q.id];
            final bool ok = q.isCorrect(a);
            return NeoCard(
              borderColor: ok ? AppColors.accentGreen : AppColors.accentPink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('Soal ${i + 1}', style: AppTextStyles.titleMd),
                      const SizedBox(width: 8),
                      Flexible(child: Pill(label: q.category)),
                      const Spacer(),
                      Icon(ok ? Icons.check_circle : Icons.cancel,
                          color: ok ? AppColors.accentGreen : AppColors.accentPink),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(q.stem, style: AppTextStyles.bodyMd),
                  if (q.expression.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    MathBox(q.expression),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'Jawabanmu: ${a == null ? '(kosong)' : '${String.fromCharCode(65 + a)}. ${q.options[a]}'}',
                    style: AppTextStyles.mathInline,
                  ),
                  Text(
                    'Kunci: ${String.fromCharCode(65 + q.answerIndex)}. ${q.options[q.answerIndex]}',
                    style: AppTextStyles.mathInline.copyWith(color: AppColors.ink),
                  ),
                  if (q.hint.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.accentBlue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(q.hint,
                              style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text('Materi: ${c.graph.node(q.nodeId)?.shortTitle ?? q.nodeId} • b = ${q.difficulty.toStringAsFixed(1)}',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
