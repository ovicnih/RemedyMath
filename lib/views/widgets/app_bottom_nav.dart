import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';

/// Bottom navigation gaya neobrutalism.
///
/// Menggantikan `NavigationBar` Material. Bedanya bukan kosmetik —
/// `NavigationBar` memakai indikator pill **melayang** di atas ikon,
/// sedangkan desain memakai pill yang **mengisi seluruh item** dan punya
/// border hitam 3 px.
///
/// Spesifikasi asal: `UI-REFERENCE.md` §"Keputusan navigasi" — "pill aktif
/// diisi `accentYellow` dengan border hitam 3 px, label w700".
///
/// ## Daftar item
///
/// Item di kode dipertahankan apa adanya: `Beranda`, `Diagnostik`,
/// `Remedial`, `Progres`. Desain menyebut `Hasil` di posisi ketiga, tapi
/// `DiagnosisResultPage` hanya pernah dicapai lewat `Navigator.push` dan
/// tidak pernah masuk daftar `pages` — menjadikannya tab berarti mengarang
/// state hasil terakhir yang belum ada. Lihat `DESIGN-AUDIT.md` §6.4b.
///
/// Widget ini tidak mengubah tinggi dengan sendirinya; parent yang
/// menentukan lewat [SafeArea].
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.destinations,
  });

  /// Index tab yang sedang aktif.
  final int currentIndex;

  /// Aksi saat item ditekan. Menerima index tujuan.
  final ValueChanged<int> onSelect;

  /// Daftar item navigasi. Biasanya empat item.
  final List<AppBottomNavItem> destinations;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceMd,
            vertical: AppSizes.spaceSm,
          ),
          child: Row(
            children: <Widget>[
              for (int i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavPill(
                    item: destinations[i],
                    selected: i == currentIndex,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu item bottom navigation.
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  /// Teks label, mis. `Beranda`.
  final String label;

  /// Ikon saat tidak aktif.
  final IconData icon;

  /// Ikon saat aktif.
  final IconData selectedIcon;
}

/// Pill item. Aktif = bg kuning + border 3 px; nonaktif = transparan
/// tanpa border, tapi tetap menyimpan ruang border agar tinggi stabil.
class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = AppColors.ink;

    return Padding(
      // Jarak 4 px antar pill. `spaceXs` = 4.
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceXs),
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceSm,
              vertical: AppSizes.spaceSm,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.accentYellow : Colors.transparent,
              // `radiusPill` — endpoint bulat penuh. Nama "pill" pada
              // desain berarti sudutnya membulat penuh, bukan `radiusCard`.
              borderRadius: AppSizes.radius(AppSizes.radiusPill),
              border: Border.all(
                color: selected ? AppColors.ink : Colors.transparent,
                width: AppSizes.borderThick,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 20,
                  color: foreground,
                ),
                const SizedBox(height: AppSizes.spaceXs),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // w700 untuk aktif maupun nonaktif — desain hanya
                  // membedakan warna isi dan border, bukan ketebalan teks.
                  style: AppTextStyles.caption.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
