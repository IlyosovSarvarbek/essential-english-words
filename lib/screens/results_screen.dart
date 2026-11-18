import 'package:material_ui/material_ui.dart';

import '../models/vocabulary.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.result});
  final QuizResult result;

  void _returnToUnit(BuildContext context) {
    final route = '/unit/${result.bookId}/${result.unitId}';
    var found = false;
    Navigator.popUntil(context, (candidate) {
      if (candidate.settings.name == route) {
        found = true;
        return true;
      }
      return candidate.isFirst;
    });
    if (!found) Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppPage(
      title: 'Unit ${result.unitId}',
      onBack: () => _returnToUnit(context),
      child: ContentList(
        top: 16,
        children: [
          SurfaceCard(
            radius: 16,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: colors.lowest,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.highest, width: 4),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: result.percentage >= 70
                            ? colors.success
                            : colors.blue,
                        width: 5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        label(
                          context,
                          '${result.percentage}%',
                          size: 22,
                          weight: FontWeight.w700,
                        ),
                        const SizedBox(height: 2),
                        label(
                          context,
                          'MASTERY',
                          size: 10,
                          weight: FontWeight.w700,
                          color: colors.muted,
                          spacing: .8,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                label(
                  context,
                  'Quiz completed',
                  size: 20,
                  weight: FontWeight.w700,
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  color: colors.container,
                  radius: 10,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      label(
                        context,
                        '${result.score}',
                        size: 28,
                        weight: FontWeight.w700,
                      ),
                      const SizedBox(width: 8),
                      label(context, '/', size: 20, color: colors.outline),
                      const SizedBox(width: 8),
                      label(
                        context,
                        '${result.total}',
                        size: 20,
                        weight: FontWeight.w600,
                        color: colors.muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            radius: 16,
            child: Column(
              children: [
                _metadata(
                  context,
                  'Correct answers',
                  result.score,
                  colors.blue,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Divider(height: 1, color: colors.container),
                ),
                _metadata(
                  context,
                  'Incorrect answers',
                  result.total - result.score,
                  colors.outlineVariant,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Divider(height: 1, color: colors.container),
                ),
                _metadata(
                  context,
                  'Total questions',
                  result.total,
                  colors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ActionButton(
            'Retry Quiz',
            weight: FontWeight.w700,
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              '/quiz/${result.bookId}/${result.unitId}?mode=${result.mode.value}',
            ),
          ),
          const SizedBox(height: 12),
          ActionButton(
            'Return to Unit',
            color: colors.primary,
            background: colors.high,
            onPressed: () => _returnToUnit(context),
          ),
        ],
      ),
    );
  }

  Widget _metadata(BuildContext context, String title, int value, Color dot) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: label(context, title, color: AppColors.of(context).muted),
            ),
            label(context, '$value', weight: FontWeight.w700),
          ],
        ),
      );
}
