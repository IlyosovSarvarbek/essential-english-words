import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Pronunciation {
  final FlutterTts _tts = FlutterTts();
  Future<void>? _initializing;

  Future<void> _initialize() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1);
    // Native plugins normalize 0..1, while browser speech uses 0..2.
    await _tts.setSpeechRate(kIsWeb ? 0.9 : 0.45);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await HapticFeedback.lightImpact();
    _initializing ??= _initialize();
    await _initializing;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      /* Platform may not supply speech. */
    }
  }
}
