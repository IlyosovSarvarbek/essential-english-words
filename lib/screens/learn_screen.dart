import 'package:material_ui/material_ui.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/word_card.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key, required this.bookId, required this.unitId});
  final int bookId;
  final int unitId;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final stats = state.stats(state.vocabulary.unit(bookId, unitId).words);
    return AppPage(
      title: 'Unit $unitId',
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: label(
          context,
          '${stats.learned} / ${stats.total}',
          weight: FontWeight.w600,
          color: AppColors.of(context).muted,
        ),
      ),
      belowHeader: ProgressTrack(
        stats.percentage,
        height: 3,
        color: stats.percentage == 100 ? AppColors.of(context).success : null,
      ),
      child: ContentList(
        gap: 10,
        children: [
          for (final word in state.vocabulary.unit(bookId, unitId).words)
            WordCard(word, key: ValueKey(word.uniqueId)),
        ],
      ),
    );
  }
}
