import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../widgets/common.dart';

part 'quiz_sections.dart';

/// Halaman kuis (diagnostik maupun post-test). Mengembalikan daftar jawaban.
///
/// Susunan visual mengikuti `UI-REFERENCE.md` §4.2: blok judul + timer,
/// kartu progres biru, kartu soal putih, panel petunjuk hijau, empat opsi
/// jawaban, lalu baris aksi bawah. Fitur yang tidak muncul di mockup
/// (coretan, ragu-ragu, navigator soal) tetap dipertahankan — lihat §7.
class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    required this.title,
    required this.badge,
    required this.questions,
    required this.duration,
    this.showHints = true,
  });

  final String title;
  final String badge;
  final List<Question> questions;
  final Duration duration;
  final bool showHints;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<int?> _answers;
  late List<bool> _flags;
  late List<String> _notes;
  int _index = 0;
  late final ValueNotifier<Duration> _left;
  Timer? _timer;
  bool _finished = false;

  int get _unansweredCount => _answers.where((a) => a == null).length;

  int _firstUnansweredIndex() {
    for (var i = 0; i < _answers.length; i++) {
      if (_answers[i] == null) return i;
    }
    return _answers.length - 1;
  }

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.questions.length, null);
    _flags = List<bool>.filled(widget.questions.length, false);
    _notes = List<String>.filled(widget.questions.length, '');
    _left = ValueNotifier<Duration>(widget.duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final Duration next = _left.value - const Duration(seconds: 1);
      _left.value = next < Duration.zero ? Duration.zero : next;
      if (_left.value <= Duration.zero) {
        _timer?.cancel();
        if (_unansweredCount > 0) {
          if (mounted) {
            showDialog<void>(
              context: context,
              builder: (BuildContext ctx) => AlertDialog(
                title: const Text("Waktu habis"),
                content: Text(
                    "Masih $_unansweredCount soal belum dijawab. Lengkapi sebelum mengumpulkan."),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Lanjut")),
                ],
              ),
            );
          }
          return;
        }
        _finish();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _left.dispose();
    super.dispose();
  }

  void _finish() {
    if (_finished) return;
    if (_unansweredCount > 0) {
      return;
    }
    _finished = true;
    _timer?.cancel();
    Navigator.of(context).pop<List<int?>>(_answers);
  }

  Future<void> _confirmFinish() async {
    final int unanswered = _unansweredCount;
    final int flagged = _flags.where((f) => f).length;
    if (unanswered > 0) {
      // Audit §1: pesan eksplisit + arahkan ke soal pertama yang kosong.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Masih ada $unanswered soal yang belum dijawab. Lengkapi '
            'semua jawaban sebelum mengumpulkan tes.',
          ),
        ),
      );
      setState(() => _index = _firstUnansweredIndex());
      return;
    }
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Kumpulkan jawaban?'),
        content: Text(
          <String>[
            if (flagged > 0) '$flagged soal ditandai ragu-ragu.',
            'Jawaban akan dianalisis dengan metode IRT.',
          ].join('\n'),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Periksa lagi')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Kumpulkan')),
        ],
      ),
    );
    if (ok == true) _finish();
  }

  Future<void> _confirmExit() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Keluar dari tes?'),
        content: const Text('Progres jawaban pada sesi ini akan hilang.'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Lanjutkan tes')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (ok == true && mounted) {
      _finished = true;
      _timer?.cancel();
      Navigator.of(context).pop<List<int?>>();
    }
  }

  Future<void> _openScratch() async {
    final TextEditingController ctrl =
        TextEditingController(text: _notes[_index]);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.spaceXl,
          0,
          AppSizes.spaceXl,
          MediaQuery.of(ctx).viewInsets.bottom + AppSizes.spaceXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Coretan Soal ${_index + 1}', style: AppTextStyles.titleMd),
            const SizedBox(height: AppSizes.spaceMd),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 8,
              style: AppTextStyles.mathInline,
              decoration: const InputDecoration(
                  hintText: 'Tulis langkah pengerjaanmu di sini...'),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Simpan')),
          ],
        ),
      ),
    );
    _notes[_index] = ctrl.text;
    ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Question q = widget.questions[_index];
    final int total = widget.questions.length;
    final bool last = _index == total - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && !_finished) _confirmExit();
      },
      child: Scaffold(
        appBar: remediAppBar(context, widget.title,
            showBack: true, profileLocked: true),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceLg,
              AppSizes.spaceLg,
              AppSizes.spaceLg,
              AppSizes.spaceXl,
            ),
            children: <Widget>[
              _QuizHeading(
                title: widget.title,
                badge: widget.badge,
                timeListenable: _left,
              ),
              const SizedBox(height: AppSizes.spaceLg),
              _ProgressCard(index: _index, total: total),
              const SizedBox(height: AppSizes.spaceLg),
              _QuestionCard(
                question: q,
                showHint: widget.showHints,
                onScratch: _openScratch,
              ),
              const SizedBox(height: AppSizes.spaceLg),
              for (int i = 0; i < q.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spaceMd),
                  child: AnswerOption(
                    letter: String.fromCharCode(65 + i),
                    text: q.options[i],
                    selected: _answers[_index] == i,
                    onTap: () => setState(() => _answers[_index] = i),
                  ),
                ),
              const SizedBox(height: AppSizes.spaceXs),
              _FooterPanel(
                flagged: _flags[_index],
                last: last,
                index: _index,
                onToggleFlag: () =>
                    setState(() => _flags[_index] = !_flags[_index]),
                onNext: last ? _confirmFinish : () => setState(() => _index++),
                onPrev: () => setState(() => _index--),
              ),
              const SizedBox(height: AppSizes.spaceLg),
              _QuestionNavigator(
                total: total,
                index: _index,
                answers: _answers,
                flags: _flags,
                onSelect: (int i) => setState(() => _index = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
