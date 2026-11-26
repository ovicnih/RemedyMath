import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remedy_math/core/app_assets.dart';
import 'package:remedy_math/views/widgets/brand.dart';

void main() {
  testWidgets('8S.1 AppLogo memuat logo asset baru dengan cacheWidth',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: AppLogo(size: 80))),
      ),
    );
    await tester.pump();

    // Widget Image dengan AssetImage (dibungkus ResizeImage untuk cacheWidth).
    final Image image = tester.widget<Image>(find.byType(Image));
    final ImageProvider provider = image.image;
    final AssetImage asset = provider is ResizeImage
        ? provider.imageProvider as AssetImage
        : provider as AssetImage;
    expect(asset.assetName, AppAssets.logo);
    expect(provider, isA<ResizeImage>());
    // Glif sigma fallback tidak ditampilkan ketika asset OK.
    expect(find.text('Σ'), findsNothing);
  });

  testWidgets('8S.1 asset gagal → fallback kotak kuning glyph sigma',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AppLogo(size: 80, logoPath: 'tidak/ada.png')),
        ),
      ),
    );
    // errorBuilder dipasang asinkron; beri frame.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Σ'), findsOneWidget);
  });
}
