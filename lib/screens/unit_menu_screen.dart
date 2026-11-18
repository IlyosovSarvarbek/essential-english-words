import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class UnitMenuScreen extends StatelessWidget {
  const UnitMenuScreen({super.key, required this.bookId, required this.unitId});
  final int bookId;
  final int unitId;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = AppColors.of(context);
    final stats = state.stats(state.vocabulary.unit(bookId, unitId).words);
    final percentColor = stats.percentage == 100
        ? colors.success
        : colors.primary;
    final items = [
      (
        'Practice Flashcards',
        LucideIcons.layers,
        '/flashcards/$bookId/$unitId',
      ),
      ('Review All Words', LucideIcons.listChecks, '/learn/$bookId/$unitId'),
      (
        'English → Uzbek Quiz',
        LucideIcons.arrowRight,
        '/quiz/$bookId/$unitId?mode=en-uz',
      ),
      (
        'Uzbek → English Quiz',
        LucideIcons.arrowLeft,
        '/quiz/$bookId/$unitId?mode=uz-en',
      ),
    ];
    return AppPage(
      title: 'Unit $unitId',
      child: ContentList(
        top: 16,
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: label(
                        context,
                        'Book $bookId • Unit $unitId',
                        size: 16,
                        weight: FontWeight.w700,
                      ),
                    ),
                    label(
                      context,
                      '${stats.percentage}%',
                      size: 16,
                      weight: FontWeight.w700,
                      color: percentColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                label(
                  context,
                  '${stats.learned} of ${stats.total} words learned',
                  size: 13,
                  color: colors.muted,
                ),
                const SizedBox(height: 14),
                ProgressTrack(
                  stats.percentage,
                  color: stats.percentage == 100 ? colors.success : colors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          label(
            context,
            'Choose a learning mode',
            size: 18,
            weight: FontWeight.w700,
            spacing: -.2,
          ),
          const SizedBox(height: 12),
          for (final (title, icon, route) in items) ...[
            SurfaceCard(
              onTap: () => Navigator.pushNamed(context, route),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.high,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: colors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: label(
                      context,
                      title,
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: colors.outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
