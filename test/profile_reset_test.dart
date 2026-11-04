import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remedy_math/controllers/app_controller.dart';
import 'package:remedy_math/models/models.dart';
import 'package:remedy_math/services/local_storage_service.dart';

/// Audit §9 + §11.F: logout menghapus data; profil baru langsung masuk
/// Beranda (RootShell) TANPA refresh — `saveProfile` dan `resetAll`
/// memanggil `notifyListeners`, jadi pergantian `home` di `main.dart`
/// terjadi instan (dilacak di sini dengan struktur yang sama).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('penyimpanan lokal: profil tersimpan dan terbaca ulang', () async {
    final LocalStorageService storage = LocalStorageService();
    await storage.init();
    await storage.saveProfile(const UserProfile(
      name: 'Ilham',
      className: 'SMA Kelas 10',
      school: 'SMA Sigma',
    ));
    final UserProfile? loaded = storage.loadProfile();
    expect(loaded, isNotNull);
    expect(loaded!.name, 'Ilham');
    expect(loaded.className, 'SMA Kelas 10');
  });

  test('sesi + penanda sudah dipelajari tersimpan lalu dihapus clearAll',
      () async {
    final LocalStorageService storage = LocalStorageService();
    await storage.init();
    await storage.saveStudied(<String>{'node_a', 'node_b'});
    await storage.saveSessions(<RemedialSession>[
      RemedialSession(
        nodeId: 'node_a',
        title: 'Materi A',
        label: 'Post-test Remedial',
        score: 80,
        passed: true,
        date: DateTime(2024, 1, 1),
      ),
    ]);
    expect(storage.loadStudied().contains('node_a'), isTrue);
    expect(storage.loadSessions().single.passed, isTrue);

    // Logout sesuai rancangan: resetAll → clearAll semua data.
    await storage.clearAll();
    expect(storage.loadProfile(), isNull);
    expect(storage.loadLatestResult(), isNull);
    expect(storage.loadSessions(), isEmpty);
    expect(storage.loadStudied(), isEmpty);
  });

  testWidgets('profil baru disimpan → Beranda tampil segera; '
      'logout → kembali ke Onboarding', (WidgetTester tester) async {
    final LocalStorageService storage = LocalStorageService();
    await storage.init();
    final AppController controller = AppController(storage: storage);

    // Struktur yang sama dengan `main.dart` §39:
    // home = hasProfile ? RootShell : OnboardingPage.
    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedBuilder(
          animation: controller,
          builder: (_, __) => Directionality(
            textDirection: TextDirection.ltr,
            child: Text(controller.profile == null ? 'ONBOARDING' : 'BERANDA'),
          ),
        ),
      ),
    );
    expect(find.text('ONBOARDING'), findsOneWidget);
    expect(find.text('BERANDA'), findsNothing);

    // Pengguna mengisi onboarding — `saveProfile` memanggil notifyListeners.
    await controller.saveProfile(const UserProfile(
      name: 'Budi',
      className: 'SMA Kelas 10',
      school: 'SMA',
    ));
    await tester.pump();
    expect(find.text('BERANDA'), findsOneWidget);
    expect(find.text('ONBOARDING'), findsNothing);

    // Logout — `resetAll` mengembalikan Onboarding tanpa restart.
    await controller.resetAll();
    await tester.pump();
    expect(find.text('ONBOARDING'), findsOneWidget);

    // Proses berulang tetap benar (audit §9 item 6).
    await controller.saveProfile(const UserProfile(
      name: 'Sari',
      className: 'SMA Kelas 10',
      school: 'SMA',
    ));
    await tester.pump();
    expect(find.text('BERANDA'), findsOneWidget);
  });
}
