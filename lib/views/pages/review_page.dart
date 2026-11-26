import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
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
          padding: const EdgeInsets.all(AppSizes.spaceLg),
          itemCount: qs.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceMd),
          itemBuilder: (BuildContext context, int i) {
            final Question q = qs[i];
            final int? a = byId[q.id];
            // 8P.1: kartu netral — tidak ada penilaian berwarna merah/hijau.
            return NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('Soal ${i + 1}', style: AppTextStyles.titleMd),
                      const SizedBox(width: AppSizes.spaceSm),
                      Flexible(
                        child: Pill(label: q.category, bordered: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  Text(q.stem, style: AppTextStyles.bodyMd),
                  if (q.expression.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSizes.spaceSm),
                    MathBox(q.expression),
                  ],
                  const SizedBox(height: AppSizes.spaceMd),
                  Text(
                    'Jawabanmu: ${a == null ? '(kosong)' : '${String.fromCharCode(65 + a)}. ${q.options[a]}'}',
                    style: AppTextStyles.mathInline,
                  ),
                  if (q.hint.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSizes.spaceSm),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.spaceSm),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppSizes.radius(AppSizes.radiusChip),
                        border: Border.all(
                          color: AppColors.ink,
                          width: AppSizes.borderHairline,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: AppColors.ink,
                          ),
                          const SizedBox(width: AppSizes.spaceSm),
                          Expanded(
                            child: Text(
                              q.hint,
                              style: AppTextStyles.labelMd
                                  .copyWith(color: AppColors.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.spaceSm),
                  Text(
                    'Materi: ${c.graph.node(q.nodeId)?.shortTitle ?? q.nodeId} • b = ${q.difficulty.toStringAsFixed(1)}',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.ink),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
