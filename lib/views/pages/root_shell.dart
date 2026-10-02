import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import 'dashboard_page.dart';
import 'diagnostic_page.dart';
import 'progress_page.dart';
import 'remedial_tab_page.dart';

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController c = context.watch<AppController>();
    const List<Widget> pages = <Widget>[
      DashboardPage(),
      DiagnosticPage(),
      RemedialTabPage(),
      ProgressPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: c.tabIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: c.tabIndex,
        onDestinationSelected: c.setTab,
        destinations: const <NavigationDestination>[
          NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Diagnostik'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Remedial'),
          NavigationDestination(
              icon: Icon(Icons.insert_chart_outlined),
              selectedIcon: Icon(Icons.insert_chart),
              label: 'Progres'),
        ],
      ),
    );
  }
}
