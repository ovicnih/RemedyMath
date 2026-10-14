import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/app_text_styles.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../widgets/common.dart';

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
              decoration: const InputDecoration(hintText: 'Tulis langkah pengerjaanmu di sini...'),
            ),
            const SizedBox(height: AppSizes.spaceMd),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && !_finished) _confirmExit();
      },
      child: Scaffold(
        appBar: remediAppBar(context, widget.title, showBack: true),
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
                time: _left,
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

/// Blok judul: eyebrow topik, judul besar bertitik pink, dan timer.
class _QuizHeading extends StatelessWidget {
  const _QuizHeading({
    required this.title,
    required this.badge,
    required this.time,
  });

  final String title;
  final String badge;
  final Duration time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        EyebrowLabel(label: badge),
        const SizedBox(height: AppSizes.spaceMd),
        Row(
          children: <Widget>[
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(text: title),
                    const TextSpan(
                      text: '.',
                      style: TextStyle(color: AppColors.accentPink),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displayLg,
              ),
            ),
            const SizedBox(width: AppSizes.spaceMd),
            _TimerChip(time: time),
          ],
        ),
      ],
    );
  }
}

/// Chip timer: bg hijau, radius 10, border 3 px, bayangan `Offset(4, 4)`.
/// Berubah pink saat waktu tersisa satu menit atau kurang.
class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.time});

  final Duration time;

  @override
  Widget build(BuildContext context) {
    final bool lowTime = time.inSeconds <= 60;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: lowTime ? AppColors.accentPink : AppColors.accentGreen,
        borderRadius: AppSizes.radius(AppSizes.radiusCard),
        border: Border.all(color: AppColors.ink, width: AppSizes.borderThick),
        boxShadow: AppSizes.shadowCard,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.schedule, size: 18, color: AppColors.ink),
          const SizedBox(width: AppSizes.spaceXs),
          Text(
            Formatters.duration(time),
            style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

/// Kartu progres soal: bg biru, "Soal X dari N", persen, progress bar.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final double ratio = total == 0 ? 0 : (index + 1) / total;
    final TextStyle counter = AppTextStyles.labelStrong.copyWith(fontSize: 16);
    return NeoCard(
      color: AppColors.accentBlue,
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Soal ${index + 1} dari $total', style: counter),
              const Spacer(),
              Text(Formatters.percent(ratio), style: counter),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),
          NeoProgressBar(value: ratio),
        ],
      ),
    );
  }
}

/// Kartu soal: eyebrow kategori, stem, kotak rumus, panel petunjuk.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.showHint,
    required this.onScratch,
  });

  final Question question;
  final bool showHint;
  final VoidCallback onScratch;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: const EdgeInsets.all(AppSizes.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(child: EyebrowLabel(label: question.category)),
              const Spacer(),
              TextButton.icon(
                onPressed: onScratch,
                icon: const Icon(Icons.edit_note, size: 18),
                label: const Text('Coretan'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),
          Text(question.stem, style: AppTextStyles.titleLg),
          if (question.expression.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSizes.spaceLg),
            MathBox(question.expression),
          ],
          if (showHint && question.hint.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSizes.spaceLg),
            HintBox(question.hint),
          ],
        ],
      ),
    );
  }
}

/// Panel aksi bawah: caption, tombol lanjut, ragu-ragu, tombol sebelumnya.
class _FooterPanel extends StatelessWidget {
  const _FooterPanel({
    required this.flagged,
    required this.last,
    required this.index,
    required this.onToggleFlag,
    required this.onNext,
    required this.onPrev,
  });

  final bool flagged;
  final bool last;
  final int index;
  final VoidCallback onToggleFlag;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Jawaban dapat diubah sebelum melanjutkan.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          NeoButton(
            expand: true,
            icon: last ? Icons.check : Icons.arrow_forward,
            label: last ? 'Selesai' : 'Soal berikutnya',
            onPressed: onNext,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          InkWell(
            borderRadius: AppSizes.radius(AppSizes.radiusChip),
            onTap: onToggleFlag,
            child: Row(
              children: <Widget>[
                Checkbox(value: flagged, onChanged: (_) => onToggleFlag()),
                const SizedBox(width: AppSizes.spaceSm),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Ragu-ragu', style: AppTextStyles.titleSm),
                      Text('Tinjau nanti', style: AppTextStyles.labelMd),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (index > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onPrev,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Soal sebelumnya'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Navigator soal: petak 40×40 per nomor. Hijau = ragu-ragu,
/// biru = sudah dijawab, putih = kosong; nomor aktif berbingkai biru.
class _QuestionNavigator extends StatelessWidget {
  const _QuestionNavigator({
    required this.total,
    required this.index,
    required this.answers,
    required this.flags,
    required this.onSelect,
  });

  final int total;
  final int index;
  final List<int?> answers;
  final List<bool> flags;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Wrap(
        spacing: AppSizes.spaceSm,
        runSpacing: AppSizes.spaceSm,
        children: <Widget>[
          for (int i = 0; i < total; i++)
            InkWell(
              borderRadius: AppSizes.radius(AppSizes.radiusCard),
              onTap: () => onSelect(i),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: flags[i]
                      ? AppColors.accentPink
                      : answers[i] != null
                          ? AppColors.accentBlue
                          : AppColors.surface,
                  borderRadius: AppSizes.radius(AppSizes.radiusCard),
                  border: Border.all(
                    color: i == index ? AppColors.accentBlue : AppColors.ink,
                    width: i == index
                        ? AppSizes.borderThin
                        : AppSizes.borderHairline,
                  ),
                ),
                child: Text('${i + 1}', style: AppTextStyles.titleSm),
              ),
            ),
        ],
      ),
    );
  }
}
