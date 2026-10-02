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
  final IrtService irt = const IrtService();
  final LocalStorageService _storage = LocalStorageService();
  late ContentRepository content;
  late KnowledgeGraphService graph;

  UserProfile? profile;
  DiagnosticResult? latestResult;
  List<RemedialSession> sessions = <RemedialSession>[];
  List<ThetaPoint> history = <ThetaPoint>[];
  Set<String> watchedVideos = <String>{};
  int tabIndex = 0;

  Future<void> init() async {
    content = await ContentRepository.load();
    graph = KnowledgeGraphService(content.nodes);
    await _storage.init();
    profile = _storage.loadProfile();
    latestResult = _storage.loadLatestResult();
    sessions = _storage.loadSessions();
    history = _storage.loadHistory();
    watchedVideos = _storage.loadWatched();
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

  bool isWatched(String nodeId) => watchedVideos.contains(nodeId);

  Future<void> markWatched(String nodeId) async {
    watchedVideos.add(nodeId);
    await _storage.saveWatched(watchedVideos);
    notifyListeners();
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
    watchedVideos = <String>{};
    tabIndex = 0;
    notifyListeners();
  }
}
