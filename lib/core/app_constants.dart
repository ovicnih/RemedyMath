/// Konstanta global aplikasi RemedyMath.
class AppConstants {
  const AppConstants._();

  static const String appName = 'RemedyMath';

  /// Batas bawah dan atas estimasi kemampuan theta.
  static const double thetaMin = -3.0;
  static const double thetaMax = 3.0;

  /// Batas ketuntasan kemampuan (θ). Lihat DESIGN.md: "Batas Tuntas (θ ≥ 0.0)".
  static const double masteryTheta = 0.0;

  /// Nilai theta untuk skor ekstrem (semua benar / semua salah).
  static const double extremeHighTheta = 2.0;
  static const double extremeLowTheta = -2.0;

  /// Rasio jawaban benar minimal agar sebuah sub-konsep dianggap dikuasai.
  static const double masteryRatio = 0.6;

  /// Parameter iterasi Newton-Raphson.
  static const int maxIterations = 50;
  static const double convergenceThreshold = 0.001;

  /// Kunci penyimpanan lokal.
  static const String keyProfile = 'remedimath.profile';
  static const String keySessions = 'remedimath.sessions';
  static const String keyLatestResult = 'remedimath.latest_result';
  static const String keyWatchedVideos = 'remedimath.watched_videos';
}
