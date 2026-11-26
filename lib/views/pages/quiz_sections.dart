part of 'quiz_page.dart';

class _QuizHeading extends StatelessWidget {
  const _QuizHeading({
    required this.title,
    required this.badge,
    required this.timeListenable,
  });

  final String title;
  final String badge;
  final ValueNotifier<Duration> timeListenable;

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
            ValueListenableBuilder<Duration>(
              valueListenable: timeListenable,
              builder: (_, Duration time, __) => _TimerChip(time: time),
            ),
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

/// Navigator soal: petak 40×40 per nomor. Pink = ragu-ragu,
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
