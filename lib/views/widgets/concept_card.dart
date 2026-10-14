import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import 'neo_card.dart';

/// Kartu mikro-belajar mandiri, gaya neobrutalism.
///
/// Bentuk dua lapis sesuai desain: kartu luar **biru** `#70B2FF`, di
/// dalamnya **rangka kuning** `#E2F16D`. Kartu ini menggantikan
/// `VideoPlayerCard` lama: fitur video YouTube dilepas agar aplikasi
/// sepenuhnya offline (lihat `HISTORY.md` v2.4.0), jadi kartu tidak lagi
/// menjadi target sentuh apa pun — rumus dan poin kunci di bawahnya sudah
/// menjadi isi pembelajarannya.
///
/// Spesifikasi asal: `UI-REFERENCE.md` §4.4 item 2.
///
/// ## Rasio, bukan tinggi mati
///
/// `Halaman4.Dart` memakai `padding` vertikal 141 px. Angka itu tidak
/// boleh disalin ke Flutter sebagai `SizedBox(height: 141)` karena
/// melanggar `AGENTS.md` §2. Diganti [AspectRatio] — lebar mengikuti
/// parent, tinggi ikut lebarnya.
///
/// ## Penandaan "telah dipelajari"
///
/// [studied] tidak memicu apa pun. Widget ini murni tampilan; penandaan
/// milik halaman lewat tombol eksplisitnya.
class ConceptCard extends StatelessWidget {
  const ConceptCard({
    super.key,
    required this.formula,
    this.studied = false,
    this.aspectRatio = 16 / 9,
    this.hint = 'Konsep inti · lihat poin kunci',
    this.eyebrow = 'RemedyMath · Mikro-Belajar',
  });

  /// Rumus besar di tengah, mis. `−(a − b) = −a + b`.
  final String formula;

  /// Menampilkan badge "Dipahami".
  final bool studied;

  /// Rasio lebar:tinggi. Default 16:9.
  final double aspectRatio;

  /// Teks hint di bawah ikon.
  final String hint;

  /// Label pill di bagian atas.
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.accentBlue,
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: NeoCard(
          // Rangka kuning: `elevated: false` supaya bayangan kartu luar
          // tetap terbaca sebagai satu blok, bukan dua garis offset
          // bertumpuk.
          elevated: false,
          color: AppColors.accentYellow,
          padding: const EdgeInsets.all(AppSizes.spaceMd),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: _EyebrowPill(label: eyebrow),
                  ),
                  if (studied) ...<Widget>[
                    const SizedBox(width: AppSizes.spaceSm),
                    const _StudiedBadge(),
                  ],
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (formula.isNotEmpty)
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(formula, style: AppTextStyles.mathDisplay),
                          ),
                        ),
                      const SizedBox(height: AppSizes.spaceSm),
                      const _BookGlyph(),
                    ],
                  ),
                ),
              ),
              Text(
                hint,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill pink di atas kartu: bg `accentPink`, radius 8, border 2 px.
/// `Flexible` pada pemanggilnya supaya label panjang melebar dan
/// menyusut, bukan meluber.
class _EyebrowPill extends StatelessWidget {
  const _EyebrowPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentPink,
        borderRadius: AppSizes.radius(AppSizes.radiusChip),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThin),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}

/// Badge hijau "Dipahami". Hijau punya kontras 1.20:1 terhadap putih
/// (`contrast_test.dart`), jadi teksnya tetap `ink` dan tidak pernah
/// putih di atas hijau.
class _StudiedBadge extends StatelessWidget {
  const _StudiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentGreen,
        borderRadius: AppSizes.radius(AppSizes.radiusChip),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThin),
      ),
      child: const Text('Dipahami', style: AppTextStyles.caption),
    );
  }
}

/// Glyph buku 44×44: bg putih, radius 10, border 3 px, bayangan
/// `Offset(4, 4)`, ikon 16 px. Murni visual — kartu tidak lagi jadi
/// target sentuh karena tidak ada tautan keluar.
class _BookGlyph extends StatelessWidget {
  const _BookGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
        boxShadow: AppSizes.shadowCard,
      ),
      child: const Icon(Icons.menu_book, size: 16, color: AppColors.ink),
    );
  }
}
