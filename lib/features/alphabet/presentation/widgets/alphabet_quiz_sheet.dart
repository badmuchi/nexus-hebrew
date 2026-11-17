import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/datasources/hebrew_alphabet_seed_data.dart';
import '../../domain/entities/hebrew_letter.dart';

/// Interactive Alef-Bet and Nikkud mastery quiz.
class AlphabetQuizSheet extends StatefulWidget {
  const AlphabetQuizSheet({super.key});

  @override
  State<AlphabetQuizSheet> createState() => _AlphabetQuizSheetState();
}

class _QuizQuestion {
  final String questionText;
  final String? hebrewPrompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const _QuizQuestion({
    required this.questionText,
    this.hebrewPrompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class _AlphabetQuizSheetState extends State<AlphabetQuizSheet> {
  late final List<_QuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedOption;
  int _score = 0;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions();
  }

  List<_QuizQuestion> _generateQuestions() {
    final list = <_QuizQuestion>[];
    final letters = List<HebrewLetter>.from(HebrewAlphabetSeedData.letters);
    final random = Random();
    letters.shuffle(random);

    // Q1: Match Hebrew letter to Russian name
    final q1Letter = letters[0];
    final otherOptions1 = letters
        .where((l) => l.id != q1Letter.id)
        .take(3)
        .map((l) => l.printed)
        .toList();
    final allOptions1 = [q1Letter.printed, ...otherOptions1]..shuffle(random);
    list.add(
      _QuizQuestion(
        questionText: 'Какая буква называется «${q1Letter.nameRussian}»?',
        options: allOptions1,
        correctIndex: allOptions1.indexOf(q1Letter.printed),
        explanation: 'Буква ${q1Letter.printed} — это ${q1Letter.nameRussian} (${q1Letter.nameHebrew}).',
      ),
    );

    // Q2: Dagesh rule question
    list.add(
      const _QuizQuestion(
        questionText: 'Как произносится буква בּ с точкой (дагешем)?',
        hebrewPrompt: 'בּ',
        options: ['Звук [Б]', 'Звук [В]', 'Звук [П]', 'Звук [Т]'],
        correctIndex: 0,
        explanation: 'Буква «Бет» с дагешем (בּ) звучит как [Б], а без дагеша (ב) — как [В].',
      ),
    );

    // Q3: Sofit question
    final sofitLetters = HebrewAlphabetSeedData.letters
        .where((l) => l.hasFinalForm)
        .toList();
    sofitLetters.shuffle(random);
    final q3Letter = sofitLetters.first;
    final otherSofits = HebrewAlphabetSeedData.letters
        .where((l) => l.hasFinalForm && l.id != q3Letter.id)
        .take(3)
        .map((l) => l.finalFormPrinted!)
        .toList();
    final allOptions3 = [q3Letter.finalFormPrinted!, ...otherSofits]
      ..shuffle(random);
    list.add(
      _QuizQuestion(
        questionText: 'Какая конечная форма (софит) у буквы «${q3Letter.printed}»?',
        hebrewPrompt: q3Letter.printed,
        options: allOptions3,
        correctIndex: allOptions3.indexOf(q3Letter.finalFormPrinted!),
        explanation: 'У буквы ${q3Letter.nameRussian} (${q3Letter.printed}) конечная форма — ${q3Letter.finalFormPrinted!}.',
      ),
    );

    // Q4: Gematria question
    final q4Letter = letters[1];
    final correctGematria = q4Letter.gematria.toString();
    final wrongGematrias = [
      (q4Letter.gematria * 2).toString(),
      (max(1, q4Letter.gematria - 1)).toString(),
      (q4Letter.gematria + 10).toString(),
    ];
    final allOptions4 = [correctGematria, ...wrongGematrias]..shuffle(random);
    list.add(
      _QuizQuestion(
        questionText: 'Какое числовое значение (гематрия) у буквы «${q4Letter.printed}» (${q4Letter.nameRussian})?',
        hebrewPrompt: q4Letter.printed,
        options: allOptions4,
        correctIndex: allOptions4.indexOf(correctGematria),
        explanation: 'Гематрия буквы ${q4Letter.printed} (${q4Letter.nameRussian}) равна ${q4Letter.gematria}.',
      ),
    );

    // Q5: Nikkud question
    list.add(
      const _QuizQuestion(
        questionText: 'Какая огласовка обозначает звук [О]?',
        options: ['Холам (וֹ / ◌ֹ)', 'Камац (◌ָ)', 'Сэголь (◌ֶ)', 'Хирик (◌ִ)'],
        correctIndex: 0,
        explanation: 'Холам (חוֹלָם) обозначает гласный звук [О].',
      ),
    );

    return list;
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Результат викторины 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_score из ${_questions.length}',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _score >= 4
                  ? 'Отличный результат! Ты уверенно ориентируешься в Алеф-Бете!'
                  : 'Хорошая тренировка! Продолжай практиковаться!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Завершить'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _questions.clear();
                _questions.addAll(_generateQuestions());
                _currentIndex = 0;
                _selectedOption = null;
                _score = 0;
                _answered = false;
              });
            },
            child: const Text('Пройти снова'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final question = _questions[_currentIndex];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Викторина: Вопрос ${_currentIndex + 1} из ${_questions.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 18),
          Text(
            question.questionText,
            style: theme.textTheme.titleMedium,
          ),
          if (question.hebrewPrompt != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  question.hebrewPrompt!,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    height: 1.35,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...List.generate(question.options.length, (index) {
            final option = question.options[index];
            final isSelected = _selectedOption == index;
            final isCorrect = index == question.correctIndex;

            Color? tileColor;
            BorderSide borderSide = BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            );

            if (_answered) {
              if (isCorrect) {
                tileColor = colorScheme.primaryContainer;
                borderSide = BorderSide(color: colorScheme.primary, width: 2);
              } else if (isSelected) {
                tileColor = colorScheme.errorContainer;
                borderSide = BorderSide(color: colorScheme.error, width: 2);
              }
            }

            return Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10),
              child: InkWell(
                onTap: () => _selectOption(index),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsetsDirectional.all(14),
                  decoration: BoxDecoration(
                    color: tileColor ?? colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.fromBorderSide(borderSide),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          option,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          textDirection: option.length == 1
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                      ),
                      if (_answered && isCorrect)
                        Icon(Icons.check_circle_rounded,
                            color: colorScheme.primary),
                      if (_answered && isSelected && !isCorrect)
                        Icon(Icons.cancel_rounded, color: colorScheme.error),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_answered) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsetsDirectional.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.explanation,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _nextQuestion,
              child: Text(
                _currentIndex == _questions.length - 1
                    ? 'Посмотреть итог'
                    : 'Следующий вопрос',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
