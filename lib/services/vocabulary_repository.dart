import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/vocabulary.dart';

class VocabularyRepository {
  VocabularyRepository(this.books)
    : allWords = List.unmodifiable(books.expand((book) => book.words));
  final List<Book> books;
  final List<Word> allWords;

  static Future<VocabularyRepository> load({AssetBundle? bundle}) async {
    final assets = bundle ?? rootBundle;
    final books = await Future.wait(
      List.generate(6, (index) async {
        final id = index + 1;
        final raw = jsonDecode(
          await assets.loadString('assets/data/books/$id.json'),
        ) as Map<String, dynamic>;
        final units = (raw['units'] as List)
            .cast<Map<String, dynamic>>()
            .map((unit) {
              final unitId = unit['unitId'] as int;
              final words = (unit['words'] as List)
                  .cast<Map<String, dynamic>>()
                  .map((word) => Word.fromJson(word, id, unitId))
                  .toList(growable: false);
              return VocabularyUnit(
                bookId: id,
                id: unitId,
                words: List.unmodifiable(words),
              );
            })
            .toList(growable: false);
        return Book(id: id, units: List.unmodifiable(units));
      }),
    );
    return VocabularyRepository(List.unmodifiable(books));
  }

  Book book(int id) => books.firstWhere((book) => book.id == id);
  VocabularyUnit unit(int bookId, int unitId) =>
      book(bookId).units.firstWhere((unit) => unit.id == unitId);

  List<Word> search(String query, QuizMode mode) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return [];
    return allWords
        .where(
          (word) => mode == QuizMode.enUz
              ? word.english.toLowerCase().contains(text)
              : word.uzbek.any(
                  (translation) => translation.toLowerCase().contains(text),
                ),
        )
        .toList(growable: false);
  }
}
