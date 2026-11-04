import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remedy_math/controllers/app_controller.dart';
import 'package:remedy_math/views/pages/quiz_page.dart';
import 'package:remedy_math/views/pages/remedial_page.dart';

/// 8P.2: setelah video selesai (termasuk pengguna yang melewatkan video ke
/// ujung — masuk lewat `markStudied`), tombol "Mulai post-test" di halaman
/// materi harus aktif dan dapat membuka kuis.
///
/// Catatan: semua node data memakai video; pemutar video tidak dibangun
/// saat materi sudah dipelajari, sehingga test widget berjalan tanpa
/// webview.
void main() {
  const String nodeId = 'n_operasi_bilangan';

  Future<AppController> freshController() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppController controller = AppController();
    await controller.init();
    return controller;
  }

  testWidgets('video selesai: tombol Mulai post-test aktif dan membuka kuis',
      (WidgetTester tester) async {
    // Layar tinggi: seluruh isi ListView terbuild (bukan lazy build).
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final AppController controller = await freshController();
    await controller.markStudied(nodeId);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppController>.value(
        value: controller,
        child: const MaterialApp(
          home: RemedialPage(nodeId: nodeId),
        ),
      ),
    );

    final Finder button = find.text('Mulai post-test');
    expect(button, findsOneWidget);
    expect(find.byType(QuizPage), findsNothing);
    // 8R.1/8R.3: kartu mikro-belajar tidak ada lagi di rute belajar.
    expect(find.text('RemedyMath · Mikro-Belajar'), findsNothing);
    expect(find.text('Konsep inti · lihat poin kunci'), findsNothing);

    await tester.tap(button);
    // Route transition; hindari pumpAndSettle karena kuis punya timer
    // periodik yang terus memicu frame.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(QuizPage), findsOneWidget);
  });
}
