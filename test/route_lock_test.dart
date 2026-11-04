import 'package:flutter_test/flutter_test.dart';

import 'package:remedy_math/controllers/app_controller.dart';
import 'package:remedy_math/models/models.dart';

/// Audit §6 + §11.F: penguncian rute berurutan dan status per node.
///
/// State per node: terkunci · belum dimulai · video selesai (menunggu
/// post-test) · tuntas. Tuntas = video selesai + post-test lulus (≥ 60%).
/// Sesi disimpan newest-first, jadi post-test terakhir menentukan status.
void main() {
  AppController c() => AppController();

  RemedialSession session(String id, int score, bool passed) =>
      RemedialSession(
        nodeId: id,
        title: 'Materi $id',
        label: 'Post-test Remedial',
        score: score,
        passed: passed,
        date: DateTime(2024, 1, 1),
      );

  DiagnosticResult result(List<String> learningPath) => DiagnosticResult(
        theta: 0,
        diagnosticCorrect: 0,
        diagnosticTotal: 3,
        questionIds: const <String>[],
        answers: const <int?>[],
        nodeMastery: const <String, double>{},
        rootCauseId: 'a',
        learningPath: learningPath,
        date: DateTime(2024, 1, 1),
      );

  final List<String> path = <String>['a', 'b', 'c'];

  test('rute pertama terbuka; langkah berikutnya terkunci', () {
    final AppController controller = c()..latestResult = result(path);
    expect(controller.isFinished('a'), isFalse);
    expect(controller.isRouteUnlocked('a'), isTrue);
    expect(controller.isRouteUnlocked('b'), isFalse);
    expect(controller.isRouteUnlocked('c'), isFalse);
  });

  test('video selesai saja tidak menuntaskan (post-test blalu lulus)', () {
    final AppController controller = c()
      ..latestResult = result(path)
      ..studiedNodes.add('a');
    expect(controller.isStudied('a'), isTrue);
    expect(controller.isPassed('a'), isFalse);
    expect(controller.isFinished('a'), isFalse);
    expect(controller.isRouteUnlocked('b'), isFalse);
  });

  test('post-test lulus membuka langkah berikutnya', () {
    final AppController controller = c()
      ..latestResult = result(path)
      ..studiedNodes.add('a')
      ..sessions.add(session('a', 80, true));
    expect(controller.isFinished('a'), isTrue);
    expect(controller.isRouteUnlocked('a'), isTrue);
    expect(controller.isRouteUnlocked('b'), isTrue);
    expect(controller.isRouteUnlocked('c'), isFalse);
  });

  test('post-test gagal membuat rute tetap terkunci', () {
    final AppController controller = c()
      ..latestResult = result(path)
      ..studiedNodes.add('a')
      ..sessions.add(session('a', 40, false));
    expect(controller.isFinished('a'), isFalse);
    expect(controller.isRouteUnlocked('b'), isFalse);
  });

  test('post-test gagal setelah pernah lulus membalik status (terbaru)', () {
    final AppController controller = c()
      ..latestResult = result(path)
      ..studiedNodes.add('a')
      ..sessions.add(session('a', 80, true));
    // Pada `AppController.submitPostTest`, sesi baru dimasukkan pada
    // indeks 0 — yang terbaru dibaca `sessionFor`.
    controller.sessions.insert(0, session('a', 40, false));
    expect(controller.isPassed('a'), isFalse);
    expect(controller.isFinished('a'), isFalse);
    expect(controller.isRouteUnlocked('b'), isFalse);
  });

  test('skor 60 berarti lulus sesuai ambang masteryRatio 0.6', () {
    final AppController controller = c()
      ..latestResult = result(path)
      ..studiedNodes.add('a')
      ..sessions.add(session('a', 60, true));
    expect(controller.isPassed('a'), isTrue);
    expect(controller.isFinished('a'), isTrue);
    expect(controller.isRouteUnlocked('b'), isTrue);
  });

  test('rencana rute: dua status terpisah berbeda maknanya', () {
    final AppController controller = c()
      ..latestResult = result(path)
      ..studiedNodes.add('b')
      ..sessions.add(session('b', 100, true));
    // b tuntas walau bukan akar; a belum tersentuh tetap penghalang c.
    expect(controller.isFinished('b'), isTrue);
    expect(controller.isFinished('a'), isFalse);
    expect(controller.isRouteUnlocked('a'), isTrue);
    expect(controller.isRouteUnlocked('c'), isFalse);
  });
}
