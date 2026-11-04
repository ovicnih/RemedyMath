import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import 'common.dart';

/// Pemutar video pembelajaran per node + deteksi selesai.
///
/// Audit §5: video pindah ke HALAMAN MATERI (tidak lagi kartu terpisah di
/// hasil diagnosis). Saat `PlayerState.ended`, widget memanggil
/// [onCompleted] — halaman memakainya untuk `markStudied`, sehingga state
/// tetap benar setelah navigasi, restart, atau pemuatan data lokal.
///
/// `videoId` kosong ditangani dengan placeholder jelas, bukan pemutar
/// kosong; tombol "Tandai sudah dipelajari" hanya muncul sebagai
/// *fallback* bila video memang belum ditautkan (audit §6: video atau
/// post-test tidak tersedia ≠ otomatis tuntas).
class VideoLessonPlayer extends StatefulWidget {
  const VideoLessonPlayer({
    super.key,
    required this.nodeId,
    required this.videoId,
    required this.lessonTitle,
    required this.summary,
    required this.completed,
    required this.onCompleted,
  });

  final String nodeId;
  final String? videoId;
  final String lessonTitle;
  final String summary;
  final bool completed;
  final VoidCallback onCompleted;

  @override
  State<VideoLessonPlayer> createState() => _VideoLessonPlayerState();
}

class _VideoLessonPlayerState extends State<VideoLessonPlayer> {
  YoutubePlayerController? _videoController;
  Timer? _stateCheckTimer;

  /// Menandai perhitungan selesai lebih dulu, agar Timer.periodic tetap
  /// berjalan beberapa detik masa transisi tidak memicu callback dua kali.
  bool _completedNotified = false;

  /// Putus selesai maksimal sebelum ujung video (8P.2): seek langsung ke
  /// akhir tetap dihitung sudah menonton. YouTube iframe tidak selalu
  /// memancarkan event `ended` saat pengguna lompat ke titik akhir —
  /// posisi bisa berhenti di frame terakhir dengan state playing/paused.
  static const Duration _endTolerance = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    final String? videoId = widget.videoId;
    if (videoId != null && videoId.isNotEmpty && !widget.completed) {
      // Sudah selesai sebelumnya: pemutar dibuat ulang melalui tombol
      // "Ulangi video" agar test widget tidak memerlukan webview.
      _videoController = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      )..loadVideoById(videoId: videoId);
      _startStateChecking();
    }
  }

  void _startStateChecking() {
    _stateCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _evaluateCompletion();
    });
  }

  /// Putar ulang video setelah selesai (8R.4): buat pemutar baru dan atur
  // ulang penanda selesai sehingga `onCompleted` dapat dipanggil lagi saat
  // video selesai ditonton kembali.
  void _ulangiVideo() {
    setState(() {
      _completedNotified = false;
      _videoController = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      )..loadVideoById(videoId: widget.videoId!);
      _startStateChecking();
    });
  }

  /// Selesai jika: state pemutar `ended` (titik putar natural), ATAU posisi
  /// pemutar sudah mencapai dua detik terakhir video (seek ke ujung).
  Future<void> _evaluateCompletion() async {
    if (_completedNotified) return;
    final YoutubePlayerController? ctrl = _videoController;
    if (ctrl == null) return;

    final bool ended = ctrl.value.playerState == PlayerState.ended;
    if (!ended && !(await _nearEnd(ctrl))) return;

    _completedNotified = true;
    _stateCheckTimer?.cancel();
    if (mounted) {
      setState(() {});
      widget.onCompleted();
    }
  }

  /// Benar-benar dekat ujung: posisi sekarang >= durasi - [_endTolerance].
  ///
  /// Durasi dibaca dari metadata pemutar; bila belum terisi (metadata belum
  /// termuat), ambil langsung via bridge `duration`. Durasi nol berarti
  /// video belum siap — bukan tanda selesai, jadi jangan trigger di awal.
  Future<bool> _nearEnd(YoutubePlayerController ctrl) async {
    Duration duration = ctrl.value.metaData.duration;
    if (duration <= Duration.zero) {
      final double? d = await _safeDurationSeconds(ctrl);
      if (d == null || d <= 0) return false;
      duration = Duration(milliseconds: (d * 1000).truncate());
    }
    final double? position = await _safePositionSeconds(ctrl);
    if (position == null) return false;
    return Duration(milliseconds: (position * 1000).truncate()) >=
        duration - _endTolerance;
  }

  /// Baca `duration` via bridge; null bila bridge bermasalah.
  Future<double?> _safeDurationSeconds(YoutubePlayerController ctrl) async {
    try {
      return await ctrl.duration;
    } catch (_) {
      return null;
    }
  }

  /// Baca `currentTime` via bridge; null bila bridge bermasalah.
  Future<double?> _safePositionSeconds(YoutubePlayerController ctrl) async {
    try {
      return await ctrl.currentTime;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _stateCheckTimer?.cancel();
    _videoController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? videoId = widget.videoId;
    return NeoLessonShell(
      eyebrow: 'Video pembelajaran',
      completedBadge: widget.completed ? const _CompletedBadge() : null,
      child: videoId == null || videoId.isEmpty
          ? const _NoVideoPlaceholder()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_videoController != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: AppSizes.radius(AppSizes.radiusCard),
                      child: YoutubePlayer(controller: _videoController!),
                    ),
                  ),
                const SizedBox(height: AppSizes.spaceMd),
                Text(widget.lessonTitle, style: AppTextStyles.titleSm),
                const SizedBox(height: AppSizes.spaceXs),
                Text(widget.summary, style: AppTextStyles.bodyMd),
                if (widget.completed && _videoController == null) ...<Widget>[
                  const SizedBox(height: AppSizes.spaceMd),
                  NeoButton(
                    icon: Icons.replay,
                    label: 'Ulangi video',
                    onPressed: _ulangiVideo,
                  ),
                ],
                if (widget.completed) ...<Widget>[
                  const SizedBox(height: AppSizes.spaceMd),
                  const Text(
                    '✓ Video selesai ditonton. Post-test sudah bisa dibuka.',
                    style: AppTextStyles.labelMd,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
    );
  }
}

/// Kartu kuning section lengkung sama seperti kartu materi lain.
class NeoLessonShell extends StatelessWidget {
  const NeoLessonShell({
    super.key,
    required this.eyebrow,
    required this.child,
    this.completedBadge,
  });

  final String eyebrow;
  final Widget child;
  final Widget? completedBadge;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.accentYellow,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionTitle(
            eyebrow,
            icon: Icons.play_circle_outline,
            style: AppTextStyles.titleMd,
            trailing: completedBadge,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          child,
        ],
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentGreen,
        borderRadius: AppSizes.radius(AppSizes.radiusChip),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.check_circle_outline, size: 12, color: AppColors.ink),
          const SizedBox(width: AppSizes.spaceXs),
          Text(
            'Selesai',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _NoVideoPlaceholder extends StatelessWidget {
  const _NoVideoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.video_library_outlined, size: 40, color: AppColors.ink),
              SizedBox(height: AppSizes.spaceXs),
              Text(
                'Video belum ditautkan untuk konsep ini. Gunakan tombol '
                '"Tandai sudah dipelajari" di bawah.',
                style: AppTextStyles.bodyMd,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
