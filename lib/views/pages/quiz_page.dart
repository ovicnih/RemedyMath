import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../widgets/common.dart';

/// Halaman kuis (diagnostik maupun post-test). Mengembalikan daftar jawaban.
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
  late Duration _left;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.questions.length, null);
    _flags = List<bool>.filled(widget.questions.length, false);
    _notes = List<String>.filled(widget.questions.length, '');
    _left = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _left -= const Duration(seconds: 1));
      if (_left <= Duration.zero) {
        _timer?.cancel();
        _finish();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    Navigator.of(context).pop<List<int?>>(_answers);
  }

  Future<void> _confirmFinish() async {
    final int unanswered = _answers.where((a) => a == null).length;
    final int flagged = _flags.where((f) => f).length;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Kumpulkan jawaban?'),
        content: Text(
          <String>[
            if (unanswered > 0) '$unanswered soal belum dijawab.',
            if (flagged > 0) '$flagged soal ditandai ragu-ragu.',
            'Jawaban akan dianalisis dengan metode IRT.',
          ].join('\n'),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Periksa lagi')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kumpulkan')),
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Lanjutkan tes')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
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
    final TextEditingController ctrl = TextEditingController(text: _notes[_index]);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Coretan Soal ${_index + 1}', style: AppTextStyles.titleMd),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 8,
              style: AppTextStyles.mathInline,
              decoration: const InputDecoration(hintText: 'Tulis langkah pengerjaanmu di sini...'),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Simpan')),
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
    final bool lowTime = _left.inSeconds <= 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && !_finished) _confirmExit();
      },
      child: Scaffold(
        appBar: remediAppBar(context, widget.title),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: <Widget>[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton.filledTonal(
                          onPressed: _confirmExit,
                          icon: const Icon(Icons.close),
                          tooltip: 'Keluar',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: 'Soal ${_index + 1} ', style: AppTextStyles.titleLg),
                            TextSpan(text: 'dari $total', style: AppTextStyles.bodyLg),
                          ])),
                        ),
                        Pill(
                          icon: Icons.timer_outlined,
                          label: Formatters.duration(_left),
                          background: lowTime ? AppColors.accentPink : AppColors.accentYellow,
                          foreground: lowTime ? AppColors.ink : AppColors.ink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    NeoProgressBar(value: (_index + 1) / total, height: 10),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Flexible(child: Pill(icon: Icons.school_outlined, label: widget.badge)),
                        const SizedBox(width: 8),
                        const Text('Bobot: 1 Poin', style: AppTextStyles.labelMd),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(child: Pill(icon: Icons.psychology_outlined, label: q.category)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _openScratch,
                          icon: const Icon(Icons.edit_note, size: 18),
                          label: const Text('Coretan'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(q.stem, style: AppTextStyles.bodyLg.copyWith(fontSize: 18)),
                    if (q.expression.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 16),
                      MathBox(q.expression),
                    ],
                    if (widget.showHints && q.hint.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Icon(Icons.lightbulb_outline, color: AppColors.accentBlue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Petunjuk Pengingat:',
                                      style: AppTextStyles.bodyMd
                                          .copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
                                  Text(q.hint, style: AppTextStyles.bodyMd),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < q.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnswerOption(
                    letter: String.fromCharCode(65 + i),
                    text: q.options[i],
                    selected: _answers[_index] == i,
                    onTap: () => setState(() => _answers[_index] = i),
                  ),
                ),
              AppCard(
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.verified_outlined, color: AppColors.accentGreen),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Pilihan dapat diubah kembali sebelum waktu habis.',
                          style: AppTextStyles.labelMd),
                    ),
                    Text(q.moduleLabel,
                        style: AppTextStyles.mathInline.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => setState(() => _flags[_index] = !_flags[_index]),
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  value: _flags[_index],
                                  onChanged: (v) => setState(() => _flags[_index] = v ?? false),
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Text('Ragu-ragu', style: AppTextStyles.titleSm),
                                      Text('Tinjau nanti',
                                          style: AppTextStyles.labelMd
                                              .copyWith(color: AppColors.ink)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: NeoButton(
                            expand: true,
                            icon: last ? Icons.check : Icons.arrow_forward,
                            label: last ? 'Selesai' : 'Soal Berikutnya',
                            onPressed: last
                                ? _confirmFinish
                                : () => setState(() => _index++),
                          ),
                        ),
                      ],
                    ),
                    if (_index > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _index--),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Soal sebelumnya'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (int i = 0; i < total; i++)
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _index = i),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _flags[i]
                              ? AppColors.accentPink
                              : _answers[i] != null
                                  ? AppColors.accentBlue
                                  : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: i == _index ? AppColors.accentBlue : AppColors.ink,
                            width: i == _index ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppTextStyles.titleSm.copyWith(
                            color: _answers[i] != null && !_flags[i]
                                ? AppColors.ink
                                : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
