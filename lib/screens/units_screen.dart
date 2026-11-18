import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class UnitsScreen extends StatelessWidget {
  const UnitsScreen({super.key, required this.bookId});
  final int bookId;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = AppColors.of(context);
    final book = state.vocabulary.book(bookId);
    return AppPage(
      title: book.title,
      child: ContentList(
        gap: 8,
        children: [
          for (final unit in book.units)
            Builder(
              builder: (context) {
                final stats = state.stats(unit.words);
                final complete = stats.percentage == 100;
                return SurfaceCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () =>
                      Navigator.pushNamed(context, '/unit/$bookId/${unit.id}'),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                label(
                                  context,
                                  'Unit ${unit.id}',
                                  size: 18,
                                  weight: FontWeight.w700,
                                  spacing: -.2,
                                ),
                                label(
                                  context,
                                  '${stats.learned} / ${stats.total} words',
                                  size: 13,
                                  color: colors.muted,
                                ),
                              ],
                            ),
                          ),
                          label(
                            context,
                            '${stats.percentage}%',
                            size: 13,
                            weight: stats.percentage > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: complete
                                ? colors.success
                                : stats.percentage > 0
                                ? colors.text
                                : colors.outline,
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            complete
                                ? LucideIcons.circleCheck
                                : LucideIcons.chevronRight,
                            size: 18,
                            color: complete ? colors.success : colors.outline,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ProgressTrack(
                        stats.percentage,
                        color: complete ? colors.success : colors.blue,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
