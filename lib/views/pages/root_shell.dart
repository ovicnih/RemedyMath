import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import 'dashboard_page.dart';
import 'diagnostic_page.dart';
import 'progress_page.dart';
import 'remedial_tab_page.dart';
import '../widgets/app_bottom_nav.dart';

/// Kerangka utama aplikasi: empat tab dalam [IndexedStack] + navigasi bawah.
///
/// `IndexedStack` dipakai supaya state tiap tab tetap hidup saat pindah.
/// Kalau tab dibangun ulang, remedial yang sudah halfway akan kehilangan
/// progres saat pengguna cek tab Progres lalu kembali.
///
/// Navigasi bawah memakai [AppBottomNav], bukan `NavigationBar` Material.
/// Bentuk neobrutalism-nya ditetapkan di `DESIGN-AUDIT.md` §6.4b: daftar
/// item mengikuti kode (`Beranda`, `Diagnostik`, `Remedial`, `Progres`),
/// bukan desain yang menyebut `Hasil`.
class RootShell extends StatelessWidget {
  const RootShell({super.key});

  /// Item navigasi. `Hasil` sengaja tidak ada: `DiagnosisResultPage`
  /// hanya dicapai lewat `Navigator.push`, jadi menjadikannya tab berarti
  /// mengarang state hasil terakhir yang belum ada di arsitektur.
  static const List<AppBottomNavItem> _destinations = <AppBottomNavItem>[
    AppBottomNavItem(
      label: 'Beranda',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    AppBottomNavItem(
      label: 'Diagnostik',
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
    ),
    AppBottomNavItem(
      label: 'Remedial',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
    ),
    AppBottomNavItem(
      label: 'Progres',
      icon: Icons.insert_chart_outlined,
      selectedIcon: Icons.insert_chart,
    ),
  ];

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    DiagnosticPage(),
    RemedialTabPage(),
    ProgressPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final int tabIndex = context.select<AppController, int>(
      (AppController c) => c.tabIndex,
    );
    final Duration fadeDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 140);

    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: <Widget>[
          for (int i = 0; i < _pages.length; i++)
            AnimatedOpacity(
              opacity: i == tabIndex ? 1.0 : 0.0,
              duration: fadeDuration,
              curve: Curves.easeOut,
              child: _pages[i],
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: tabIndex,
        destinations: _destinations,
        onSelect: context.read<AppController>().setTab,
      ),
    );
  }
}
