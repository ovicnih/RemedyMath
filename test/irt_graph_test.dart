import 'package:flutter_test/flutter_test.dart';
import 'package:remedy_math/models/models.dart';
import 'package:remedy_math/services/irt_service.dart';
import 'package:remedy_math/services/knowledge_graph_service.dart';

ConceptNode _n(String id, int level, List<String> pre) => ConceptNode(
      id: id,
      title: id,
      shortTitle: id,
      level: level,
      prerequisites: pre,
      misconception: '',
      wrongPattern: '',
      correctPattern: '',
      lessonTitle: '',
      summary: '',
      keyPoints: const <KeyPoint>[],
    );

void main() {
  const IrtService irt = IrtService();

  test('skor ekstrem', () {
    expect(irt.estimateTheta(const <ItemResponse>[
      ItemResponse(difficulty: 0, correct: true),
      ItemResponse(difficulty: 1, correct: true),
    ]), 2.0);
    expect(irt.estimateTheta(const <ItemResponse>[
      ItemResponse(difficulty: 0, correct: false),
    ]), -2.0);
  });

  test('theta simetris untuk setengah benar pada b=0', () {
    final double t = irt.estimateTheta(const <ItemResponse>[
      ItemResponse(difficulty: 0, correct: true),
      ItemResponse(difficulty: 0, correct: false),
    ]);
    expect(t.abs() < 0.01, isTrue);
  });

  test('akar masalah = prasyarat lemah terdalam', () {
    final KnowledgeGraphService g = KnowledgeGraphService(<ConceptNode>[
      _n('a', 0, <String>[]),
      _n('b', 1, <String>['a']),
      _n('c', 2, <String>['b']),
    ]);
    expect(g.findRootCause(<String, double>{'a': 1, 'b': 0.3, 'c': 0.2}), 'b');
    expect(g.findRootCause(<String, double>{'a': 1, 'b': 1, 'c': 1}), isNull);
    expect(g.learningPath(<String, double>{'a': 1, 'b': 0.3, 'c': 0.2}), <String>['b', 'c']);
  });
}
