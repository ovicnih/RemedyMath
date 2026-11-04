import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Ukuran gambar dalam piksel — dipakai layar crop untuk menghitung
/// skala awal dan batas geser.
class ImageSize {
  const ImageSize(this.width, this.height);
  final int width;
  final int height;
}

/// Area persegi (1:1) terpilih di layar crop, dalam koordinat piksel
/// gambar sumber.
class CropRegion {
  const CropRegion({
    required this.x,
    required this.y,
    required this.size,
  });
  final int x;
  final int y;
  final int size;
}

/// Layanan pengolahan foto profil: crop persegi 1:1 + resize seragam.
///
/// Alur setelah umpan balik pengguna (8 Part 3): pengguna memilih area
/// crop sendiri di layar interaktif (`crop_page.dart`), layar mengirim
/// [CropRegion] ke [cropRect]. Posisi awal pemilihan area adalah
/// [baseline] — crop pusat dari sisi terpendek — supaya pengguna yang
/// tidak menggeser apa pun tetap mendapat hasil lama yang benar.
///
/// Keluaran selalu 512x512 JPEG q85 sehingga proporsi avatar 1:1 penuh.
///
/// Memakai package `image` (pure Dart) — tanpa konfigurasi native, jadi
/// jalurnya identik untuk Android dan web.
class ProfileImageService {
  const ProfileImageService._();

  /// Sisi keluaran (persegi). 512 px cukup untuk avatar terbesar di UI
  /// (kesan tetap tajam sampai DPR 3x pada avatar 160 px).
  static const int outputSize = 512;

  /// Kualitas JPEG keluaran (0-100); 85 seimbang antara ukuran kecil
  /// dan tajam, cocok untuk penyimpanan base64 di SharedPreferences.
  static const int jpegQuality = 85;

  /// Ambil ukuran gambar tanpa kerja encode (untuk layar crop).
  ///
  /// Melempar [ArgumentError] bila format tidak dikenali.
  static ImageSize imageSize(List<int> rawBytes) {
    final img.Image? decoded =
        img.decodeImage(Uint8List.fromList(rawBytes));
    if (decoded == null) {
      throw ArgumentError.value(
        rawBytes.length,
        'rawBytes',
        'Format gambar tidak dikenali',
      );
    }
    return ImageSize(decoded.width, decoded.height);
  }

  /// Region baseline: crop pusat dari sisi terpendek.
  static CropRegion baseline(ImageSize src) {
    final int side = src.width <= src.height ? src.width : src.height;
    return CropRegion(
      x: (src.width - side) ~/ 2,
      y: (src.height - side) ~/ 2,
      size: side,
    );
  }

  /// Potong tepat [region] dari gambar lalu keluarkan JPEG persegi
  /// [outputSize].
  ///
  /// Region dimasukkan (clamp) ke dalam batas gambar agar hasil geser
  /// ekstrem di layar tidak pernah keluar dari piksel sumber.
  ///
  /// Melempar [ArgumentError] bila format gambar tidak dikenali.
  static Uint8List cropRect(List<int> rawBytes, CropRegion region) {
    final img.Image? decoded =
        img.decodeImage(Uint8List.fromList(rawBytes));
    if (decoded == null) {
      throw ArgumentError.value(
        rawBytes.length,
        'rawBytes',
        'Format gambar tidak dikenali',
      );
    }
    final int x = region.x.clamp(0, decoded.width - 1);
    final int y = region.y.clamp(0, decoded.height - 1);
    // Sisi terbesar yang utuh dari titik (x, y): min sisa kanan/bawah.
    final int maxSide =
        (decoded.width - x) < (decoded.height - y)
            ? (decoded.width - x)
            : (decoded.height - y);
    final int size =
        region.size <= 0 ? 1 : (region.size > maxSide ? maxSide : region.size);
    final img.Image cropped = img.copyCrop(
      decoded,
      x: x,
      y: y,
      width: size,
      height: size,
    );
    final img.Image resized = img.copyResize(
      cropped,
      width: outputSize,
      height: outputSize,
      interpolation: img.Interpolation.nearest,
    );
    return img.encodeJpg(resized, quality: jpegQuality);
  }

  /// Jalan pintas [cropRect] berisi region [baseline]: crop pusat.
  ///
  /// Tetap dipakai sebagai fallback bila layar crop tidak bisa membuka
  /// gambarnya, dan oleh test sebagai pembanding.
  ///
  /// Melempar [ArgumentError] bila format gambar tidak dikenali.
  static Uint8List cropSquare(List<int> rawBytes) {
    final ImageSize dims = imageSize(rawBytes);
    return cropRect(rawBytes, baseline(dims));
  }

  /// Path file keluaran `<nama>_crop.jpg` di folder yang sama dengan file
  /// asli picker, sehingga file galeri tidak tertimpa dan avatar selalu
  /// memakai versi persegi.
  static String croppedFilePath(String originalPath) {
    final int dot = originalPath.lastIndexOf('.');
    final String stem =
        dot > 0 ? originalPath.substring(0, dot) : originalPath;
    return '${stem}_crop.jpg';
  }
}
