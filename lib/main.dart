import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'controllers/app_controller.dart';
import 'core/app_constants.dart';
import 'core/app_theme.dart';
import 'views/pages/onboarding_page.dart';
import 'views/pages/root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id');
  final AppController controller = AppController();
  await controller.init();
  runApp(
    ChangeNotifierProvider<AppController>.value(
      value: controller,
      child: const RemediMathApp(),
    ),
  );
}

class RemediMathApp extends StatelessWidget {
  const RemediMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool hasProfile =
        context.select<AppController, bool>((c) => c.profile != null);
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: hasProfile ? const RootShell() : const OnboardingPage(),
    );
  }
}
