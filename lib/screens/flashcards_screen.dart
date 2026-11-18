import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/vocabulary.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/animated_flip.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({
    super.key,
    required this.bookId,
    required this.unitId,
  });
  final int bookId;
  final int unitId;
  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<Word>? _deck;
  int _index = 0;
  bool _flipped = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    // Snapshot only once. Newly learned cards remain navigable this session.
    _deck ??= state.vocabulary
        .unit(widget.bookId, widget.unitId)
        .words
        .where((word) => !state.isLearned(word))
        .toList(growable: false);
  }

  void _move(int delta) => setState(() {
    _index += delta;
    _flipped = false;
  });
  void _flip() => setState(() => _flipped = !_flipped);

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = AppColors.of(context);
    final words = _deck!;
    if (words.isEmpty) {
      return AppPage(
        title: 'Unit ${widget.unitId}',
        child: EmptyState(
          title: 'All Words Learned!',
          description: 'There are no words to revise in this unit. All words have been marked as learned!',
          icon: LucideIcons.circleCheck,
          iconColor: colors.success,
          actions: [
            ActionButton(
              'Review All Words',
              radius: 12,
              weight: FontWeight.w700,
              onPressed: () => Navigator.pushNamed(
                context,
                '/learn/${widget.bookId}/${widget.unitId}',
              ),
            ),
            ActionButton(
              'Back to Unit',
              radius: 12,
              background: colors.low,
              color: colors.text,
              border: colors.cardBorder,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
    final word = words[_index];
    final learned = state.isLearned(word);
    return AppPage(
      title: 'Unit ${widget.unitId}',
      child: ContentList(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              label(
                context,
                'Progress',
                size: 13,
                weight: FontWeight.w500,
                color: colors.muted,
              ),
              label(
                context,
                '${_index + 1} OF ${words.length}',
                size: 12,
                weight: FontWeight.w700,
                color: colors.primary,
                spacing: .8,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressTrack(((_index + 1) / words.length * 100).round(), height: 5),
          const SizedBox(height: 20),
          AnimatedFlip(
            key: ValueKey(word.uniqueId),
            flipped: _flipped,
            front: _buildCard(context, word, learned, false),
            back: _buildCard(context, word, learned, true),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  'Previous',
                  leadingIcon: LucideIcons.chevronLeft,
                  background: colors.low,
                  color: colors.text,
                  border: colors.cardBorder,
                  onPressed: _index == 0 ? null : () => _move(-1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  'Next',
                  icon: LucideIcons.chevronRight,
                  background: colors.high,
                  color: colors.text,
                  border: colors.cardBorder,
                  onPressed: _index == words.length - 1 ? null : () => _move(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Word word,
    bool learned,
    bool flipped,
  ) {
    final state = AppScope.of(context);
    final colors = AppColors.of(context);
    return SurfaceCard(
      radius: 16,
      padding: const EdgeInsets.all(20),
      onTap: _flip,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 338),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (word.partOfSpeech.isNotEmpty)
                        PartOfSpeech(
                          word.partOfSpeech,
                          weight: FontWeight.w700,
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: (learned ? colors.success : colors.error)
                              .withValues(alpha: colors.dark ? .15 : .1),
                          border: Border.all(
                            color: learned ? colors.success : colors.error,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              learned
                                  ? LucideIcons.circleCheck
                                  : LucideIcons.rotateCw,
                              size: 13,
                              color: learned ? colors.success : colors.error,
                            ),
                            const SizedBox(width: 4),
                            label(
                              context,
                              learned ? 'LEARNED' : 'LEARNING',
                              size: 11,
                              weight: FontWeight.w700,
                              spacing: .4,
                              color: learned ? colors.success : colors.error,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AudioButton(word, size: 40),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  label(
                    context,
                    word.english,
                    size: 32,
                    weight: FontWeight.w700,
                    spacing: -.5,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (!flipped) ...[
                    const SizedBox(height: 6),
                    label(
                      context,
                      'Tap to reveal translation',
                      color: colors.outline,
                      align: TextAlign.center,
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.lowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          label(
                            context,
                            "O'ZBEKCHA TARJIMA",
                            size: 11,
                            weight: FontWeight.w700,
                            spacing: .8,
                            color: colors.muted,
                          ),
                          const SizedBox(height: 4),
                          label(
                            context,
                            word.translation,
                            size: 20,
                            weight: FontWeight.w600,
                            color: colors.primary,
                            align: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: flipped
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ActionButton(
                                'Learning',
                                height: 44,
                                fontSize: 14,
                                leadingIcon: LucideIcons.rotateCw,
                                background: !learned
                                    ? colors.errorContainer
                                    : colors.high,
                                border: !learned
                                    ? colors.error
                                    : Colors.transparent,
                                color: !learned ? colors.error : colors.muted,
                                weight: !learned
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                onPressed: () => state.setLearned(word, false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ActionButton(
                                'Learned',
                                height: 44,
                                fontSize: 14,
                                leadingIcon: LucideIcons.circleCheck,
                                background: learned
                                    ? colors.successContainer
                                    : colors.high,
                                border: learned
                                    ? colors.success
                                    : Colors.transparent,
                                color: learned ? colors.success : colors.muted,
                                weight: learned
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                onPressed: () => state.setLearned(word, true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _flip,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.rotateCcw,
                                  size: 15,
                                  color: colors.muted,
                                ),
                                const SizedBox(width: 6),
                                label(
                                  context,
                                  'Flip back',
                                  size: 13,
                                  color: colors.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ActionButton('Reveal translation', onPressed: _flip),
            ),
          ],
        ),
      ),
    );
  }
}
