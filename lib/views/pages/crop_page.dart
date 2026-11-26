import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import '../widgets/common.dart';
import '../../services/profile_image_service.dart';

/// Layar crop foto profil (8S.2): model interaksi sesuai
/// `RENCANA_PERBAIKAN_FITUR_CROP_FOTO_PROFIL.md`.
///
/// Bingkai crop persegi 1:1 **tetap di tengah layar**; foto di belakangnya
/// yang digeser (satu jari) dan diperbesar/perkecil (pinch dua jari)
/// tanpa merentang proporsi. Area di luar bingkai di-overlay gelap dengan
/// garis bantu tengah. Tombol "Simpan" memotong tepat area di dalam
/// bingkai via `ProfileImageService.cropRect` → JPEG 512×512; "Batal"
/// kembali `null`.
class CropPage extends StatefulWidget {
  const CropPage({super.key, required this.rawBytes});

  /// Byte gambar asli dari picker (PNG/JPEG apa adanya).
  final List<int> rawBytes;

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  ImageSize? _dims;
  String? _error;
  late final Uint8List _imageBytes = Uint8List.fromList(widget.rawBytes);

  /// Skala tampil: piksel layar per piksel gambar sumber.
  double _scale = 1;

  /// Posisi pusat gambar relatif terhadap pusat bingkai (piksel layar).
  /// `Offset.zero` berarti pusat gambar tepat di tengah bingkai.
  Offset _offset = Offset.zero;

  /// Skala dasar saat gestur pinch dimulai.
  double _baseScale = 1.0;

  /// Titik fokus awal saat gestur dimulai.
  Offset _startFocal = Offset.zero;

  /// Offset dasar saat gestur dimulai.
  Offset _baseOffset = Offset.zero;

  /// Titik fokus sentuhan pada update gestur sebelumnya.
  Offset? _prevFocal;

  /// Rasio sisi bingkai terhadap sisi viewport.
  static const double _kFrameRatio = 0.83;

  /// Zoom maksimal = cover scale × _kMaxZoom.
  static const double _kMaxZoom = 4.0;

  @override
  void initState() {
    super.initState();
    _loadSize();
  }

  void _loadSize() {
    try {
      final ImageSize dims = ProfileImageService.imageSize(widget.rawBytes);
      if (!mounted) return;
      setState(() => _dims = dims);
    } on ArgumentError {
      if (!mounted) return;
      setState(() => _error = 'Format gambar tidak dikenali');
    }
  }

  /// Skala minimum "cover": bingkai penuh terpenuhi gambar (tidak ada
  /// ruang kosong di dalam bingkai), proporsi gambar dipertahankan.
  double _coverScale(double frameSide, ImageSize dims) {
    return max(frameSide / dims.width, frameSide / dims.height);
  }

  /// Sisi bingkai dalam piksel layar (persegi, tengah viewport).
  double _frameSide(double side) => side * _kFrameRatio;

  /// Rect bingkai dalam koordinat viewport sisi [side].
  Rect _frameRect(double side, ImageSize dims) {
    final double f = _frameSide(side);
    return Rect.fromCenter(
      center: Offset(side / 2, side / 2),
      width: f,
      height: f,
    );
  }

  /// Siapkan skala dan offset awal: gambar memenuhi bingkai, pusat di tengah.
  void _prepareLayout(double side, ImageSize dims) {
    _scale = _coverScale(_frameSide(side), dims);
    _offset = Offset.zero;
  }

  /// Ganjal skala dan offset agar seluruh bingkai terus tertutupi gambar
  /// (tidak ada ruang kosong).
  void _clamp(double side, ImageSize dims) {
    final double frameSide = _frameSide(side);
    final double cover = _coverScale(frameSide, dims);
    _scale = _scale.clamp(cover, cover * _kMaxZoom);

    final double halfW = dims.width * _scale / 2;
    final double halfH = dims.height * _scale / 2;
    final double frameHalf = frameSide / 2;

    // Batas pergeseran maksimum dari pusat agar tepi bingkai tidak bocor.
    final double maxDx = max(0.0, halfW - frameHalf);
    final double maxDy = max(0.0, halfH - frameHalf);

    _offset = Offset(
      _offset.dx.clamp(-maxDx, maxDx),
      _offset.dy.clamp(-maxDy, maxDy),
    );
  }

  /// Area crop dalam koordinat piksel gambar sumber (selalu persegi,
  /// sama dengan area bingkai).
  CropRegion _regionFor(double side, ImageSize dims) {
    final double frameSide = _frameSide(side);
    final int srcSize = (frameSide / _scale).round();
    // Pusat gambar layar = (side/2, side/2) + _offset.
    // Piksel sumber di tepi kiri bingkai:
    //   srcX = (screenX - imgCenterScreen.x) / _scale + dims.width / 2
    final double srcLeft =
        dims.width / 2 - (frameSide / 2 + _offset.dx) / _scale;
    final double srcTop =
        dims.height / 2 - (frameSide / 2 + _offset.dy) / _scale;
    final int x = srcLeft.round().clamp(0, dims.width - 1);
    final int y = srcTop.round().clamp(0, dims.height - 1);
    final int maxW = dims.width - x;
    final int maxH = dims.height - y;
    final int size = srcSize.clamp(1, min(maxW, maxH));
    return CropRegion(x: x, y: y, size: size);
  }

  Future<void> _confirmCrop(double side) async {
    if (_dims == null) return;
    final Uint8List bytes = ProfileImageService.cropRect(
      widget.rawBytes,
      _regionFor(side, _dims!),
    );
    if (!mounted) return;
    Navigator.of(context).pop<Uint8List>(bytes);
  }

  /// Sesuaikan: skala cover + pusat, agar bingkai penuh tanpa ruang kosong.
  void _fitToFrame(double side, ImageSize dims) {
    setState(() {
      _scale = _coverScale(_frameSide(side), dims);
      _offset = Offset.zero;
      _clamp(side, dims);
    });
  }

  /// Pusatkan: pusatkan gambar pada bingkai, pertahankan skala saat ini.
  void _centerOnFrame(double side, ImageSize dims) {
    setState(() {
      _offset = Offset.zero;
      _clamp(side, dims);
    });
  }

  void _onScaleStart(ScaleStartDetails d) {
    _baseScale = _scale;
    _baseOffset = _offset;
    _startFocal = d.localFocalPoint;
    _prevFocal = d.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails d, double side, ImageSize dims) {
    setState(() {
      if (d.scale != 1.0 && d.pointerCount > 1) {
        // Pinch zoom: skala relatif terhadap _baseScale (bukan kumulatif eksponensial).
        final double frameSide = _frameSide(side);
        final double cover = _coverScale(frameSide, dims);
        final double targetScale =
            (_baseScale * d.scale).clamp(cover, cover * _kMaxZoom);

        // Pertahankan titik fokus di bawah jari (anchor zoom).
        final Offset center = Offset(side / 2, side / 2);
        final Offset focalInImage =
            (_startFocal - (center + _baseOffset)) / _baseScale;

        _scale = targetScale;
        _offset = d.localFocalPoint - focalInImage * _scale - center;
      } else {
        // Drag 1 jari: tambahkan selisih titik fokus.
        final Offset delta = _prevFocal == null
            ? Offset.zero
            : d.localFocalPoint - _prevFocal!;
        _offset += delta;
      }

      _clamp(side, dims);
      _prevFocal = d.localFocalPoint;
    });
  }

  void _onScaleEnd(ScaleEndDetails d) {
    _prevFocal = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: remediAppBar(context, 'Sesuaikan foto', showBack: true),
      body: SafeArea(
        child: _error != null
            ? _errorPane(_error!)
            : _dims == null
                ? const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: AppColors.ink,
                      color: AppColors.accentYellow,
                    ),
                  )
                : LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final ImageSize dims = _dims!;
                      final double side =
                          constraints.biggest.shortestSide;
                      // LayoutBuilder dapat dipanggil ulang; tata letak
                      // awal hanya sekali.
                      if (!_layoutReady) {
                        _prepareLayout(side, dims);
                        _layoutReady = true;
                      }
                      return _buildCropBody(side, dims);
                    },
                  ),
      ),
    );
  }

  bool _layoutReady = false;

  Widget _buildCropBody(double side, ImageSize dims) {
    final Rect frame = _frameRect(side, dims);
    final double imgW = dims.width * _scale;
    final double imgH = dims.height * _scale;
    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _onScaleStart,
              onScaleUpdate: (ScaleUpdateDetails d) =>
                  _onScaleUpdate(d, side, dims),
              onScaleEnd: _onScaleEnd,
              child: SizedBox(
                width: side,
                height: side,
                child: ClipRect(
                  child: Stack(
                    children: <Widget>[
                      // Foto: diposisikan tepat dengan koordinat piksel layar
                      // (pusatViewport + _offset - ukuranRender / 2).
                      Positioned(
                        left: side / 2 + _offset.dx - imgW / 2,
                        top: side / 2 + _offset.dy - imgH / 2,
                        width: imgW,
                        height: imgH,
                        child: Image.memory(
                          _imageBytes,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            key: const ValueKey('cropMask'),
                            size: Size.square(side),
                            painter: _CropMask(frame: frame),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: AppSizes.spaceSm),
          child: Text(
            'Geser foto, cabut-cabut (pinch) untuk zoom',
            style: AppTextStyles.caption,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceLg,
            vertical: AppSizes.spaceMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSizes.spaceMd,
                runSpacing: AppSizes.spaceMd,
                children: <Widget>[
                  NeoButton(
                    label: 'Sesuaikan',
                    onPressed: () => _fitToFrame(side, dims),
                  ),
                  NeoButton(
                    label: 'Pusatkan',
                    onPressed: () => _centerOnFrame(side, dims),
                  ),
                  NeoButton(
                    label: 'Reset',
                    color: AppColors.surface,
                    onPressed: () => _fitToFrame(side, dims),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMd),
              Row(
                children: <Widget>[
                  Expanded(
                    child: NeoButton(
                      label: 'Simpan',
                      onPressed: () => _confirmCrop(side),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceMd),
                  Expanded(
                    child: NeoButton(
                      label: 'Batal',
                      color: AppColors.surface,
                      onPressed: () =>
                          Navigator.of(context).pop<Uint8List>(null),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Panel format tak dikenali: jalan keluar aman tanpa crash.
  Widget _errorPane(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.image_not_supported_outlined, size: 56),
              const SizedBox(height: AppSizes.spaceMd),
              Text(message, style: AppTextStyles.bodyMd),
              const SizedBox(height: AppSizes.spaceLg),
              NeoButton(
                label: 'Kembali',
                onPressed: () => Navigator.of(context).pop<Uint8List>(null),
              ),
            ],
          ),
        ),
      );
}

/// Peliput bingkai: gelapkan area luar, gambar border bingkai + garis bantu
/// tengah (gaya panduan Canva).
class _CropMask extends CustomPainter {
  const _CropMask({required this.frame});

  final Rect frame;

  static final Paint _dimPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.5);
  static final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = AppSizes.borderThick * 2
    ..color = Colors.white;
  static final Paint _guidePaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.4)
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect area = Offset.zero & size;

    // Latar gelap di luar bingkai.
    final Path dim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(area)
      ..addRect(frame);
    canvas.drawPath(dim, _dimPaint);

    // Border bingkai hasil crop.
    canvas.drawRect(frame, _borderPaint);

    // Garis bantu tengah vertikal & horizontal.
    canvas.drawLine(
      Offset(frame.center.dx, frame.top),
      Offset(frame.center.dx, frame.bottom),
      _guidePaint,
    );
    canvas.drawLine(
      Offset(frame.left, frame.center.dy),
      Offset(frame.right, frame.center.dy),
      _guidePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CropMask old) => old.frame != frame;
}
