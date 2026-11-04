import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:remedy_math/controllers/app_controller.dart';
import 'package:remedy_math/models/models.dart';
import 'package:remedy_math/views/pages/quiz_page.dart';
import 'package:remedy_math/views/widgets/common.dart';

/// Audit §1 + §11.A/§11.F: validasi kuis — semua soal wajib dijawab,
/// submit berulang ditolak, timer habis + jawaban kosong tidak mengirim,
/// jawaban yang sudah dipilih dipertahankan, hasil dipetakan tepat.
void main() {
  Question question(String id) => Question(
        id: id,
        nodeId: 'node',
        category: '',
        moduleLabel: '',
        stem: 'Soal $id',
        expression: '',
        hint: '',
        options: const <String>['A', 'B', 'C', 'D'],
        answerIndex: 0,
        difficulty: 0,
      );

  Widget host({
    required Future<List<int?>?> Function(BuildContext ctx) onStart,
  }) =>
      ChangeNotifierProvider<AppController>(
        create: (_) => AppController(),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => Center(
                child: ElevatedButton(
                  onPressed: () => onStart(context),
                  child: const Text('GO'),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('tidak bisa dikumpulkan selama ada soal kosong; '
      'jawaban dipertahankan; submit sekali mengembalikan jawaban',
      (WidgetTester tester) async {
    // Layar tinggi: seluruh isi ListView terbuild (bukan lazy build).
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Future<List<int?>?> pending = Future<List<int?>?>.value();
    await tester.pumpWidget(host(
      onStart: (BuildContext ctx) => pending = Navigator.of(ctx)
          .push<List<int?>>(MaterialPageRoute<List<int?>>(
        builder: (_) => QuizPage(
          title: 'Diagnostik',
          badge: 'b',
          questions: <Question>[
            question('q1'),
            question('q2'),
            question('q3'),
          ],
          duration: const Duration(minutes: 5),
        ),
      )),
    ));

    await tester.tap(find.text('GO'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPage), findsOneWidget);
    expect(find.text('GO'), findsNothing);

    // Lompat ke soal terakhir lalu tekan Selesai.
    await tester.tap(find.text('Soal berikutnya'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soal berikutnya'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    // Pesan eksplisit muncul; dialog kumpul TIDAK terbuka; halaman tetap ada.
    expect(
      find.textContaining('belum dijawab. Lengkapi semua jawaban'),
      findsOneWidget,
    );
    expect(find.text('Kumpulkan jawaban?'), findsNothing);
    expect(find.byType(QuizPage), findsOneWidget);

    // Jawab semua soal (auto-arah ke soal pertama yang kosong).
    await tester.tap(find.byType(AnswerOption).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soal berikutnya'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AnswerOption).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soal berikutnya'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AnswerOption).first);
    await tester.pumpAndSettle();

    // Selesai → dialog konfirmasi → kumpulkan sekali.
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    expect(find.text('Kumpulkan jawaban?'), findsOneWidget);
    await tester.tap(find.text('Kumpulkan'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPage), findsNothing);
    expect(find.text('GO'), findsOneWidget);

    final List<int?>? returned = await pending;
    expect(returned, <int?>[0, 0, 0]);
  });

  testWidgets('timer habis dengan soal kosong → peringatan, tidak mengirim',
      (WidgetTester tester) async {
    // Layar tinggi: seluruh isi ListView terbuild (bukan lazy build).
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Future<List<int?>?> pending = Future<List<int?>?>.value();
    await tester.pumpWidget(host(
      onStart: (BuildContext ctx) => pending = Navigator.of(ctx)
          .push<List<int?>>(MaterialPageRoute<List<int?>>(
        builder: (_) => QuizPage(
          title: 'Diagnostik',
          badge: 'b',
          questions: <Question>[question('q1'), question('q2')],
          duration: Duration.zero,
        ),
      )),
    ));

    await tester.tap(find.text('GO'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPage), findsOneWidget);

    // Periode timer 1 detik → dialog batas waktu muncul.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Waktu habis'), findsOneWidget);
    expect(find.byType(QuizPage), findsOneWidget);
    expect(find.text('GO'), findsNothing);

    // Tutup dialog, jawab semua, kumpulkan sekali.
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AnswerOption).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soal berikutnya'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AnswerOption).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kumpulkan'));
    await tester.pumpAndSettle();

    final List<int?>? returned = await pending;
    expect(returned, <int?>[0, 0]);
  });
}
