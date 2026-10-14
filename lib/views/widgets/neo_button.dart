import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';

/// Tombol aksi utama gaya neobrutalism.
///
/// Bentuknya sama persis dengan `NeoCard` — radius 10, border 3 px,
/// bayangan `Offset(4, 4)` — supaya tombol dan kartu terlihat sebagai satu
/// keluarga bentuk. Yang berbeda hanya bayangan yang hilang saat tombol
/// ditekan.
///
/// Spesifikasi asal: `UI-REFERENCE.md` §4.1 item 2 (`Mulai diagnostik`),
/// §4.1 item 4 (`Mulai tes`), §4.2 item 6 (`Soal berikutnya`), §4.3 item 6
/// (`Mulai belajar`), dan §4.4 item 4 (`Mulai post-test`).
///
/// ## State nonaktif
///
/// Desain membungkus tombol dengan `Opacity(0.50)`, bukan mengubah
/// warnanya. Widget ini mereproduksi itu persis: isi tombol diredupkan ke
/// 0.50 sementara warna, border, dan bayangan tetap utuh. Bayangan tidak
/// dihapus hanya karena status berubah — bentuk tombol harus stabil.
///
/// ## Efek tombol tertekan
///
/// Bayangan ditahan selama tombol ditekan dan menghilang saat dilepas,
/// sehingga tombol terasa "tenggelam" mengikuti jarum. Animasi memakai
/// `AnimatedContainer` — animasi implisit bawaan Flutter, tanpa paket
/// tambahan dan tanpa `AnimationController` manual.
class NeoButton extends StatefulWidget {
  const NeoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.accentYellow,
    this.icon,
    this.iconSize = 16,
    this.expand = false,
    this.textStyle,
  });

  /// Teks tombol. Dipakai juga sebagai label aksesibilitas.
  final String label;

  /// Aksi saat ditekan. `null` berarti tombol nonaktif.
  final VoidCallback? onPressed;

  /// Warna isi. Default kuning — CTA utama di semua halaman.
  final Color color;

  /// Ikon opsional di sebelah teks. Panah CTA = `Icons.arrow_forward`.
  final IconData? icon;

  /// Ukuran ikon. Desain memakai 16 px untuk panah CTA.
  final double iconSize;

  /// Jika `true`, tombol memakai lebar penuh kontainer.
  final bool expand;

  /// Gaya teks. Default [AppTextStyles.labelStrong] (15 w900).
  final TextStyle? textStyle;

  /// `true` kalau [onPressed] tidak null.
  bool get isEnabled => onPressed != null;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.isEnabled;

    // Bayangan hilang hanya saat tombol ditekan. Pada state nonaktif
    // bayangan tetap ada supaya bentuk tombol tidak berubah diam-diam.
    final List<BoxShadow> shadow =
        _pressed ? const <BoxShadow>[] : AppSizes.shadowCard;

    final Widget label = Text(
      widget.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: widget.textStyle ?? AppTextStyles.labelStrong,
    );

    final Widget row = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[
          Icon(widget.icon, size: widget.iconSize, color: AppColors.ink),
          const SizedBox(width: AppSizes.spaceSm),
        ],
        // `Flexible` hanya aman pada Row dengan lebar terikat. Pada
        // `MainAxisSize.min` (tombol ikut isi) label dibiarkan apa adanya,
        // karena `Flexible` di sana bisa melempar overflow.
        if (widget.expand) Flexible(child: label) else label,
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          width: widget.expand ? double.infinity : null,
          // Tanpa ini tinggi tombol hanya hasil isinya, bisa di bawah 48 px.
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceXl,
            vertical: AppSizes.spaceMd,
          ),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: AppSizes.radius(AppSizes.radiusCard),
            border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
            boxShadow: shadow,
          ),
          child: Opacity(opacity: enabled ? 1 : 0.50, child: row),
        ),
      ),
    );
  }
}
