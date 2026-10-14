import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remedy_math/core/app_colors.dart';
import 'package:remedy_math/core/app_sizes.dart';
import 'package:remedy_math/views/widgets/neo_card.dart';

void main() {
  group('NeoCard.borderFor', () {
    test('border default memakai tinta dan lebar borderThick', () {
      final Border b = NeoCard.borderFor(AppColors.ink);
      expect(b.isUniform, isTrue);
      expect(b.top.color, AppColors.ink);
      expect(b.top.width, AppSizes.borderThick);
    });

    test('border kustom memakai warna yang diminta di keempat sisi', () {
      final Border b = NeoCard.borderFor(AppColors.accentBlue);
      expect(b.isUniform, isTrue);
      expect(b.top.color, AppColors.accentBlue);
      expect(b.right.color, AppColors.accentBlue);
      expect(b.bottom.color, AppColors.accentBlue);
      expect(b.left.color, AppColors.accentBlue);
      expect(b.left.width, AppSizes.borderThick);
    });

    test('border selalu seragam agar boleh dipadukan dengan radius', () {
      // Flutter melempar assertion saat paint bila borderRadius diberikan
      // pada Border yang warna sisinya berbeda. Ini yang membuat stripe per
      // sisi lama tidak pernah bisa dirender.
      for (final Color c in <Color>[
        AppColors.ink,
        AppColors.accentPink,
        AppColors.accentBlue,
        AppColors.accentGreen,
        AppColors.surface,
      ]) {
        expect(NeoCard.borderFor(c).isUniform, isTrue, reason: '$c');
      }
    });
  });

  group('NeoCard widget', () {
    Future<void> pump(
      WidgetTester tester, {
      Color? color,
      Color? borderColor,
      bool elevated = true,
      VoidCallback? onTap,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoCard(
              color: color ?? AppColors.surface,
              borderColor: borderColor ?? AppColors.ink,
              elevated: elevated,
              onTap: onTap,
              child: const SizedBox(width: 40, height: 40),
            ),
          ),
        ),
      );
    }

    BoxDecoration decorationOf(WidgetTester tester) =>
        tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration
            as BoxDecoration;

    testWidgets('merender child yang diberikan', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoCard(child: Text('isi kartu')),
          ),
        ),
      );
      expect(find.text('isi kartu'), findsOneWidget);
    });

    testWidgets('memakai radiusCard dan bayangan kartu', (WidgetTester tester) async {
      await pump(tester);
      final BoxDecoration d = decorationOf(tester);
      expect(d.borderRadius, AppSizes.radius(AppSizes.radiusCard));
      expect(d.boxShadow, AppSizes.shadowCard);
      final BoxShadow shadow = d.boxShadow!.first;
      expect(shadow.offset, AppSizes.shadowOffset);
      expect(shadow.blurRadius, AppSizes.shadowBlur);
      expect(shadow.spreadRadius, AppSizes.shadowSpread);
      expect(shadow.color, AppColors.ink);
    });

    testWidgets('elevated false menghapus bayangan', (WidgetTester tester) async {
      await pump(tester, elevated: false);
      expect(decorationOf(tester).boxShadow, isNull);
    });

    testWidgets('warna latar bawaan adalah surface', (WidgetTester tester) async {
      await pump(tester);
      expect(decorationOf(tester).color, AppColors.surface);
    });

    testWidgets('warna latar kustom dipakai utuh', (WidgetTester tester) async {
      await pump(tester, color: AppColors.accentYellow);
      expect(decorationOf(tester).color, AppColors.accentYellow);
    });

    testWidgets('borderColor bawaan adalah tinta', (WidgetTester tester) async {
      await pump(tester);
      expect(decorationOf(tester).border, NeoCard.borderFor(AppColors.ink));
    });

    testWidgets('borderColor kustom diterapkan dan tetap seragam',
        (WidgetTester tester) async {
      await pump(tester, borderColor: AppColors.accentBlue);
      final Border b = decorationOf(tester).border as Border;
      expect(b.top.color, AppColors.accentBlue);
      expect(b.isUniform, isTrue);
    });

    testWidgets('kartu dengan border kustom benar-benar ter-paint tanpa error',
        (WidgetTester tester) async {
      // Regression test: border per sisi pernah melempar assertion
      // "A borderRadius can only be given on borders with uniform colors".
      await pump(tester, borderColor: AppColors.accentBlue);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('padding bawaan adalah spaceLg', (WidgetTester tester) async {
      await pump(tester);
      final Padding padding = tester.widget<Padding>(
        find
            .descendant(of: find.byType(NeoCard), matching: find.byType(Padding))
            .first,
      );
      expect(padding.padding, const EdgeInsets.all(AppSizes.spaceLg));
    });

    testWidgets('onTap dipanggil saat kartu ditekan', (WidgetTester tester) async {
      int tapped = 0;
      await pump(tester, onTap: () => tapped++);
      await tester.tap(find.byType(NeoCard));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('tanpa onTap tidak ada handler yang bisa ditekan',
        (WidgetTester tester) async {
      await pump(tester);
      expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
    });
  });
}
