import 'package:material_ui/material_ui.dart';

import 'models/vocabulary.dart';
import 'screens/books_screen.dart';
import 'screens/flashcards_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/results_screen.dart';
import 'screens/search_screen.dart';
import 'screens/unit_menu_screen.dart';
import 'screens/units_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/app_scroll_behavior.dart';

class EssentialWordsApp extends StatelessWidget {
  const EssentialWordsApp({super.key, required this.state, this.initialRoute});
  final AppState state;
  final String? initialRoute;

  Route<dynamic> _route(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '/') ?? Uri(path: '/');
    final parts = [
      if (uri.scheme == 'essentialenglishwords' && uri.host.isNotEmpty)
        uri.host,
      ...uri.pathSegments,
    ];
    final type = parts.isEmpty ? '' : parts.first;
    int bounded(String? raw, int max) {
      final value = int.tryParse(raw ?? '') ?? 1;
      return value >= 1 && value <= max ? value : 1;
    }

    final bookId = bounded(parts.length > 1 ? parts[1] : null, 6);
    final unitId = bounded(
      parts.length > 2 ? parts[2] : null,
      state.vocabulary.book(bookId).units.length,
    );
    final mode = QuizMode.parse(uri.queryParameters['mode']);
    final Widget screen;
    if (type == 'quiz' && parts.length > 1 && parts[1] == 'results') {
      final resultBook = bounded(uri.queryParameters['bookId'], 6);
      final resultUnit = bounded(
        uri.queryParameters['unitId'],
        state.vocabulary.book(resultBook).units.length,
      );
      final total = (int.tryParse(uri.queryParameters['total'] ?? '') ?? 20)
          .clamp(1, 10000);
      final score = (int.tryParse(uri.queryParameters['score'] ?? '') ?? 0)
          .clamp(0, total);
      screen = ResultsScreen(
        result: QuizResult(
          bookId: resultBook,
          unitId: resultUnit,
          mode: mode,
          score: score,
          total: total,
          completedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else {
      screen = switch (type) {
        'units' => UnitsScreen(bookId: bookId),
        'unit' => UnitMenuScreen(bookId: bookId, unitId: unitId),
        'learn' => LearnScreen(bookId: bookId, unitId: unitId),
        'flashcards' => FlashcardsScreen(bookId: bookId, unitId: unitId),
        'quiz' => QuizScreen(bookId: bookId, unitId: unitId, mode: mode),
        'search' => const SearchScreen(),
        _ => const BooksScreen(),
      };
    }
    return MaterialPageRoute(settings: settings, builder: (_) => screen);
  }

  List<Route<dynamic>> _initialRoutes(String name) {
    final uri = Uri.tryParse(name);
    final parts = uri?.pathSegments ?? [];
    final routes = <Route<dynamic>>[_route(const RouteSettings(name: '/'))];
    if (name == '/' || name.isEmpty) return routes;
    if (parts.length >= 2 &&
        ['units', 'unit', 'learn', 'flashcards', 'quiz'].contains(parts[0]) &&
        int.tryParse(parts[1]) != null) {
      if (parts[0] != 'units') {
        routes.add(_route(RouteSettings(name: '/units/${parts[1]}')));
      }
      if (parts.length >= 3 && parts[0] != 'unit') {
        routes.add(
          _route(RouteSettings(name: '/unit/${parts[1]}/${parts[2]}')),
        );
      }
    }
    routes.add(_route(RouteSettings(name: name)));
    return routes;
  }

  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'Essential Words',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const AppScrollBehavior(),
        theme: appTheme(false),
        darkTheme: appTheme(true),
        themeMode: state.themeMode,
        initialRoute: initialRoute,
        onGenerateRoute: _route,
        onGenerateInitialRoutes: _initialRoutes,
      ),
    ),
  );
}
