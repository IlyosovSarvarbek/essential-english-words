import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/progress_storage.dart';
import 'services/vocabulary_repository.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const Bootstrap());
}

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  late Future<AppState> _loading = _load();
  Future<AppState> _load() async {
    final state = AppState(
      vocabulary: await VocabularyRepository.load(),
      storage: LocalProgressStorage(),
    );
    await state.initialize();
    return state;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppState>(
    future: _loading,
    builder: (context, snapshot) {
      if (snapshot.hasData) return EssentialWordsApp(state: snapshot.data!);
      return MaterialApp(
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xff121316),
          body: Center(
            child: snapshot.hasError
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Could not load vocabulary.'),
                      TextButton(
                        onPressed: () => setState(() => _loading = _load()),
                        child: const Text('Try again'),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(color: Color(0xffb3c5ff)),
          ),
        ),
      );
    },
  );
}
