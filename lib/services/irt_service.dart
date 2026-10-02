import 'dart:math' as math;

import '../core/app_constants.dart';
import '../models/models.dart';

/// Estimasi kemampuan siswa dengan Model Rasch (IRT 1PL) + Newton-Raphson.
class IrtService {
  const IrtService();

  /// P(benar | θ, b) = 1 / (1 + e^-(θ - b)).
  double probability(double theta, double difficulty) =>
      1 / (1 + math.exp(-(theta - difficulty)));

  /// Maximum Likelihood Estimation θ.
  /// Skor ekstrem: semua benar → +2.0, semua salah → −2.0.
  double estimateTheta(List<ItemResponse> responses) {
    if (responses.isEmpty) return 0;
    final int correct = responses.where((r) => r.correct).length;
    if (correct == responses.length) return AppConstants.extremeHighTheta;
    if (correct == 0) return AppConstants.extremeLowTheta;

    double theta = 0;
    for (int i = 0; i < AppConstants.maxIterations; i++) {
      double gradient = 0;
      double hessian = 0;
      for (final ItemResponse r in responses) {
        final double p = probability(theta, r.difficulty);
        gradient += (r.correct ? 1 : 0) - p;
        hessian -= p * (1 - p);
      }
      if (hessian == 0) break;
      final double step = gradient / hessian;
      theta = (theta - step).clamp(AppConstants.thetaMin, AppConstants.thetaMax);
      if (step.abs() < AppConstants.convergenceThreshold) break;
    }
    return theta;
  }

  /// Standard error estimasi: 1 / sqrt(informasi).
  double standardError(double theta, List<ItemResponse> responses) {
    double info = 0;
    for (final ItemResponse r in responses) {
      final double p = probability(theta, r.difficulty);
      info += p * (1 - p);
    }
    return info == 0 ? double.infinity : 1 / math.sqrt(info);
  }

  /// Posisi relatif kelas (persentil distribusi normal baku).
  double classPercentile(double theta) => 0.5 * (1 + _erf(theta / math.sqrt2));

  String proficiencyLabel(double theta) {
    if (theta < -1.0) return 'Dasar';
    if (theta < 0) return 'Menengah-Dasar';
    if (theta < 1.0) return 'Menengah';
    return 'Mahir';
  }

  String levelLabel(double theta) {
    if (theta < -1.5) return 'Level 0 - Pengenalan';
    if (theta < 0) return 'Level 1 - Fondasi';
    if (theta < 1.0) return 'Level 2 - Berkembang';
    return 'Level 3 - Mahir';
  }

  bool isMastered(double theta) => theta >= AppConstants.masteryTheta;

  // Abramowitz & Stegun 7.1.26.
  double _erf(double x) {
    final double sign = x < 0 ? -1 : 1;
    final double ax = x.abs();
    const double a1 = 0.254829592, a2 = -0.284496736, a3 = 1.421413741;
    const double a4 = -1.453152027, a5 = 1.061405429, p = 0.3275911;
    final double t = 1 / (1 + p * ax);
    final double y =
        1 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-ax * ax);
    return sign * y;
  }
}
