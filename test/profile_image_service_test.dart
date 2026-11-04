import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:remedy_math/services/profile_image_service.dart';

/// Foto 300x100: band merah x=100..199, selebihnya putih.
Uint8List bandPng() {
  final img.Image src = img.Image(width: 300, height: 100);
  img.fillRect(
    src,
    x1: 0,
    y1: 0,
    x2: 299,
    y2: 99,
    color: img.ColorRgb8(255, 255, 255),
  );
  img.fillRect(
    src,
    x1: 100,
    y1: 0,
    x2: 199,
    y2: 99,
    color: img.ColorRgb8(200, 30, 30),
  );
  return img.encodePng(src);
}

void main() {
  group('ProfileImageService.cropSquare', () {
    test('foto landscape menjadi persegi 512x512', () {
      final img.Image src = img.Image(width: 320, height: 200);
      img.fillRect(
        src,
        x1: 0,
        y1: 0,
        x2: 319,
        y2: 199,
        color: img.ColorRgb8(255, 0, 0),
      );
      final Uint8List png = img.encodePng(src);

      final Uint8List out = ProfileImageService.cropSquare(png);
      final img.Image decoded = img.decodeImage(out)!;

      expect(decoded.width, ProfileImageService.outputSize);
      expect(decoded.height, ProfileImageService.outputSize);
    });

    test('crop di pusat: band merah tengah dipertahankan, tepi kiri hilang',
        () {
      // Foto 300x100 dengan band merah di sepertiga tengah — crop persegi
      // pusat wajib mengambil band merah (100–200), bukan tepi putih.
      final img.Image src = img.Image(width: 300, height: 100);
      img.fillRect(
        src,
        x1: 0,
        y1: 0,
        x2: 299,
        y2: 99,
        color: img.ColorRgb8(255, 255, 255),
      );
      img.fillRect(
        src,
        x1: 100,
        y1: 0,
        x2: 199,
        y2: 99,
        color: img.ColorRgb8(200, 30, 30),
      );
      final Uint8List png = img.encodePng(src);

      final Uint8List out = ProfileImageService.cropSquare(png);
      final img.Image decoded = img.decodeImage(out)!;

      // Interpolation.nearest memetakan piksel tengah langsung dari
      // sumber; JPEG lossy boleh menggeser kanal ±2.
      expect(decoded.getPixel(256, 256).r, closeTo(200, 3));
      expect(decoded.getPixel(256, 256).g, closeTo(30, 3));
      expect(decoded.getPixel(256, 256).b, closeTo(30, 3));
    });

    test('foto potret (tinggi > lebar) tetap persegi penuh', () {
      final img.Image src = img.Image(width: 100, height: 500);
      img.fillRect(
        src,
        x1: 0,
        y1: 0,
        x2: 99,
        y2: 499,
        color: img.ColorRgb8(0, 0, 255),
      );
      final Uint8List png = img.encodePng(src);

      final Uint8List out = ProfileImageService.cropSquare(png);
      final img.Image decoded = img.decodeImage(out)!;

      expect(decoded.width, ProfileImageService.outputSize);
      expect(decoded.height, ProfileImageService.outputSize);
      expect(decoded.getPixel(256, 256).b, closeTo(255, 3));
    });

    test('byte bukan gambar melempar ArgumentError', () {
      expect(
        () => ProfileImageService.cropSquare(<int>[1, 2, 3, 4]),
        throwsArgumentError,
      );
    });

    test('croppedFilePath menambahkan suffix _crop.jpg', () {
      expect(
        ProfileImageService.croppedFilePath('C:/temp/foto.HEIC'),
        'C:/temp/foto_crop.jpg',
      );
      expect(
        ProfileImageService.croppedFilePath('tanpa_ekstensi'),
        'tanpa_ekstensi_crop.jpg',
      );
    });
  });

  group('ProfileImageService.cropRect (8R.2 layar crop)', () {
    test('region terpilih di kiri menghasilkan area putih', () {
      // Region persegi 100x100 di sudut kiri (piksel putih) — hasil
      // TIDAK boleh band merah tengah.
      final Uint8List out = ProfileImageService.cropRect(
        bandPng(),
        const CropRegion(x: 0, y: 0, size: 100),
      );
      final img.Image decoded = img.decodeImage(out)!;
      expect(decoded.width, ProfileImageService.outputSize);
      expect(decoded.height, ProfileImageService.outputSize);
      expect(decoded.getPixel(256, 256).r, closeTo(255, 3));
    });

    test('region di band merah tengah menghasilkan merah', () {
      final Uint8List out = ProfileImageService.cropRect(
        bandPng(),
        const CropRegion(x: 100, y: 0, size: 100),
      );
      final img.Image decoded = img.decodeImage(out)!;
      expect(decoded.getPixel(256, 256).r, closeTo(200, 3));
      expect(decoded.getPixel(256, 256).g, closeTo(30, 3));
    });

    test('region di luar batas di-clamp dan tetap aman', () {
      // x=250 size=100 → clamp ke sisa kanan (50 px), tidak crash.
      final Uint8List out = ProfileImageService.cropRect(
        bandPng(),
        const CropRegion(x: 250, y: 0, size: 100),
      );
      final img.Image decoded = img.decodeImage(out)!;
      expect(decoded.width, ProfileImageService.outputSize);
      expect(decoded.height, ProfileImageService.outputSize);
      // Sisa kanan putih.
      expect(decoded.getPixel(256, 256).r, closeTo(255, 3));
    });

    test('cropSquare = cropRect region baseline', () {
      final List<int> raw = bandPng();
      final Uint8List a = ProfileImageService.cropSquare(raw);
      final Uint8List b = ProfileImageService.cropRect(
        raw,
        ProfileImageService.baseline(
          ProfileImageService.imageSize(raw),
        ),
      );
      expect(img.decodeImage(a)!.getPixel(256, 256).r,
          img.decodeImage(b)!.getPixel(256, 256).r);
    });

    test('imageSize membaca dimensi dan error format lama', () {
      final ImageSize dims = ProfileImageService.imageSize(bandPng());
      expect(dims.width, 300);
      expect(dims.height, 100);
      expect(
        () => ProfileImageService.imageSize(<int>[7, 8, 9]),
        throwsArgumentError,
      );
    });
  });
}
