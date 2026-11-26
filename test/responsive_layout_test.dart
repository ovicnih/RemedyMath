import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remedy_math/controllers/app_controller.dart';
import 'package:remedy_math/core/app_theme.dart';
import 'package:remedy_math/models/models.dart';
import 'package:remedy_math/services/local_storage_service.dart';
import 'package:remedy_math/views/pages/crop_page.dart';
import 'package:remedy_math/views/pages/dashboard_page.dart';
import 'package:remedy_math/views/pages/diagnostic_page.dart';
import 'package:remedy_math/views/pages/onboarding_page.dart';
import 'package:remedy_math/views/pages/progress_page.dart';
import 'package:remedy_math/views/pages/remedial_tab_page.dart';
import 'package:remedy_math/views/pages/settings_page.dart';

Uint8List _samplePng() {
  final img.Image pic = img.Image(width: 120, height: 120);
  img.fill(pic, color: img.ColorRgb8(226, 241, 109));
  return Uint8List.fromList(img.encodePng(pic));
}

Future<AppController> _makeController() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final LocalStorageService storage = LocalStorageService();
  final AppController controller = AppController(storage: storage);
  await controller.init();
  await controller.saveProfile(const UserProfile(
    name: 'Nadia Putri',
    className: 'SMA Kelas 10',
    school: 'SMAN 1 Bandung',
  ));
  return controller;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const List<Size> viewports = <Size>[
    Size(360, 640),
    Size(412, 915),
  ];

  final Uint8List pngBytes = _samplePng();

  for (final Size size in viewports) {
    final String label = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('5.8/9.5 layout responsif tanpa overflow pada $label',
        (WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final AppController controller =
          (await tester.runAsync(_makeController))!;
      addTearDown(controller.dispose);

      final List<Widget> pages = <Widget>[
        const OnboardingPage(),
        const DashboardPage(),
        const DiagnosticPage(),
        const RemedialTabPage(),
        const ProgressPage(),
        const SettingsPage(),
        CropPage(rawBytes: pngBytes),
      ];

      for (final Widget page in pages) {
        await tester.pumpWidget(
          ChangeNotifierProvider<AppController>.value(
            value: controller,
            child: MaterialApp(
              theme: AppTheme.light(),
              home: page,
            ),
          ),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: '${page.runtimeType} tidak boleh overflow pada $label',
        );
      }
    });
  }
}
