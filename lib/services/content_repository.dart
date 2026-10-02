import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/models.dart';

/// Memuat bank soal dan knowledge graph dari aset JSON (offline).
class ContentRepository {
  ContentRepository({
    required this.diagnosticTitle,
    required this.topic,
    required this.durationMinutes,
    required this.diagnosticQuestions,
    required this.postTests,
    required this.chapter,
    required this.nodes,
  });

  final String diagnosticTitle;
  final String topic;
  final int durationMinutes;
  final List<Question> diagnosticQuestions;
  final Map<String, List<Question>> postTests;
  final String chapter;
  final List<ConceptNode> nodes;

  late final Map<String, Question> allQuestions = <String, Question>{
    for (final Question q in diagnosticQuestions) q.id: q,
    for (final List<Question> l in postTests.values)
      for (final Question q in l) q.id: q,
  };

  static Future<ContentRepository> load() async {
    final Map<String, dynamic> q = jsonDecode(
      await rootBundle.loadString('assets/data/questions.json'),
    ) as Map<String, dynamic>;
    final Map<String, dynamic> kg = jsonDecode(
      await rootBundle.loadString('assets/data/knowledge_graph.json'),
    ) as Map<String, dynamic>;
    return fromMaps(q, kg);
  }

  static ContentRepository fromMaps(Map<String, dynamic> q, Map<String, dynamic> kg) {
    final Map<String, dynamic> d = q['diagnostic'] as Map<String, dynamic>;
    final Map<String, dynamic> pt =
        (q['postTests'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    return ContentRepository(
      diagnosticTitle: (d['title'] ?? 'Tes Diagnostik') as String,
      topic: (d['topic'] ?? '') as String,
      durationMinutes: ((d['durationMinutes'] ?? 15) as num).toInt(),
      diagnosticQuestions: (d['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      postTests: pt.map((k, v) => MapEntry<String, List<Question>>(
            k,
            (v as List<dynamic>)
                .map((e) => Question.fromJson(e as Map<String, dynamic>))
                .toList(),
          )),
      chapter: (kg['chapter'] ?? '') as String,
      nodes: (kg['nodes'] as List<dynamic>)
          .map((e) => ConceptNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
