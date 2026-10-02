import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_constants.dart';
import '../models/models.dart';

/// Penyimpanan lokal di perangkat (offline).
class LocalStorageService {
  static const String _keyHistory = 'remedimath.theta_history';
  SharedPreferences? _prefs;

  Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  SharedPreferences get _p => _prefs!;

  UserProfile? loadProfile() {
    final String? s = _p.getString(AppConstants.keyProfile);
    return s == null ? null : UserProfile.fromJson(jsonDecode(s) as Map<String, dynamic>);
  }

  Future<void> saveProfile(UserProfile p) =>
      _p.setString(AppConstants.keyProfile, jsonEncode(p.toJson()));

  DiagnosticResult? loadLatestResult() {
    final String? s = _p.getString(AppConstants.keyLatestResult);
    if (s == null) return null;
    try {
      return DiagnosticResult.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLatestResult(DiagnosticResult r) =>
      _p.setString(AppConstants.keyLatestResult, jsonEncode(r.toJson()));

  List<RemedialSession> loadSessions() => _list(AppConstants.keySessions)
      .map(RemedialSession.fromJson)
      .toList();

  Future<void> saveSessions(List<RemedialSession> l) => _p.setString(
      AppConstants.keySessions, jsonEncode(l.map((e) => e.toJson()).toList()));

  List<ThetaPoint> loadHistory() => _list(_keyHistory).map(ThetaPoint.fromJson).toList();

  Future<void> saveHistory(List<ThetaPoint> l) =>
      _p.setString(_keyHistory, jsonEncode(l.map((e) => e.toJson()).toList()));

  Set<String> loadWatched() =>
      (_p.getStringList(AppConstants.keyWatchedVideos) ?? <String>[]).toSet();

  Future<void> saveWatched(Set<String> s) =>
      _p.setStringList(AppConstants.keyWatchedVideos, s.toList());

  Future<void> clearAll() async {
    for (final String k in <String>[
      AppConstants.keyProfile,
      AppConstants.keyLatestResult,
      AppConstants.keySessions,
      AppConstants.keyWatchedVideos,
      _keyHistory,
    ]) {
      await _p.remove(k);
    }
  }

  List<Map<String, dynamic>> _list(String key) {
    final String? s = _p.getString(key);
    if (s == null) return <Map<String, dynamic>>[];
    try {
      return (jsonDecode(s) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
}
