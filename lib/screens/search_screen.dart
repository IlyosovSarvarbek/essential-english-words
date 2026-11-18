import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/vocabulary.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/word_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  QuizMode _direction = QuizMode.enUz;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final query = _controller.text;
    final results = AppScope.of(context).vocabulary.search(query, _direction);
    return AppPage(
      title: 'Search',
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.low,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (colors.dark ? Colors.white : Colors.black)
                              .withValues(alpha: .1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            LucideIcons.search,
                            size: 18,
                            color: colors.muted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              style: TextStyle(
                                fontSize: 15,
                                color: colors.text,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: _direction == QuizMode.enUz
                                    ? 'Search English word...'
                                    : 'Qidirish (o‘zbekcha)...',
                                hintStyle: TextStyle(
                                  color: colors.outline,
                                  fontSize: 15,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          if (query.isNotEmpty)
                            IconButton(
                              tooltip: 'Clear search',
                              onPressed: () => setState(_controller.clear),
                              icon: Icon(
                                LucideIcons.x,
                                size: 16,
                                color: colors.muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: colors.container,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          for (final mode in QuizMode.values)
                            Expanded(
                              child: Material(
                                color: _direction == mode
                                    ? colors.low
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  side: BorderSide(
                                    color: _direction == mode
                                        ? colors.cardBorder
                                        : Colors.transparent,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(9),
                                  onTap: () =>
                                      setState(() => _direction = mode),
                                  child: SizedBox(
                                    height: 36,
                                    child: Center(
                                      child: label(
                                        context,
                                        mode.title,
                                        size: 13,
                                        weight: _direction == mode
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: _direction == mode
                                            ? colors.text
                                            : colors.muted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (query.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: label(
                            context,
                            '${results.length} MATCHING WORDS',
                            size: 11,
                            weight: FontWeight.w700,
                            spacing: .8,
                            color: colors.muted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: query.trim().isEmpty
                ? const EmptyState(
                    title: 'Search for a word',
                    description: 'Type in English or Uzbek to explore definitions across all 6 books.',
                  )
                : results.isEmpty
                ? const EmptyState(
                    title: 'No words found',
                    description: 'Try another word or spelling.',
                    icon: LucideIcons.searchX,
                  )
                : ContentList(
                    top: 8,
                    gap: 10,
                    children: [
                      for (final word in results)
                        WordCard(word, searchResult: true),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
