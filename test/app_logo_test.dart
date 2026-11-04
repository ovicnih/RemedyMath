import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remedy_math/core/app_assets.dart';
import 'package:remedy_math/views/widgets/brand.dart';

void main() {
  testWidgets('8R.5 AppLogo memuat logo asset buatan pengguna',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: AppLogo(size: 80))),
      ),
    );
    await tester.pump();

    // Widget Image dengan AssetImage terpasang.
    final Image image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, AppAssets.logo);
    // Glif sigma fallback tidak ditampilkan ketika asset OK.
    expect(find.text('Σ'), findsNothing);
  });

  testWidgets('8R.5 asset gagal → fallback glyph sigma', (tester) async {
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
