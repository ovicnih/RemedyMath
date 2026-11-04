import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remedy_math/controllers/app_controller.dart';
import 'package:remedy_math/views/pages/review_page.dart';

/// 8P.1: pembahasan soal tidak lagi menampilkan kotak penilaian dua warna
/// ("Yang salah" merah dan "Yang benar" hijau). Kartu netral tinta.
void main() {
  testWidgets('Pembahasan tidak punya panel Yang salah dan Yang benar',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppController controller = AppController();
    await controller.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppController>.value(
        value: controller,
        child: const MaterialApp(home: ReviewPage()),
      ),
    );

    expect(find.text('Soal 1'), findsOneWidget);
    expect(find.text('Yang benar'), findsNothing);
    expect(find.text('Yang salah'), findsNothing);
  });
}
