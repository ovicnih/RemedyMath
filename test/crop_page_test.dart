import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import 'package:remedy_math/controllers/app_controller.dart';
import 'package:remedy_math/views/pages/crop_page.dart';

/// 8S.2: bingkai tetap tengah, foto pan+zoom di belakang.
///
/// Gambar uji: 200x100 putih dengan stripe merah sempit di x=90..110.
Uint8List stripePng() {
  final img.Image src = img.Image(width: 200, height: 100);
  img.fillRect(
    src,
    x1: 0,
    y1: 0,
    x2: 199,
    y2: 99,
    color: img.ColorRgb8(255, 255, 255),
  );
  img.fillRect(
    src,
    x1: 90,
    y1: 0,
    x2: 110,
    y2: 99,
    color: img.ColorRgb8(200, 30, 30),
  );
  return img.encodePng(src);
}

class _BukaCrop extends StatelessWidget {
  const _BukaCrop({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: const Text('Buka Crop'));
  }
}

/// Temukan GestureDetector yang memuat foto (SizedBox persegi besar).
Finder _imageGesture(WidgetTester tester) {
  final Finder f = find.byWidgetPredicate((Widget w) =>
      w is GestureDetector &&
      w.child is SizedBox &&
      (w.child as SizedBox).width != null &&
      (w.child as SizedBox).width == (w.child as SizedBox).height &&
      (w.child as SizedBox).width! > 200);
  expect(f, findsOneWidget);
  return f;
}

Future<Uint8List?> _openAndSave(WidgetTester tester,
    {Offset? dragFrom,
    Offset? dragTo,
    Future<void> Function(WidgetTester tester)? beforeSave}) async {
  tester.view.physicalSize = const Size(700, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  Uint8List? received;
  await tester.pumpWidget(
    ChangeNotifierProvider<AppController>.value(
      value: AppController(),
      child: MaterialApp(
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: _BukaCrop(
                onPressed: () async {
                  received = await Navigator.of(context).push<Uint8List>(
                    MaterialPageRoute<Uint8List>(
                      builder: (_) => CropPage(rawBytes: stripePng()),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Buka Crop'));
  await tester.pump();
  await tester.pump();
  expect(find.text('Simpan'), findsOneWidget);

  if (dragFrom != null && dragTo != null) {
    final Finder gesture = _imageGesture(tester);
    final Offset topLeft = tester.getTopLeft(gesture);
    final Size size = tester.getSize(gesture);
    final Offset center = topLeft + Offset(size.width / 2, size.height / 2);
    final TestGesture g = await tester.startGesture(center + dragFrom);
    await g.moveTo(center + dragTo);
    await g.up();
    await tester.pump();
  }

  if (beforeSave != null) {
    await beforeSave(tester);
    await tester.pump();
  }

  await tester.tap(find.text('Simpan'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  return received;
}

void main() {
  testWidgets('baseline Simpan: crop tengah berisi stripe merah',
      (WidgetTester tester) async {
    final Uint8List? received = await _openAndSave(tester);
    expect(received, isNotNull);
    final img.Image result = img.decodeImage(received!)!;
    expect(result.width, 512);
    expect(result.height, 512);
    // Tengah output memetakan ke pusat gambar sumber (x≈100) → di dalam
    // stripe merah (90..110).
    expect(result.getPixel(256, 256).r, closeTo(200, 3));
  });

  testWidgets('geser foto ke kiri: tengah hasil di luar stripe → putih',
      (WidgetTester tester) async {
    final Uint8List? received = await _openAndSave(
      tester,
      dragFrom: Offset.zero,
      dragTo: const Offset(-400, 0), // geser kiri jauh (diklamp)
    );
    expect(received, isNotNull);
    final img.Image result = img.decodeImage(received!)!;
    expect(result.width, 512);
    expect(result.height, 512);
    // Geser kiri maksimum → window crop di x≈100..200, pusat ≈150 → di
    // luar stripe (90..110) → putih.
    expect(result.getPixel(256, 256).r, closeTo(255, 3));
  });

  testWidgets(
      'tombol Pusatkan: foto digeser lalu dipusatkan kembali ke stripe merah',
      (WidgetTester tester) async {
    final Uint8List? received = await _openAndSave(
      tester,
      dragFrom: Offset.zero,
      dragTo: const Offset(-400, 0),
      beforeSave: (WidgetTester t) async {
        await t.tap(find.text('Pusatkan'));
      },
    );
    expect(received, isNotNull);
    final img.Image result = img.decodeImage(received!)!;
    expect(result.width, 512);
    expect(result.height, 512);
    // Setelah Pusatkan ditekan, crop kembali ke tengah (stripe merah)
    expect(result.getPixel(256, 256).r, closeTo(200, 3));
  });

  testWidgets(
      'tombol Reset: foto digeser lalu direset kembali ke stripe merah',
      (WidgetTester tester) async {
    final Uint8List? received = await _openAndSave(
      tester,
      dragFrom: Offset.zero,
      dragTo: const Offset(-400, 0),
      beforeSave: (WidgetTester t) async {
        await t.tap(find.text('Reset'));
      },
    );
    expect(received, isNotNull);
    final img.Image result = img.decodeImage(received!)!;
    expect(result.width, 512);
    expect(result.height, 512);
    // Setelah Reset ditekan, crop kembali ke cover baseline (stripe merah)
    expect(result.getPixel(256, 256).r, closeTo(200, 3));
  });
}
