# Essential Words

**Build your English vocabulary, one unit at a time.**

Essential Words is an English–Uzbek vocabulary learning app built with Flutter. Explore 3,600 words, listen to their pronunciation, practice with animated flashcards, and test your understanding in both languages. Your learning progress stays saved on your device, so you can pick up where you left off.

**6 books · 180 units · 20 words per unit · Light and dark themes**

## Screenshots

Actual app screens, captured at a mobile viewport size.

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/books.png" alt="Dark theme book library with overall learning progress and six books" width="240"><br><strong>Book library</strong></td>
    <td align="center"><img src="docs/screenshots/units.png" alt="Book units with word counts and individual progress" width="240"><br><strong>Units and progress</strong></td>
    <td align="center"><img src="docs/screenshots/learning-modes.png" alt="Unit menu with word review, flashcards, and two quiz directions" width="240"><br><strong>Learning modes</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/word-review.png" alt="English words with Uzbek translations, parts of speech, pronunciation, and learned controls" width="240"><br><strong>Word review</strong></td>
    <td align="center"><img src="docs/screenshots/flashcards.png" alt="Revealed flashcard with Uzbek translation and learning status controls" width="240"><br><strong>Flashcards</strong></td>
    <td align="center"><img src="docs/screenshots/quiz.png" alt="Multiple choice vocabulary quiz showing correct answer feedback" width="240"><br><strong>Vocabulary quizzes</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/results.png" alt="Completed quiz with score, answer counts, and retry action" width="240"><br><strong>Quiz results</strong></td>
    <td align="center"><img src="docs/screenshots/search.png" alt="Dictionary search results for agree across the vocabulary collection" width="240"><br><strong>Dictionary search</strong></td>
    <td align="center"><img src="docs/screenshots/light-theme.png" alt="Book library in the light theme" width="240"><br><strong>Light theme</strong></td>
  </tr>
</table>

## Features

- **A structured vocabulary library.** Six books with 30 units each. Every word includes its English spelling, Uzbek translations, and part of speech.
- **Word review.** Browse all 20 words in a unit, hear their pronunciation, and mark words as learned or return them to learning.
- **Flashcard practice.** Recall the meaning before revealing the translation with a smooth 3D flip. Practice words you have yet to learn and move through the deck at your own pace.
- **Two quiz directions.** Practice English → Uzbek or Uzbek → English with four answer choices, immediate feedback, a final score, and the option to try again.
- **Visible progress.** Track learned words and completion percentages for each unit, each book, and the full library. Changes update immediately and remain saved after restarting.
- **English pronunciation.** Listen to words using the device or browser's English (US) text-to-speech voice.
- **Bilingual dictionary.** Search English words or Uzbek translations across all six books and open a result's unit.
- **A comfortable interface.** Switch between light and dark themes, enjoy rounded cards and smooth touch ripples, and scroll with elastic, spring-back motion across platforms. Flashcard flips respect the system's reduced-motion preference.
- **Learn without an account.** Vocabulary, fonts, and images are bundled with the app. Core study features work offline, and progress, theme preferences, and quiz history are stored locally.

Pronunciation availability depends on the platform's speech engine and installed English voices. An offline voice is needed for offline pronunciation; Linux currently has no pronunciation implementation.

## How to study

1. Choose a book and open a unit.
2. Use **Review All Words** to read translations and listen to pronunciation.
3. Open **Practice Flashcards** to recall words before revealing their meanings. Mark familiar words as **Learned**.
4. Take a quiz in either direction and review your score.
5. Continue through the units while your progress grows.

Flashcard sessions start with the unit's unlearned words. Words marked learned remain available for the current session and are excluded the next time you open the deck. You can always revisit every word through word review. Quiz scores are separate from learned-word progress.

## Getting started

Use **Flutter 3.50 or newer** with **Dart 3.14 or newer**, plus the toolchain for your target platform. Run these commands from the project directory:

```sh
flutter pub get
flutter run
```

To run in Chrome:

```sh
flutter run -d chrome
```

Use `--web-port 8080` during development to keep the same browser storage between runs.

The project includes Android, iOS, web, Windows, macOS, and Linux targets. iOS and macOS builds require macOS and Xcode; desktop builds require the corresponding platform's Flutter tooling.

### Dictionary and direct links

The dictionary is available at the `/search` route. In a web deployment, append `/#/search` to the app's base URL.

On Android and iOS, the custom URL scheme can open specific screens:

| Destination | Link |
| --- | --- |
| Dictionary | `essentialenglishwords:///search` |
| Book 1 units | `essentialenglishwords:///units/1` |
| Book 1, Unit 1 | `essentialenglishwords:///unit/1/1` |
| Word review | `essentialenglishwords:///learn/1/1` |
| Flashcards | `essentialenglishwords:///flashcards/1/1` |

Use three slashes after the scheme so the complete route reaches the app.

## Offline storage

Learning progress, theme preferences, and quiz attempts are stored in a local SQLite database:

| Platform | Storage |
| --- | --- |
| Android, iOS, macOS | Native SQLite through `sqflite` |
| Web | SQLite WebAssembly in a worker, persisted in IndexedDB through `sqflite_common_ffi_web` |
| Windows, Linux | SQLite through `sqflite_common_ffi` |

Changing a word's status updates only that word's record. Each completed quiz adds one result, and an index supports reading results in pages. The app keeps the latest 100 results in memory; all older attempts remain in the database.

Existing installations automatically import their saved progress, theme, and quiz history from preferences storage once. The import runs in a transaction, and original preference values are retained. A failed import offers a retry instead of opening an empty learning state.

Web storage belongs to the site's origin and remains subject to browser quotas and site-data clearing. The web SQLite adapter is currently marked experimental by its maintainer.

The required `web/sqlite3.wasm` and `web/sqflite_sw.js` files are included in the project. After upgrading the SQLite packages, regenerate them before building:

```sh
dart run sqflite_common_ffi_web:setup --force
```

## Build and verify

```sh
flutter analyze
flutter test
```

Tests cover vocabulary integrity, search, quiz generation, SQLite persistence and migration, paged quiz history, study flows, flashcard animation, ripple feedback, and elastic scrolling.

Build an Android APK or a web release:

```sh
flutter build apk --release
flutter build web --release --no-web-resources-cdn
```

The web command bundles rendering resources locally. Serve `build/web` using a web server. Android uses application ID `uz.essentialwords.flutter`; configure your own release signing key before distributing through an app store.

## Project structure

| Path | Contents |
| --- | --- |
| `lib/screens/` | Library, units, study modes, quizzes, results, and search |
| `lib/widgets/` | Reusable cards, buttons, headers, progress indicators, and flip animation |
| `lib/models/` | Vocabulary, progress, and quiz models |
| `lib/services/` | Vocabulary loading, local storage, and pronunciation |
| `lib/state/` | Shared learning progress and theme state |
| `lib/theme/` | Colors, typography, transitions, and scrolling behavior |
| `assets/data/books/` | Six bundled vocabulary books |
| `assets/fonts/` | Bundled fonts and their license files |
| `docs/screenshots/` | App screenshots used in this README |
| `test/` | Unit and widget tests |

Built with Flutter and Dart, using `material_ui` for Material components, the `sqflite` family for local persistence, `flutter_tts` for pronunciation, and `lucide_icons_flutter` for icons. `shared_preferences` is retained only to import data from earlier installations.
