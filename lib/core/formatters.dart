import 'package:intl/intl.dart';

/// Utilitas format tampilan.
class Formatters {
  const Formatters._();

  /// θ dengan dua desimal dan tanda eksplisit, contoh: `-0.80`.
  static String theta(double value) => value.toStringAsFixed(2);

  /// Rasio 0..1 menjadi persen bulat, contoh: `46%`.
  static String percent(double ratio) =>
      '${(ratio * 100).round().clamp(0, 100)}%';

  /// Durasi menjadi `mm:ss`.
  static String duration(Duration d) {
    final Duration safe = d.isNegative ? Duration.zero : d;
    final String m = safe.inMinutes.toString().padLeft(2, '0');
    final String s = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Tanggal ringkas berbahasa Indonesia, contoh: `24 Okt 2024`.
  static String shortDate(DateTime date) =>
      DateFormat('d MMM yyyy', 'id').format(date);

  /// Skor 0..100 dari rasio benar.
  static int score(double ratio) => (ratio * 100).round().clamp(0, 100);
}
