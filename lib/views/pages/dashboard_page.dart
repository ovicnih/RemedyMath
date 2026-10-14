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

/// Beranda / dashboard siswa.
///
/// Susunan mengikuti `UI-REFERENCE.md` §4.1: `AppHeader`, hero, kartu metrik
/// IRT biru, kartu diagnosis adaptif kuning, kartu rekomendasi, tiga stat
/// card, lalu riwayat belajar. Footer desain dihapus di mobile (§8); kartu
/// kutipan lama dihapus karena itu satu-satunya elemen yang boleh dibuang
/// (§7).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    final DiagnosticResult? r = c.latestResult;
    final ConceptNode? root = c.rootCause;
    final String nextNodeId = r != null && r.learningPath.isNotEmpty
        ? r.learningPath.first
        : c.graph.ordered.first.id;
    final ConceptNode rec = c.graph.node(nextNodeId)!;

    return Scaffold(
      // 4.1 Header: identitas tetap di atas, konten bergulir di bawahnya.
      // `AppHeader` menangani safe area atasnya sendiri.
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
                  _Hero(
                    name: c.profile?.firstName ?? 'Siswa',
                    className: c.profile?.className ?? 'SMA Kelas 10',
                    onStart: () => Flows.startDiagnostic(context),
                  ),
                  const SizedBox(height: AppSizes.spaceXl),
                  _MetricCard(controller: c, result: r, root: root),
                  const SizedBox(height: AppSizes.spaceXl),
                  _DiagnosticCta(
                    durationMinutes: c.content.durationMinutes,
                    count: c.content.diagnosticQuestions.length,
                    onStart: () => Flows.startDiagnostic(context),
                  ),
                  const SizedBox(height: AppSizes.spaceXl),
                  _RecommendationCard(
                    title: rec.lessonTitle,
                    points: rec.keyPoints.length,
                    onOpen: () => Flows.openRemedial(context, rec.id),
                  ),
                  const SizedBox(height: AppSizes.spaceXl),
                  _StatsRow(controller: c),
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
}

/// 4.2 Hero: eyebrow, sapaan dua baris, deskripsi, dan CTA diagnostik.
///
/// Tanda seru pada sapaan diwarnai pink seperti desain; ini logotype
/// sapaan, pengecualian warna sama dengan titik pink wordmark (§6.5).
class _Hero extends StatelessWidget {
  const _Hero({
    required this.name,
    required this.className,
    required this.onStart,
  });

  final String name;
  final String className;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        EyebrowLabel(label: 'Dashboard Siswa · $className'),
        const SizedBox(height: AppSizes.spaceLg),
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
        const Text('Siap belajar hari ini?', style: AppTextStyles.displayLg),
        const SizedBox(height: AppSizes.spaceMd),
        const Text(
          'Langkah kecil, hasil besar. Konsistensi hari ini membangun '
          'penguasaanmu esok.',
          style: AppTextStyles.bodyLg,
        ),
        const SizedBox(height: AppSizes.spaceLg),
        NeoButton(
          expand: true,
          icon: Icons.arrow_forward,
          label: 'Mulai diagnostik',
          onPressed: onStart,
        ),
      ],
    );
  }
}

/// 4.3 Kartu biru metrik diagnostik IRT.
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.controller,
    required this.result,
    required this.root,
  });

  final AppController controller;
  final DiagnosticResult? result;
  final ConceptNode? root;

  @override
  Widget build(BuildContext context) {
    final DiagnosticResult? r = result;
    final double theta = r?.theta ?? 0;
    final double pct = r == null ? 0 : controller.irt.classPercentile(theta);
    return NeoCard(
      color: AppColors.accentBlue,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('METRIK DIAGNOSTIK IRT', style: AppTextStyles.eyebrow),
          const SizedBox(height: AppSizes.spaceMd),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: r == null ? '–' : Formatters.theta(theta),
                  style: AppTextStyles.displayNum,
                ),
                const TextSpan(text: ' / 3.00 θ', style: AppTextStyles.labelSm),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            r == null
                ? 'Belum ada diagnosis'
                : 'Tingkat kemahiran: ${controller.irt.proficiencyLabel(theta)}',
            style: AppTextStyles.labelMd,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          NeoProgressBar(value: pct),
          const SizedBox(height: AppSizes.spaceSm),
          Row(
            children: <Widget>[
              const Expanded(
                child: Text('Perlu pendampingan', style: AppTextStyles.caption),
              ),
              Text(
                r == null
                    ? 'Belum ada data'
                    : '${Formatters.percent(pct)} relatif kelas',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLg),
          _RootCauseCallout(root: root, hasResult: r != null),
        ],
      ),
    );
  }
}

/// Callout putih di dalam kartu metrik: akar masalah terdeteksi.
class _RootCauseCallout extends StatelessWidget {
  const _RootCauseCallout({required this.root, required this.hasResult});

  final ConceptNode? root;
  final bool hasResult;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String text;
    if (!hasResult) {
      icon = Icons.info_outline;
      text = 'Ikuti tes diagnostik untuk menemukan akar masalahmu.';
    } else if (root != null) {
      icon = Icons.warning_amber_rounded;
      text = 'Akar masalah: ${root!.title}';
    } else {
      icon = Icons.check_circle_rounded;
      text = 'Tidak ada miskonsepsi terdeteksi. Pertahankan!';
    }
    return NeoCard(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      onTap: hasResult
          ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DiagnosisResultPage(),
                ),
              )
          : null,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 19, color: AppColors.ink),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMd,
            ),
          ),
          if (hasResult) ...<Widget>[
            const SizedBox(width: AppSizes.spaceSm),
            const Icon(Icons.arrow_forward, size: 16, color: AppColors.ink),
          ],
        ],
      ),
    );
  }
}

/// 4.4 Kartu kuning diagnosis adaptif.
class _DiagnosticCta extends StatelessWidget {
  const _DiagnosticCta({
    required this.durationMinutes,
    required this.count,
    required this.onStart,
  });

  final int durationMinutes;
  final int count;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.accentYellow,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Temukan titik sulitmu.', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSizes.spaceSm),
          const Text(
            'Identifikasi miskonsepsi dan kelemahan materi aljabar lewat '
            'analisis butir otomatis.',
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: AppSizes.spaceLg),
          Wrap(
            spacing: AppSizes.spaceLg,
            runSpacing: AppSizes.spaceSm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _Meta(icon: Icons.schedule, text: '$durationMinutes menit'),
              _Meta(icon: Icons.checklist_rounded, text: '$count soal cepat'),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLg),
          NeoButton(
            expand: true,
            color: AppColors.surface,
            icon: Icons.arrow_forward,
            label: 'Mulai tes',
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

/// Ikon + label meta kecil (13 w900 sesuai desain).
class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.ink),
        const SizedBox(width: AppSizes.spaceXs),
        Text(
          text,
          style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

/// Kartu rekomendasi belajar: materi berikutnya pada rute belajar.
///
/// Tidak ada di mockup, tapi punya fungsi informasi (`UI-REFERENCE.md` §7).
class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.title,
    required this.points,
    required this.onOpen,
  });

  final String title;
  final int points;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      onTap: onOpen,
      child: Row(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentYellow,
              borderRadius: AppSizes.radius(AppSizes.radiusCard),
              boxShadow: AppSizes.shadowCard,
            ),
            child: const Icon(
              Icons.menu_book,
              color: AppColors.ink,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSizes.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 18,
                      color: AppColors.accentBlue,
                    ),
                    SizedBox(width: AppSizes.spaceXs),
                    Expanded(
                      child: Text(
                        'Rekomendasi Belajar Hari Ini',
                        style: AppTextStyles.titleSm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceXs),
                Text(
                  '$title · $points poin kunci',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

/// 4.5 Tiga stat card: topik tuntas, perlu remedial, akurasi rata-rata.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: StatCard(
            color: AppColors.accentGreen,
            value: '${controller.masteredCount}',
            label: 'Topik tuntas',
          ),
        ),
        const SizedBox(width: AppSizes.spaceLg),
        Expanded(
          child: StatCard(
            color: AppColors.accentPink,
            value: '${controller.remedialCount}',
            label: 'Perlu remedial',
          ),
        ),
        const SizedBox(width: AppSizes.spaceLg),
        Expanded(
          child: StatCard(
            color: AppColors.surface,
            value: Formatters.percent(controller.averageAccuracy),
            label: 'Akurasi rata-rata',
          ),
        ),
      ],
    );
  }
}

/// 4.6 + 4.7 Judul bagian riwayat belajar dan tiga kartu riwayat terbaru.
///
/// Desain menaruh tiga kartu berdampingan, tapi `AGENTS.md` §2 melarang
/// lebar mati; pada 360 dp tiga kartu sebaris tidak muat, jadi direflow
/// menjadi `Column`.
class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionTitle(
          'Riwayat belajar',
          style: AppTextStyles.titleMd,
          trailing: TextButton(
            onPressed: () => controller.setTab(3),
            child: Text(
              'Lihat hasil →',
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceSm),
        if (controller.sessions.isEmpty)
          const EmptyState(
            icon: Icons.history_edu,
            title: 'Belum ada sesi remedial',
            message: 'Selesaikan tes diagnostik lalu ikuti rute belajarmu '
                'untuk mengisi riwayat.',
          )
        else
          for (final RemedialSession s in controller.sessions.take(3))
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
