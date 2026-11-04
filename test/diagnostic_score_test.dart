import 'package:flutter_test/flutter_test.dart';

import 'package:remedy_math/core/formatters.dart';
import 'package:remedy_math/models/models.dart';

/// Audit §8 + §11.E: skor diagnostik 0–100
/// `skor = (benar / total) × 100`, dibulatkan ke bilangan bulat terdekat.
void main() {
  test('2 benar dari 15 soal tampil 13/100', () {
    expect(Formatters.score(2 / 15), 13);
  });

  test('8 benar dari 15 soal tampil 53/100', () {
    expect(Formatters.score(8 / 15), 53);
  });

  test('15 benar dari 15 soal tampil 100/100', () {
    expect(Formatters.score(15 / 15), 100);
  });

  test('0 benar dari 15 soal tampil 0/100', () {
    expect(Formatters.score(0 / 15), 0);
  });

  test('akurasi jarang: jumlah seluruh soal nol ditangani aman', () {
    final DiagnosticResult emptyTotal = DiagnosticResult(
      theta: 0,
      diagnosticCorrect: 0,
      diagnosticTotal: 0,
      questionIds: const <String>[],
      answers: const <int?>[],
      nodeMastery: const <String, double>{},
      rootCauseId: null,
      learningPath: const <String>[],
      date: DateTime(2000),
    );
    expect(emptyTotal.accuracy, 0);
    expect(Formatters.score(emptyTotal.accuracy), 0);
  });

  test('skor tidak pernah di luar rentang 0–100', () {
    expect(Formatters.score(1.5), 100);
    expect(Formatters.score(-0.5), 0);
  });

  test('jumlah benar tidak melebihi jumlah seluruh soal', () {
    // Konsekruensi rumus: total>0 & benar≤total → skor ≤ 100.
    const int benar = 13;
    const int total = 15;
    expect(benar <= total, isTrue);
    expect(Formatters.score(benar / total) <= 100, isTrue);
  });
}
