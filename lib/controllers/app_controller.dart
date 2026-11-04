import 'package:flutter/foundation.dart';

import '../core/app_constants.dart';
import '../core/formatters.dart';
import '../models/models.dart';
import '../services/content_repository.dart';
import '../services/irt_service.dart';
import '../services/knowledge_graph_service.dart';
import '../services/local_storage_service.dart';

/// State global aplikasi.
class AppController extends ChangeNotifier {
  AppController({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final IrtService irt = const IrtService();
  final LocalStorageService _storage;
  late ContentRepository content;
  late KnowledgeGraphService graph;

  UserProfile? profile;
  DiagnosticResult? latestResult;
  List<RemedialSession> sessions = <RemedialSession>[];
  List<ThetaPoint> history = <ThetaPoint>[];
  Set<String> studiedNodes = <String>{};
  int tabIndex = 0;

  Future<void> init() async {
    content = await ContentRepository.load();
    graph = KnowledgeGraphService(content.nodes);
    await _storage.init();
    profile = _storage.loadProfile();
    latestResult = _storage.loadLatestResult();
    sessions = _storage.loadSessions();
    history = _storage.loadHistory();
    studiedNodes = _storage.loadStudied();
  }

  void setTab(int i) {
    tabIndex = i;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile p) async {
    profile = p;
    await _storage.saveProfile(p);
    notifyListeners();
  }

  // ---- Statistik ringkas ----
  int get masteredCount => latestResult == null
      ? 0
      : latestResult!.nodeMastery.values
          .where((v) => v >= AppConstants.masteryRatio)
          .length;

  int get remedialCount => latestResult?.learningPath.length ?? 0;

  double get averageAccuracy {
    final List<double> all = <double>[
      if (latestResult != null) latestResult!.accuracy,
      ...sessions.map((s) => s.score / 100),
    ];
    if (all.isEmpty) return 0;
    return all.reduce((a, b) => a + b) / all.length;
  }

  ConceptNode? get rootCause => graph.node(latestResult?.rootCauseId);

  bool isStudied(String nodeId) => studiedNodes.contains(nodeId);

  Future<void> markStudied(String nodeId) async {
    studiedNodes.add(nodeId);
    await _storage.saveStudied(studiedNodes);
    notifyListeners();
  }

  /// ---- Status rute berurutan (audit §6) ----
  ///
  /// Setiap node punya state: terkunci · belum dimulai · video selesai
  /// (menunggu post-test) · tuntas. `studied` = video selesai, `passed` =
  /// post-test terakhir lulus (ambang [AppConstants.masteryRatio] = 60%).

  /// Sesi post-test TERAKHIR untuk node (daftar [sessions] newest-first).
  RemedialSession? sessionFor(String nodeId) {
    for (final RemedialSession s in sessions) {
      if (s.nodeId == nodeId) return s;
    }
    return null;
  }

  /// Post-test terakhir node lulus. Tanpa sesi berarti belum lulus.
  bool isPassed(String nodeId) => sessionFor(nodeId)?.passed ?? false;

  /// Materi tuntas hanya jika video selesai dan post-test lulus
  /// (audit §6: video selesai saja tidak otomatis tuntas).
  bool isFinished(String nodeId) => isStudied(nodeId) && isPassed(nodeId);

  /// Apakah materi boleh dibuka menurut urutan rute (audit §6).
  ///
  /// Node pada rute: terbuka hanya jika semua langkah sebelumnya tuntas.
  /// Node di luar rute (peta materi): terbuka saat sudah pernah dipelajari
  /// atau seluruh prasyaratnya tuntas, agar penguncian tetap berlaku.
  bool isRouteUnlocked(String nodeId) {
    final List<String> path = latestResult?.learningPath ?? const <String>[];
    final int idx = path.indexOf(nodeId);
    if (idx < 0) {
      final ConceptNode? n = graph.node(nodeId);
      return isStudied(nodeId) ||
          (n?.prerequisites ?? const <String>[]).every(isFinished);
    }
    for (int i = 0; i < idx; i++) {
      if (!isFinished(path[i])) return false;
    }
    return true;
  }

  /// Judul materi penghalang untuk pesan penguncian.
  String routeBlockerTitle(String nodeId) {
    final List<String> path = latestResult?.learningPath ?? const <String>[];
    final int idx = path.indexOf(nodeId);
    if (idx >= 0) {
      for (int i = 0; i < idx; i++) {
        if (!isFinished(path[i])) {
          return graph.node(path[i])?.shortTitle ?? path[i];
        }
      }
      return '';
    }
    final ConceptNode? n = graph.node(nodeId);
    for (final String p in n?.prerequisites ?? const <String>[]) {
      if (!isFinished(p)) return graph.node(p)?.shortTitle ?? p;
    }
    return '';
  }

  List<ItemResponse> _responses(List<String> ids, List<int?> answers) {
    final List<ItemResponse> out = <ItemResponse>[];
    for (int i = 0; i < ids.length; i++) {
      final Question? q = content.allQuestions[ids[i]];
      if (q == null) continue;
      out.add(ItemResponse(
        difficulty: q.difficulty,
        correct: q.isCorrect(i < answers.length ? answers[i] : null),
      ));
    }
    return out;
  }

  /// Proses tes diagnostik: estimasi θ + penelusuran akar masalah.
  Future<DiagnosticResult> submitDiagnostic(List<int?> answers) async {
    final List<Question> qs = content.diagnosticQuestions;
    final List<String> ids = qs.map((q) => q.id).toList();
    final double theta = irt.estimateTheta(_responses(ids, answers));
    final Map<String, double> mastery = graph.masteryByNode(qs, answers);
    int correct = 0;
    for (int i = 0; i < qs.length; i++) {
      if (qs[i].isCorrect(i < answers.length ? answers[i] : null)) correct++;
    }
    final DiagnosticResult r = DiagnosticResult(
      theta: theta,
      diagnosticCorrect: correct,
      diagnosticTotal: qs.length,
      questionIds: ids,
      answers: List<int?>.from(answers),
      nodeMastery: mastery,
      rootCauseId: graph.findRootCause(mastery),
      learningPath: graph.learningPath(mastery),
      date: DateTime.now(),
    );
    latestResult = r;
    history.add(ThetaPoint(theta: theta, date: r.date, label: 'Diagnostik'));
    await _storage.saveLatestResult(r);
    await _storage.saveHistory(history);
    notifyListeners();
    return r;
  }

  /// Proses post-test sebuah materi dan perbarui θ.
  Future<RemedialSession> submitPostTest(String nodeId, List<int?> answers) async {
    final List<Question> qs = content.postTests[nodeId] ?? <Question>[];
    int correct = 0;
    for (int i = 0; i < qs.length; i++) {
      if (qs[i].isCorrect(i < answers.length ? answers[i] : null)) correct++;
    }
    final double ratio = qs.isEmpty ? 0 : correct / qs.length;
    final bool passed = ratio >= AppConstants.masteryRatio;
    final ConceptNode? node = graph.node(nodeId);

    if (latestResult != null) {
      final DiagnosticResult prev = latestResult!;
      final Set<String> ptIds = qs.map((q) => q.id).toSet();
      final List<String> ids = <String>[];
      final List<int?> ans = <int?>[];
      for (int i = 0; i < prev.questionIds.length; i++) {
        if (ptIds.contains(prev.questionIds[i])) continue;
        ids.add(prev.questionIds[i]);
        ans.add(i < prev.answers.length ? prev.answers[i] : null);
      }
      for (int i = 0; i < qs.length; i++) {
        ids.add(qs[i].id);
        ans.add(i < answers.length ? answers[i] : null);
      }
      final Map<String, double> mastery = Map<String, double>.from(prev.nodeMastery)
        ..[nodeId] = ratio;
      final double theta = irt.estimateTheta(_responses(ids, ans));
      final String? root = graph.findRootCause(mastery);
      latestResult = prev.copyWith(
        theta: theta,
        questionIds: ids,
        answers: ans,
        nodeMastery: mastery,
        rootCauseId: root,
        clearRootCause: root == null,
        learningPath: graph.learningPath(mastery),
      );
      history.add(ThetaPoint(
        theta: theta,
        date: DateTime.now(),
        label: 'Post-test ${node?.shortTitle ?? ''}',
      ));
      await _storage.saveLatestResult(latestResult!);
      await _storage.saveHistory(history);
    }

    final RemedialSession s = RemedialSession(
      nodeId: nodeId,
      title: node?.title ?? nodeId,
      label: 'Post-test Remedial',
      score: Formatters.score(ratio),
      passed: passed,
      date: DateTime.now(),
    );
    sessions.insert(0, s);
    await _storage.saveSessions(sessions);
    notifyListeners();
    return s;
  }

  Future<void> resetAll() async {
    await _storage.clearAll();
    profile = null;
    latestResult = null;
    sessions = <RemedialSession>[];
    history = <ThetaPoint>[];
    studiedNodes = <String>{};
    tabIndex = 0;
    notifyListeners();
  }
}
