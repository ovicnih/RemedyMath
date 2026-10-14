import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';

/// Kotak petunjuk soal, gaya neobrutalism.
///
/// Bentuk sesuai `UI-REFERENCE.md` §4.2 item 4: bg `#A3F3B6`, radius 10,
/// border 3 px, **tanpa bayangan**, padding 16, ikon 22 px, teks 14 w700.
///
/// Panel ini sengaja tidak berbayang — desain membedakannya dari kartu
/// biasa supaya terlihat sebagai "catatan", bukan elemen mengambang.
class HintBox extends StatelessWidget {
  const HintBox(this.text, {super.key});

  /// Isi petunjuk.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.accentGreen,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.lightbulb_outline, size: 22, color: AppColors.ink),
          const SizedBox(width: AppSizes.spaceMd),
          Expanded(child: Text(text, style: AppTextStyles.labelMd)),
        ],
      ),
    );
  }
}
