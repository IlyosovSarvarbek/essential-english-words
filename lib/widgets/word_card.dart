import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/vocabulary.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class WordCard extends StatelessWidget {
  const WordCard(this.word, {super.key, this.searchResult = false});
  final Word word;
  final bool searchResult;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = AppColors.of(context);
    final learned = state.isLearned(word);
    return SurfaceCard(
      onTap: searchResult
          ? () => Navigator.pushNamed(
              context,
              '/unit/${word.bookId}/${word.unitId}',
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    label(
                      context,
                      word.english,
                      size: 22,
                      weight: FontWeight.w700,
                      spacing: -.2,
                    ),
                    if (word.partOfSpeech.isNotEmpty)
                      PartOfSpeech(word.partOfSpeech),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AudioButton(word, size: searchResult ? 36 : 38),
            ],
          ),
          SizedBox(height: searchResult ? 4 : 10),
          label(
            context,
            word.translation,
            size: 16,
            weight: FontWeight.w600,
            color: colors.primary,
            height: 22 / 16,
          ),
          SizedBox(height: searchResult ? 8 : 14),
          if (searchResult)
            label(
              context,
              'Book ${word.bookId} • Unit ${word.unitId}',
              size: 12,
              weight: FontWeight.w500,
              color: colors.muted,
            )
          else
            Semantics(
              container: true,
              button: true,
              child: Material(
                color: learned
                    ? colors.success.withValues(alpha: colors.dark ? .15 : .12)
                    : colors.high,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: learned ? colors.success : Colors.transparent,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => state.setLearned(word, !learned),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          learned
                              ? LucideIcons.circleCheck
                              : LucideIcons.rotateCw,
                          size: 16,
                          color: learned ? colors.success : colors.muted,
                        ),
                        const SizedBox(width: 6),
                        label(
                          context,
                          learned ? 'Learned' : 'Mark as Learned',
                          size: 13,
                          weight: FontWeight.w600,
                          color: learned ? colors.success : colors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
