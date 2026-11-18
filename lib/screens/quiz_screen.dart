import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/vocabulary.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.bookId,
    required this.unitId,
    required this.mode,
  });
  final int bookId;
  final int unitId;
  final QuizMode mode;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion>? _questions;
  final _scrollController = ScrollController();
  int _index = 0;
  int _score = 0;
  String? _selected;
  bool _finishing = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = AppScope.of(context).vocabulary;
    _questions ??= generateQuiz(
      repository.unit(widget.bookId, widget.unitId),
      repository.book(widget.bookId),
      widget.mode,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _select(String answer) {
    if (_selected != null) return;
    final correct = answer == _questions![_index].correctAnswer;
    setState(() {
      _selected = answer;
      if (correct) _score++;
    });
    unawaited(
      correct ? HapticFeedback.lightImpact() : HapticFeedback.heavyImpact(),
    );
  }

  void _next() {
    if (_selected == null || _finishing) return;
    if (_index < _questions!.length - 1) {
      setState(() {
        _index++;
        _selected = null;
      });
    } else {
      _finishing = true;
      final result = QuizResult(
        bookId: widget.bookId,
        unitId: widget.unitId,
        mode: widget.mode,
        score: _score,
        total: _questions!.length,
        completedAt: DateTime.now().millisecondsSinceEpoch,
      );
      unawaited(AppScope.of(context).saveResult(result));
      Navigator.pushReplacementNamed(
        context,
        '/quiz/results?bookId=${widget.bookId}&unitId=${widget.unitId}&mode=${widget.mode.value}&score=$_score&total=${_questions!.length}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final questions = _questions!;
    if (questions.isEmpty) {
      return AppPage(
        title: widget.mode.title,
        child: Center(
          child: label(
            context,
            'No quiz questions could be generated.',
            color: colors.muted,
          ),
        ),
      );
    }
    final question = questions[_index];
    final answered = _selected != null;
    final correct = _selected == question.correctAnswer;
    final percentage = ((_index + 1) / questions.length * 100).round();
    return AppPage(
      title: widget.mode.title,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomSpace(context)),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  label(
                    context,
                    'QUESTION ${_index + 1} OF ${questions.length}',
                    size: 12,
                    weight: FontWeight.w700,
                    color: colors.muted,
                    spacing: .8,
                  ),
                  label(
                    context,
                    '$percentage%',
                    size: 13,
                    weight: FontWeight.w600,
                    color: colors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ProgressTrack(percentage),
              const SizedBox(height: 16),
              SurfaceCard(
                radius: 16,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (question.word.partOfSpeech.isNotEmpty) ...[
                      PartOfSpeech(
                        question.word.partOfSpeech,
                        weight: FontWeight.w700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    label(
                      context,
                      question.question,
                      size: 26,
                      weight: FontWeight.w700,
                      spacing: -.3,
                      align: TextAlign.center,
                    ),
                    if (widget.mode == QuizMode.enUz) ...[
                      const SizedBox(height: 10),
                      IconControl(
                        icon: LucideIcons.volume2,
                        tooltip: 'Listen pronunciation',
                        size: 32,
                        radius: 20,
                        background: Colors.transparent,
                        color: colors.primary,
                        onPressed: () =>
                            AppScope.of(context).pronunciation
                                .speak(question.word.english)
                                .catchError((Object error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Pronunciation is unavailable. Check your English speech voice.',
                                        ),
                                      ),
                                    );
                                  }
                                }),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (var index = 0; index < question.options.length; index++) ...[
                _option(context, question, index),
                const SizedBox(height: 10),
              ],
              if (answered) ...[
                const SizedBox(height: 6),
                SurfaceCard(
                  padding: const EdgeInsets.all(14),
                  color: correct
                      ? colors.blue.withValues(alpha: colors.dark ? .2 : .1)
                      : colors.dark
                      ? const Color(0xff2a1718)
                      : colors.errorContainer,
                  borderColor: correct ? colors.primary : colors.error,
                  child: Row(
                    children: [
                      Icon(
                        correct ? LucideIcons.circleCheck : LucideIcons.x,
                        size: 20,
                        color: correct ? colors.primary : colors.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: label(
                          context,
                          correct
                              ? 'To‘g‘ri javob! (Correct)'
                              : 'Noto‘g‘ri javob (Incorrect)',
                          weight: FontWeight.w700,
                          color: correct ? colors.primary : colors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ActionButton(
                  _index == questions.length - 1
                      ? 'Natijalarni ko‘rish'
                      : 'Keyingisi',
                  onPressed: _next,
                  radius: 12,
                  icon: LucideIcons.arrowRight,
                  weight: FontWeight.w700,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(BuildContext context, QuizQuestion question, int index) {
    final colors = AppColors.of(context);
    final option = question.options[index];
    final answered = _selected != null;
    final selected = _selected == option;
    final correct = option == question.correctAnswer;
    final showCorrect = answered && correct;
    final showWrong = answered && selected && !correct;
    final background = showCorrect
        ? colors.dark
              ? const Color(0xff1e2a4a)
              : const Color(0xffe0e7ff)
        : showWrong
        ? colors.errorContainer
        : colors.low;
    final accent = showCorrect ? colors.primary : colors.error;
    final textColor = showCorrect
        ? colors.dark
              ? colors.primary
              : const Color(0xff1e3a8a)
        : showWrong
        ? colors.error
        : colors.text;
    return Opacity(
      opacity: answered && !correct && !selected ? .5 : 1,
      child: SurfaceCard(
        color: background,
        borderColor: showCorrect || showWrong ? accent : colors.cardBorder,
        onTap: answered ? null : () => _select(option),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: showCorrect || showWrong ? accent : colors.high,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: label(
                  context,
                  String.fromCharCode(65 + index),
                  size: 13,
                  weight: FontWeight.w700,
                  color: showCorrect || showWrong ? Colors.white : colors.muted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label(
                    context,
                    option,
                    size: 16,
                    weight: FontWeight.w600,
                    color: textColor,
                    height: 22 / 16,
                    decoration: showWrong ? TextDecoration.lineThrough : null,
                  ),
                  if (showCorrect || showWrong) ...[
                    const SizedBox(height: 2),
                    label(
                      context,
                      showCorrect ? 'To‘g‘ri javob' : 'Siz tanlagan javob',
                      size: 12,
                      weight: FontWeight.w500,
                      color: accent,
                    ),
                  ],
                ],
              ),
            ),
            if (showCorrect || showWrong) ...[
              const SizedBox(width: 8),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  showCorrect ? LucideIcons.check : LucideIcons.x,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
