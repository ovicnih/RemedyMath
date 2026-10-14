import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import 'neo_card.dart';

/// Kartu video mikro-belajar, gaya neobrutalism.
///
/// Bentuk dua lapis sesuai desain: kartu luar **biru** `#70B2FF`, di
/// dalamnya **rangka kuning** `#E2F16D`. Pemisahan warna itu bukan
/// hiasan — yellow frame menandai area yang bisa diketuk, jadi fingertip
/// tahu di mana letak target.
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
/// Rasio 16:9 dipakai karena itu yang sudah berjalan di kode lama dan
/// tata letak kartu video di Android umumnya 16:9. Lihat `TODO.md`
/// "Tentukan rasio kartu video".
///
/// ## Penandaan "telah ditonton"
///
/// [watched] tidak memicu apa pun. Widget ini murni tampilan. Penandaan
/// tetap milik halaman lewat callback-nya — lihat `TODO.md` "Perbaiki
/// penandaan video yang terlalu optimistis".
///
/// ## Teks hint
///
/// Default `Buka di YouTube`, bukan "ketuk untuk melihat ringkasan".
/// kartu ini tidak punya layar ringkasan; mengetuknya cuma melempar ke
/// aplikasi YouTube, jadi hint harus menyebut apa yang benar-benar terjadi.
class VideoPlayerCard extends StatelessWidget {
  const VideoPlayerCard({
    super.key,
    required this.formula,
    required this.onPlay,
    this.watched = false,
    this.aspectRatio = 16 / 9,
    this.hint = 'Buka di YouTube',
    this.eyebrow = 'RemedyMath · Mikro-Belajar',
  });

  /// Rumus besar di tengah, mis. `−(a − b) = −a + b`.
  final String formula;

  /// Aksi saat kartu diketuk. Biasanya membuka video.
  final VoidCallback onPlay;

  /// Menampilkan badge "Ditonton".
  final bool watched;

  /// Rasio lebar:tinggi. Default 16:9.
  final double aspectRatio;

  /// Teks hint di bawah tombol putar.
  final String hint;

  /// Label pill di bagian atas.
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    // Seluruh kartu adalah target sentuh, bukan hanya tombol putar.
    // `NeoCard` sudah membungkus child-nya dengan `Semantics` + gesture,
    // jadi tidak ada dua target tumpang tindih yang dilaporkan ke
    // pembaca layar.
    return NeoCard(
      color: AppColors.accentBlue,
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      onTap: onPlay,
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
                  if (watched) ...<Widget>[
                    const SizedBox(width: AppSizes.spaceSm),
                    const _WatchedBadge(),
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
                      const _PlayGlyph(),
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

/// Badge hijau "Ditonton". Hijau punya kontras 1.20:1 terhadap putih
/// (`contrast_test.dart`), jadi teksnya tetap `ink` dan tidak pernah
/// putih di atas hijau.
class _WatchedBadge extends StatelessWidget {
  const _WatchedBadge();

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
      child: const Text('Ditonton', style: AppTextStyles.caption),
    );
  }
}

/// Tombol putar 44×44: bg putih, radius 10, border 3 px, bayangan
/// `Offset(4, 4)`, ikon 16 px. Murni visual — gesture ada di kartu
/// luar supaya tidak ada dua target sentuh yang saling tumpang tindih.
class _PlayGlyph extends StatelessWidget {
  const _PlayGlyph();

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
      child: const Icon(Icons.play_arrow_rounded, size: 16, color: AppColors.ink),
    );
  }
}
