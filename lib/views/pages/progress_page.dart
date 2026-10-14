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

/// Theta dinormalisasi ke rentang -3..+3 agar bisa dipakai langsung
/// sebagai `value` [NeoProgressBar].
///
/// Fungsi ini menggantikan perhitungan inline di `ThetaScale` lama, yang
/// dihapus pada Tahap 3.5 karena memakai `Stack` + `Positioned`.
double _thetaFraction(double theta) => ((theta + 3) / 6).clamp(0.0, 1.0);

/// Tab Progres: perkembangan θ, penguasaan materi, riwayat sesi, profil.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  Future<void> _reset(BuildContext context) async {
    final AppController c = context.read<AppController>();
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Hapus semua data?'),
        content: const Text('Profil, hasil diagnostik, dan riwayat akan dihapus dari perangkat.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) await c.resetAll();
  }

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final DiagnosticResult? r = c.latestResult;
    final List<ThetaPoint> hist = c.history.length > 8
        ? c.history.sublist(c.history.length - 8)
        : c.history;

    return Scaffold(
      appBar: remediAppBar(context, 'Progres'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: <Widget>[
            NeoCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SectionTitle('Perkembangan Kemampuan (θ)', icon: Icons.show_chart),
                  const SizedBox(height: 12),
                  if (r == null)
                    const Text('Belum ada data. Kerjakan tes diagnostik terlebih dahulu.',
                        style: AppTextStyles.bodyMd)
                  else ...<Widget>[
                    NeoProgressBar(value: _thetaFraction(r.theta), height: 20),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Perlu pendampingan',
                            style: AppTextStyles.caption,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Batas tuntas (θ ≥ ${AppConstants.masteryTheta.toStringAsFixed(1)})',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Mandiri',
                            textAlign: TextAlign.end,
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          for (final ThetaPoint p in hist)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(p.theta.toStringAsFixed(1),
                                        style: AppTextStyles.mathInline.copyWith(fontSize: 10)),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      child: FractionallySizedBox(
                                        heightFactor: ((p.theta + 3) / 6).clamp(0.05, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: p.theta >= AppConstants.masteryTheta
                                                ? AppColors.accentGreen
                                                : AppColors.accentBlue,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${c.history.length} pengukuran • terakhir ${hist.isEmpty ? '-' : hist.last.label}',
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.ink)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (r != null)
              NeoCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SectionTitle('Penguasaan Sub-konsep', icon: Icons.hub_outlined),
                    const SizedBox(height: 12),
                    for (final ConceptNode n in c.graph.ordered)
                      if (r.nodeMastery.containsKey(n.id))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(child: Text(n.shortTitle, style: AppTextStyles.bodyMd)),
                                  Text(Formatters.percent(r.nodeMastery[n.id]!),
                                      style: AppTextStyles.labelMd),
                                ],
                              ),
                              const SizedBox(height: 4),
                              NeoProgressBar(
                                value: r.nodeMastery[n.id],
                                height: 8,
                                color: r.nodeMastery[n.id]! >=
                                        AppConstants.masteryRatio
                                    ? AppColors.accentGreen
                                    : AppColors.accentPink,
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const SectionTitle('Riwayat Sesi Remedial', icon: Icons.history),
            const SizedBox(height: 8),
            if (c.sessions.isEmpty)
              const EmptyState(
                icon: Icons.history_edu,
                title: 'Belum ada sesi',
                message: 'Riwayat post-test remedial akan muncul di sini.',
              )
            else
              for (final RemedialSession s in c.sessions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SessionTile(
                    title: s.title,
                    dateLabel: Formatters.shortDate(s.date),
                    subtitle: s.label,
                    score: s.score,
                    passed: s.passed,
                    onAction: () => Flows.openRemedial(context, s.nodeId),
                  ),
                ),
            const SizedBox(height: 16),
            NeoCard(
              child: Row(
                children: <Widget>[
                  const ProfileAvatar(size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(c.profile?.name ?? '-', style: AppTextStyles.titleMd),
                        Text(
                          <String>[
                            c.profile?.className ?? '',
                            if ((c.profile?.school ?? '').isNotEmpty) c.profile!.school,
                          ].join(' • '),
                          style: AppTextStyles.labelMd,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Hapus data',
                    onPressed: () => _reset(context),
                    icon: const Icon(Icons.logout, color: AppColors.accentPink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
