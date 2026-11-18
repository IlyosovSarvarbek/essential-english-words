import 'dart:math';

class Word {
  const Word({
    required this.id,
    required this.bookId,
    required this.unitId,
    required this.english,
    required this.uzbek,
    required this.partOfSpeech,
  });

  factory Word.fromJson(Map<String, dynamic> json, int bookId, int unitId) {
    final translations = json['uzbek'];
    return Word(
      id: json['id'] as String,
      bookId: bookId,
      unitId: unitId,
      english: json['english'] as String,
      uzbek: translations is List
          ? translations.cast<String>()
          : [translations as String],
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
    );
  }

  final String id;
  final int bookId;
  final int unitId;
  final String english;
  final List<String> uzbek;
  final String partOfSpeech;
  String get uniqueId => id.startsWith('b${bookId}_') ? id : 'b${bookId}_$id';
  String get translation => uzbek.join(', ');
}

class VocabularyUnit {
  const VocabularyUnit({
    required this.bookId,
    required this.id,
    required this.words,
  });
  final int bookId;
  final int id;
  final List<Word> words;
}

class Book {
  const Book({required this.id, required this.units});
  final int id;
  final List<VocabularyUnit> units;
  String get title => 'Book $id';
  List<Word> get words =>
      units.expand((unit) => unit.words).toList(growable: false);
}

class ProgressStats {
  const ProgressStats(this.learned, this.total);
  final int learned;
  final int total;
  int get percentage => total == 0 ? 0 : (learned / total * 100).round();
}

enum QuizMode {
  enUz('en-uz', 'English → Uzbek'),
  uzEn('uz-en', 'Uzbek → English');

  const QuizMode(this.value, this.title);
  final String value;
  final String title;
  static QuizMode parse(String? value) => value == 'uz-en' ? uzEn : enUz;
}

class QuizQuestion {
  const QuizQuestion({
    required this.word,
    required this.question,
    required this.correctAnswer,
    required this.options,
  });
  final Word word;
  final String question;
  final String correctAnswer;
  final List<String> options;
}

// Matches the source: words stay in unit order, answer options are shuffled.
List<QuizQuestion> generateQuiz(
  VocabularyUnit unit,
  Book book,
  QuizMode mode, {
  Random? random,
}) {
  final rng = random ?? Random();
  String answer(Word word) =>
      mode == QuizMode.enUz ? word.translation : word.english;
  return unit.words
      .map((word) {
        final correct = answer(word);
        final others =
            unit.words
                .where((other) => other.uniqueId != word.uniqueId)
                .toList()
              ..shuffle(rng);
        final distractors = <String>{};
        for (final candidate in [...others, ...(book.words..shuffle(rng))]) {
          final text = answer(candidate);
          if (text != correct) distractors.add(text);
          if (distractors.length == 3) break;
        }
        final options = [correct, ...distractors]..shuffle(rng);
        return QuizQuestion(
          word: word,
          question: mode == QuizMode.enUz ? word.english : word.translation,
          correctAnswer: correct,
          options: List.unmodifiable(options),
        );
      })
      .toList(growable: false);
}

class QuizResult {
  const QuizResult({
    required this.bookId,
    required this.unitId,
    required this.mode,
    required this.score,
    required this.total,
    required this.completedAt,
  });
  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    bookId: json['bookId'] as int,
    unitId: json['unitId'] as int,
    mode: QuizMode.parse(json['mode'] as String?),
    score: json['score'] as int,
    total: json['total'] as int,
    completedAt: json['completedAt'] as int,
  );
  final int bookId;
  final int unitId;
  final QuizMode mode;
  final int score;
  final int total;
  final int completedAt;
  int get percentage => total == 0 ? 0 : (score / total * 100).round();
  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'unitId': unitId,
    'mode': mode.value,
    'score': score,
    'total': total,
    'completedAt': completedAt,
  };
}
