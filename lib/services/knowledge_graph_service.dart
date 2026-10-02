import '../core/app_constants.dart';
import '../models/models.dart';

/// Knowledge Graph prasyarat materi dan penelusuran mundur akar masalah.
class KnowledgeGraphService {
  KnowledgeGraphService(List<ConceptNode> list)
      : nodes = <String, ConceptNode>{for (final ConceptNode n in list) n.id: n};

  final Map<String, ConceptNode> nodes;

  ConceptNode? node(String? id) => id == null ? null : nodes[id];

  List<ConceptNode> get ordered {
    final List<ConceptNode> l = nodes.values.toList()
      ..sort((a, b) => a.level.compareTo(b.level));
    return l;
  }

  /// Rasio benar per simpul materi.
  Map<String, double> masteryByNode(List<Question> questions, List<int?> answers) {
    final Map<String, int> total = <String, int>{};
    final Map<String, int> correct = <String, int>{};
    for (int i = 0; i < questions.length; i++) {
      final Question q = questions[i];
      final int? a = i < answers.length ? answers[i] : null;
      total[q.nodeId] = (total[q.nodeId] ?? 0) + 1;
      if (q.isCorrect(a)) correct[q.nodeId] = (correct[q.nodeId] ?? 0) + 1;
    }
    return total.map((k, v) => MapEntry<String, double>(k, (correct[k] ?? 0) / v));
  }

  Set<String> weakNodes(Map<String, double> mastery) => mastery.entries
      .where((e) => e.value < AppConstants.masteryRatio)
      .map((e) => e.key)
      .toSet();

  /// Semua prasyarat (langsung & tidak langsung) dari sebuah simpul.
  Set<String> ancestors(String id) {
    final Set<String> seen = <String>{};
    final List<String> stack = <String>[...?nodes[id]?.prerequisites];
    while (stack.isNotEmpty) {
      final String cur = stack.removeLast();
      if (seen.add(cur)) stack.addAll(nodes[cur]?.prerequisites ?? <String>[]);
    }
    return seen;
  }

  Set<String> descendants(String id) =>
      nodes.keys.where((k) => ancestors(k).contains(id)).toSet();

  /// Backward traversal: dari setiap simpul lemah, telusuri prasyarat hingga
  /// simpul lemah terdalam yang seluruh prasyaratnya sudah dikuasai.
  String? findRootCause(Map<String, double> mastery) {
    final Set<String> weak = weakNodes(mastery);
    if (weak.isEmpty) return null;
    final Set<String> roots = <String>{};
    for (final String w in weak) {
      roots.addAll(_traceBack(w, weak, <String>{}));
    }
    final List<String> list = roots.toList()
      ..sort((a, b) {
        final int impact = descendants(b)
            .where(weak.contains)
            .length
            .compareTo(descendants(a).where(weak.contains).length);
        if (impact != 0) return impact;
        final int m = (mastery[a] ?? 1).compareTo(mastery[b] ?? 1);
        if (m != 0) return m;
        return (nodes[a]?.level ?? 0).compareTo(nodes[b]?.level ?? 0);
      });
    return list.first;
  }

  Set<String> _traceBack(String id, Set<String> weak, Set<String> visiting) {
    if (!visiting.add(id)) return <String>{};
    final List<String> weakPrereqs =
        (nodes[id]?.prerequisites ?? <String>[]).where(weak.contains).toList();
    if (weakPrereqs.isEmpty) return <String>{id};
    final Set<String> out = <String>{};
    for (final String p in weakPrereqs) {
      out.addAll(_traceBack(p, weak, visiting));
    }
    return out;
  }

  /// Rute belajar: simpul lemah diurutkan topologis (level), akar masalah dulu.
  List<String> learningPath(Map<String, double> mastery) {
    final String? root = findRootCause(mastery);
    final List<String> weak = weakNodes(mastery).toList()
      ..sort((a, b) {
        if (a == root) return -1;
        if (b == root) return 1;
        final int l = (nodes[a]?.level ?? 0).compareTo(nodes[b]?.level ?? 0);
        if (l != 0) return l;
        return (mastery[a] ?? 1).compareTo(mastery[b] ?? 1);
      });
    return weak;
  }

  /// Rantai prasyarat untuk breadcrumb, dari fondasi ke simpul.
  List<ConceptNode> chainTo(String id) {
    final List<ConceptNode> list = ancestors(id)
        .map((e) => nodes[e])
        .whereType<ConceptNode>()
        .toList()
      ..sort((a, b) => a.level.compareTo(b.level));
    final ConceptNode? self = nodes[id];
    if (self != null) list.add(self);
    return list;
  }
}
