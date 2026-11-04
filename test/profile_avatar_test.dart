import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remedy_math/controllers/app_controller.dart';
import 'package:remedy_math/core/app_colors.dart';
import 'package:remedy_math/models/models.dart';
import 'package:remedy_math/views/pages/progress_page.dart';
import 'package:remedy_math/views/widgets/app_header.dart';
import 'package:remedy_math/views/widgets/brand.dart';

/// Satu testWidgets untuk seluruh skenario avatar: init controller berat
/// hanya boleh berjalan sekali per file test (dua init beruntun membuat
/// harness menggantung, lihat catatan post_test_gate_test.dart).
void main() {
  testWidgets('8P.4/8P.5 avatar & appbar menampilkan foto profil',
      (tester) async {
   SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppController controller = AppController();
    await controller.init();
    await controller.saveProfile(
      const UserProfile(name: 'Ilham Hamdi', className: 'X A', school: 'SMA 1'),
    );

    // -- Skenario 1: tanpa foto -> latar pink, inisial 'IH'. -------------
    await tester.pumpWidget(
      ChangeNotifierProvider<AppController>.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(body: ProfileAvatar()),
        ),
      ),
    );

    BoxDecoration decorationFor(ProfileAvatar avatar) {
      final Container box = tester.widget<Container>(
        find.descendant(
          of: find.byWidget(avatar),
          matching: find.byType(Container),
        ),
      );
      return box.decoration! as BoxDecoration;
    }

    final ProfileAvatar base = tester.widget<ProfileAvatar>(
      find.byType(ProfileAvatar),
    );
    expect(decorationFor(base).color, AppColors.accentPink);
    expect(find.text('IH'), findsOneWidget);
    expect(find.byType(Image), findsNothing);

    // -- Skenario 2: photoPath ada -> latar transparan + Image dirender --
    const String path = 'X:/upload/foto_crop.jpg';
    await tester.pumpWidget(
      ChangeNotifierProvider<AppController>.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(body: ProfileAvatar(photoPath: path)),
        ),
      ),
    );
    await tester.pump();

    final ProfileAvatar withPhoto = tester.widget<ProfileAvatar>(
      find.byType(ProfileAvatar),
    );
    expect(decorationFor(withPhoto).color, Colors.transparent);
    // Widget Image masih ada sampai error decode terpicu (file tidak ada).
    expect(
      find.descendant(
        of: find.byType(ProfileAvatar),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );

    // -- Skenario 3: appbar meneruskan photoPath profil ke avatar header -
    await controller.saveProfile(
      const UserProfile(
        name: 'Ilham Hamdi',
        className: 'X A',
        school: 'SMA 1',
        photoPath: path,
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppController>.value(
        value: controller,
        child: MaterialApp(
          home: Builder(
            builder: (BuildContext context) =>
                Scaffold(appBar: remediAppBar(context, 'Uji')),
          ),
        ),
      ),
    );
    await tester.pump();

    final ProfileAvatar headerAvatar = tester.widget<ProfileAvatar>(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(ProfileAvatar),
      ),
    );
    expect(headerAvatar.photoPath, path);

    // -- Skenario 4: AppHeader (Beranda) otomatis menampilkan foto profil -
    await tester.pumpWidget(
      ChangeNotifierProvider<AppController>.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(body: AppHeader()),
        ),
      ),
    );
    await tester.pump();

    final ProfileAvatar appHeaderAvatar = tester.widget<ProfileAvatar>(
      find.descendant(
        of: find.byType(AppHeader),
        matching: find.byType(ProfileAvatar),
      ),
    );
    expect(appHeaderAvatar.photoPath, path);
    expect(decorationFor(appHeaderAvatar).color, Colors.transparent);
    expect(
      find.descendant(
        of: find.byType(ProfileAvatar),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );

    // -- Skenario 5: ProgressPage menampilkan avatar foto profil ---------
    await tester.pumpWidget(
      ChangeNotifierProvider<AppController>.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(body: ProgressPage()),
        ),
      ),
    );
    await tester.pump();

    final Iterable<ProfileAvatar> progressAvatars =
        tester.widgetList<ProfileAvatar>(find.byType(ProfileAvatar));
    expect(progressAvatars.isNotEmpty, isTrue);
    for (final ProfileAvatar avatar in progressAvatars) {
      expect(decorationFor(avatar).color, Colors.transparent);
    }
  });
}
