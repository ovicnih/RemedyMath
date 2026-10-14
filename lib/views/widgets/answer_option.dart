import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import 'neo_card.dart';

/// Satu opsi jawaban pada halaman kuis, gaya neobrutalism.
///
/// Bentuk sesuai desain: kartu putih radius 10, border 3 px, bayangan
/// `Offset(4, 4)`, padding 16; **radio 20 px** bg putih border 1 px
/// `#767676`; **badge huruf 32×32** bg `#E2F16D` radius 8 border 2 px
/// w900; teks opsi 15 w900.
///
/// Spesifikasi asal: `UI-REFERENCE.md` §4.2 item 5.
///
/// ## State terpilih — ditetapkan di sini, bukan dari desain
///
/// Desain `Halaman2.Dart` menampilkan empat opsi tanpa satu pun terpilih,
/// jadi tidak ada acuan visual. Keputusan yang dipakai:
///
/// * **Border kartu** `ink` → `accentBlue` ketika terpilih.
/// * **Badge huruf** `accentYellow` → `accentBlue` ketika terpilih.
/// * **Radio** garis `radioBorder` → lingkaran penuh `ink`.
/// * **Teks** tetap w900 di kedua state — desain sudah menetapkan w900
///   untuk semua opsi, jadi tidak ada state yang harus berubah di sini.
///
/// Warna bukan satu-satunya pembawa makna: radio berubah dari garis jadi
/// lingkaran penuh, jadi state tetap terbaca tanpa warna (WCAG 1.4.1).
///
/// Kenapa `accentBlue` dan bukan `accentGreen`: `accentGreen` kontrasnya
/// hanya 1.20 terhadap `surface` — tidak terbaca. `accentBlue` 7.87.
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    this.onTap,
  });

  /// Huruf opsi: `A`, `B`, `C`, `D`.
  final String letter;

  /// Isi opsi, boleh berupa rumus matematika.
  final String text;

  /// `true` kalau opsi ini sedang dipilih.
  final bool selected;

  /// Aksi saat diketuk. `null` membuat kartu non-interaktif.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = selected ? AppColors.accentBlue : AppColors.ink;
    final Color badge = selected ? AppColors.accentBlue : AppColors.accentYellow;

    return NeoCard(
      onTap: onTap,
      color: AppColors.surface,
      borderColor: border,
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      child: Row(
        children: <Widget>[
          _LetterBadge(letter: letter, color: badge),
          const SizedBox(width: AppSizes.spaceLg),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelStrong,
            ),
          ),
          const SizedBox(width: AppSizes.spaceMd),
          _RadioMark(selected: selected),
        ],
      ),
    );
  }
}

/// Badge huruf 32×32: radius 8, border 2 px, w900.
class _LetterBadge extends StatelessWidget {
  const _LetterBadge({required this.letter, required this.color});

  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppSizes.radius(AppSizes.radiusChip),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThin),
      ),
      child: Text(
        letter,
        style: AppTextStyles.labelStrong.copyWith(fontSize: 15, height: 1.0),
      ),
    );
  }
}

/// Radio 20 px. Tidak aktif = bg putih + border hairline `radioBorder`.
/// Aktif = border `ink` + titik penuh `ink` di tengah.
class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});

  final bool selected;

  static const double _size = 20;
  static const double _dot = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          // `radioBorder` oleh definisinya hanya untuk radio tidak aktif.
          color: selected ? AppColors.ink : AppColors.radioBorder,
          width: AppSizes.borderHairline,
        ),
      ),
      child: selected
          ? Container(
              width: _dot,
              height: _dot,
              decoration: const BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
