/// Model data RemedyMath.
library;

class Question {
  const Question({
    required this.id,
    required this.nodeId,
    required this.category,
    required this.moduleLabel,
    required this.stem,
    required this.expression,
    required this.hint,
    required this.options,
    required this.answerIndex,
    required this.difficulty,
  });

  final String id;
  final String nodeId;
  final String category;
  final String moduleLabel;
  final String stem;
  final String expression;
  final String hint;
  final List<String> options;
  final int answerIndex;

  /// Parameter kesulitan b (Model Rasch 1PL).
  final double difficulty;

  bool isCorrect(int? selected) => selected == answerIndex;

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: j['id'] as String,
        nodeId: j['nodeId'] as String,
        category: (j['category'] ?? '') as String,
        moduleLabel: (j['moduleLabel'] ?? '') as String,
        stem: (j['stem'] ?? '') as String,
        expression: (j['expression'] ?? '') as String,
        hint: (j['hint'] ?? '') as String,
        options: (j['options'] as List<dynamic>).map((e) => e.toString()).toList(),
        answerIndex: (j['answerIndex'] as num).toInt(),
        difficulty: (j['difficulty'] as num).toDouble(),
      );
}

class KeyPoint {
  const KeyPoint({required this.title, required this.detail});
  final String title;
  final String detail;

  factory KeyPoint.fromJson(Map<String, dynamic> j) => KeyPoint(
        title: (j['title'] ?? '') as String,
        detail: (j['detail'] ?? '') as String,
      );
}

class ConceptNode {
  const ConceptNode({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.level,
    required this.prerequisites,
    required this.misconception,
    required this.wrongPattern,
    required this.correctPattern,
    required this.videoUrl,
    required this.videoTitle,
    required this.videoDurationLabel,
    required this.videoDurationMinutes,
    required this.instructor,
    required this.instructorRole,
    required this.summary,
    required this.keyPoints,
  });

  final String id;
  final String title;
  final String shortTitle;
  final int level;
  final List<String> prerequisites;
  final String misconception;
  final String wrongPattern;
  final String correctPattern;
  final String videoUrl;
  final String videoTitle;
  final String videoDurationLabel;
  final int videoDurationMinutes;
  final String instructor;
  final String instructorRole;
  final String summary;
  final List<KeyPoint> keyPoints;

  factory ConceptNode.fromJson(Map<String, dynamic> j) => ConceptNode(
        id: j['id'] as String,
        title: (j['title'] ?? '') as String,
        shortTitle: (j['shortTitle'] ?? j['title'] ?? '') as String,
        level: ((j['level'] ?? 0) as num).toInt(),
        prerequisites: ((j['prerequisites'] ?? <dynamic>[]) as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
        misconception: (j['misconception'] ?? '') as String,
        wrongPattern: (j['wrongPattern'] ?? '') as String,
        correctPattern: (j['correctPattern'] ?? '') as String,
        videoUrl: (j['videoUrl'] ?? '') as String,
        videoTitle: (j['videoTitle'] ?? '') as String,
        videoDurationLabel: (j['videoDurationLabel'] ?? '') as String,
        videoDurationMinutes: ((j['videoDurationMinutes'] ?? 0) as num).toInt(),
        instructor: (j['instructor'] ?? '') as String,
        instructorRole: (j['instructorRole'] ?? '') as String,
        summary: (j['summary'] ?? '') as String,
        keyPoints: ((j['keyPoints'] ?? <dynamic>[]) as List<dynamic>)
            .map((e) => KeyPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.className,
    required this.school,
  });

  final String name;
  final String className;
  final String school;

  String get initials {
    final List<String> parts =
        name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String get firstName {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'name': name, 'className': className, 'school': school};

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: (j['name'] ?? '') as String,
        className: (j['className'] ?? 'SMA Kelas 10') as String,
        school: (j['school'] ?? '') as String,
      );
}

/// Satu respons butir untuk estimasi IRT.
class ItemResponse {
  const ItemResponse({required this.difficulty, required this.correct});
  final double difficulty;
  final bool correct;
}

class DiagnosticResult {
  const DiagnosticResult({
    required this.theta,
    required this.diagnosticCorrect,
    required this.diagnosticTotal,
    required this.questionIds,
    required this.answers,
    required this.nodeMastery,
    required this.rootCauseId,
    required this.learningPath,
    required this.date,
  });

  final double theta;
  final int diagnosticCorrect;
  final int diagnosticTotal;

  /// Semua butir yang dipakai estimasi (diagnostik + post-test).
  final List<String> questionIds;
  final List<int?> answers;
  final Map<String, double> nodeMastery;
  final String? rootCauseId;
  final List<String> learningPath;
  final DateTime date;

  double get accuracy =>
      diagnosticTotal == 0 ? 0 : diagnosticCorrect / diagnosticTotal;

  DiagnosticResult copyWith({
    double? theta,
    List<String>? questionIds,
    List<int?>? answers,
    Map<String, double>? nodeMastery,
    String? rootCauseId,
    bool clearRootCause = false,
    List<String>? learningPath,
    DateTime? date,
  }) =>
      DiagnosticResult(
        theta: theta ?? this.theta,
        diagnosticCorrect: diagnosticCorrect,
        diagnosticTotal: diagnosticTotal,
        questionIds: questionIds ?? this.questionIds,
        answers: answers ?? this.answers,
        nodeMastery: nodeMastery ?? this.nodeMastery,
        rootCauseId: clearRootCause ? null : (rootCauseId ?? this.rootCauseId),
        learningPath: learningPath ?? this.learningPath,
        date: date ?? this.date,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'theta': theta,
        'diagnosticCorrect': diagnosticCorrect,
        'diagnosticTotal': diagnosticTotal,
        'questionIds': questionIds,
        'answers': answers.map((a) => a ?? -1).toList(),
        'nodeMastery': nodeMastery,
        'rootCauseId': rootCauseId,
        'learningPath': learningPath,
        'date': date.toIso8601String(),
      };

  factory DiagnosticResult.fromJson(Map<String, dynamic> j) => DiagnosticResult(
        theta: (j['theta'] as num).toDouble(),
        diagnosticCorrect: (j['diagnosticCorrect'] as num).toInt(),
        diagnosticTotal: (j['diagnosticTotal'] as num).toInt(),
        questionIds: (j['questionIds'] as List<dynamic>).map((e) => e.toString()).toList(),
        answers: (j['answers'] as List<dynamic>).map((e) {
          final int v = (e as num).toInt();
          return v < 0 ? null : v;
        }).toList(),
        nodeMastery: (j['nodeMastery'] as Map<String, dynamic>)
            .map((k, v) => MapEntry<String, double>(k, (v as num).toDouble())),
        rootCauseId: j['rootCauseId'] as String?,
        learningPath: (j['learningPath'] as List<dynamic>).map((e) => e.toString()).toList(),
        date: DateTime.parse(j['date'] as String),
      );
}

class RemedialSession {
  const RemedialSession({
    required this.nodeId,
    required this.title,
    required this.label,
    required this.score,
    required this.passed,
    required this.date,
  });

  final String nodeId;
  final String title;
  final String label;
  final int score;
  final bool passed;
  final DateTime date;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'nodeId': nodeId,
        'title': title,
        'label': label,
        'score': score,
        'passed': passed,
        'date': date.toIso8601String(),
      };

  factory RemedialSession.fromJson(Map<String, dynamic> j) => RemedialSession(
        nodeId: j['nodeId'] as String,
        title: (j['title'] ?? '') as String,
        label: (j['label'] ?? '') as String,
        score: (j['score'] as num).toInt(),
        passed: j['passed'] as bool,
        date: DateTime.parse(j['date'] as String),
      );
}

class ThetaPoint {
  const ThetaPoint({required this.theta, required this.date, required this.label});
  final double theta;
  final DateTime date;
  final String label;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'theta': theta,
        'date': date.toIso8601String(),
        'label': label,
      };

  factory ThetaPoint.fromJson(Map<String, dynamic> j) => ThetaPoint(
        theta: (j['theta'] as num).toDouble(),
        date: DateTime.parse(j['date'] as String),
        label: (j['label'] ?? '') as String,
      );
}
