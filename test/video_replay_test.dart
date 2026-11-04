import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remedy_math/controllers/app_controller.dart';
import 'package:remedy_math/views/pages/remedial_page.dart';
import 'package:remedy_math/views/widgets/video_lesson.dart';

/// 8R.4: video tetap ada setelah selesai dan dapat diulang kembali.
const String _nodeId = 'n_operasi_bilangan';

Future<void> _pumpStudiedRemedial(WidgetTester tester) async {
  // Layar tinggi: seluruh ListView terbuild (hindari lazy build).
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final AppController controller = AppController();
  await controller.init();
  await controller.markStudied(_nodeId);

  await tester.pumpWidget(
    ChangeNotifierProvider<AppController>.value(
      value: controller,
      child: const MaterialApp(home: RemedialPage(nodeId: _nodeId)),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('video tetap tampil setelah selesai + tombol ulang video',
      (WidgetTester tester) async {
    await _pumpStudiedRemedial(tester);

    // Pemutar video tetap ada di rute belajar (tidak dihilangkan).
    expect(find.byType(VideoLessonPlayer), findsOneWidget);

    // Status selesai ditampilkan dan post-test sudah terbuka.
    expect(
      find.text('✓ Video selesai ditonton. Post-test sudah bisa dibuka.'),
      findsOneWidget,
    );
    expect(find.text('Mulai post-test'), findsOneWidget);

    // Tombol putar ulang tersedia.
    expect(find.text('Ulangi video'), findsOneWidget);
  });
}
