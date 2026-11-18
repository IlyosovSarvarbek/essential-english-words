# Essential Words - Flutter

A Flutter recreation of the Expo application in `../react_native`. The reference directory is read-only; this app has independent copies of the original vocabulary and visual assets.

Requires Flutter 3.50 / Dart 3.14 or newer. This SDK uses the standalone `material_ui` package.

```sh
flutter pub get
flutter run
```

Choose an Android emulator/device, iOS simulator/device, Chrome, or a supported desktop target. Android uses application ID `uz.essentialwords.flutter` and can coexist with the Expo app.

```sh
flutter analyze
flutter test
flutter build apk --release
flutter build web --release --no-web-resources-cdn
```

The generated Android release configuration uses the Flutter template's debug signing key. Configure a distribution signing key before submitting to an app store. iOS builds require macOS and Xcode.

## Features and source parity

- All six original books, 180 units, and 3,600 English words with every Uzbek translation and part of speech.
- Matching dark/light palettes, headers, cards, spacing, progress, portrait layout, and 640-pixel content limit.
- Smooth tinted ripples on cards and buttons, with contrast on blue actions and both themes.
- Perspective flashcard flips with readable faces, smooth height changes, reversible motion, and support for the system's reduced-motion preference.
- iOS-style elastic scrolling on every platform, including short lists and desktop mouse dragging. Lists spring back to their bounds when released.
- Book, unit, learning menu, word review, flashcards, two quiz directions, results, and dictionary routes.
- Learned statuses update unit, book, and overall progress immediately and persist across restarts.
- Flashcards snapshot unlearned words on entry. A newly learned card remains in the current deck; reopening excludes it. Completed units offer review, where words can be unlearned.
- Quizzes retain unit word order and shuffle four distinct answers. Selection locks after answering and reveals feedback. Results show mastery, answer counts, retry, and return to the existing unit screen. Quizzes do not change learned statuses.
- Pronunciation uses the device's English (US) text-to-speech engine and tactile feedback. Offline speech needs an installed voice. Linux has no flutter_tts implementation and reports pronunciation unavailability.
- Dictionary search supports English and Uzbek substrings across all books and opens the containing unit.
- Original launcher imagery and matching light/dark native splash screens.

The source comments out its header search button. This port preserves that visible UI; the full dictionary remains available at `/search`, including `essentialenglishwords:///search` on mobile and `/#/search` on web. Mobile custom-scheme links use three slashes so Flutter receives the complete route path.

## Structure

| Directory | Responsibility |
| --- | --- |
| `lib/models` | Vocabulary, progress, quiz generation, results |
| `lib/services` | Bundled data, persistence, pronunciation |
| `lib/state` | Shared learning progress and theme |
| `lib/theme` | Reference colors and page transitions |
| `lib/screens` | All nine screen types |
| `lib/widgets` | Shared headers, cards, buttons, progress and words |
| `assets/data/books` | Unmodified copies of all six source JSON files |
| `test` | Data, search, quizzes, persistence and user flows |

Learning progress, theme, and quiz history persist through SharedPreferencesAsync. Word IDs use the source's book prefixes. Writes are serialized so rapid changes cannot replace newer progress with an older snapshot. Expo installations keep separate storage; this app does not read or modify their database.

Vocabulary, fonts, and images are bundled. No account or backend is required. The web build command above also bundles rendering resources.

Regenerate platform assets after changing images:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

`assets/images/splash.png` is an 800-pixel copy of the source splash, giving a 200-point width at 4x density. Font licenses are included beside the Roboto and Noto Sans Symbols files in `assets/fonts`.
