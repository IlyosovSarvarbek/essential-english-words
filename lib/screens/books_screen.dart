import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = AppColors.of(context);
    final stats = state.stats(state.vocabulary.allWords);
    return AppPage(
      title: 'Books',
      back: false,
      themeToggle: true,
      child: ContentList(
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.bookOpen, size: 20, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: label(
                        context,
                        'Essential English Words',
                        size: 16,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    label(
                      context,
                      '${stats.percentage}%',
                      size: 16,
                      weight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                label(
                  context,
                  '${stats.learned} of ${stats.total} words learned',
                  size: 13,
                  color: colors.muted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final book in state.vocabulary.books) ...[
            Builder(
              builder: (context) {
                final stats = state.stats(book.words);
                return SurfaceCard(
                  onTap: () =>
                      Navigator.pushNamed(context, '/units/${book.id}'),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    label(
                                      context,
                                      '${book.units.length} units',
                                      size: 13,
                                      weight: FontWeight.w500,
                                      color: colors.muted,
                                    ),
                                    if (stats.learned > 0) ...[
                                      label(
                                        context,
                                        '  •  ',
                                        size: 12,
                                        color: colors.muted,
                                      ),
                                      label(
                                        context,
                                        '${stats.learned} / ${stats.total} words',
                                        size: 13,
                                        weight: FontWeight.w500,
                                        color: colors.primary,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                label(
                                  context,
                                  book.title,
                                  size: 20,
                                  weight: FontWeight.w700,
                                  spacing: -.2,
                                ),
                              ],
                            ),
                          ),
                          if (stats.percentage > 0) ...[
                            label(
                              context,
                              '${stats.percentage}%',
                              weight: FontWeight.w600,
                            ),
                            const SizedBox(width: 8),
                          ],
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(
                              LucideIcons.chevronRight,
                              size: 20,
                              color: colors.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ProgressTrack(stats.percentage, height: 4),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
