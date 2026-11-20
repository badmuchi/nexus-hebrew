import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// CEFR proficiency level targeted by the assessment question.
enum CefrLevel {
  a1(label: 'A1', labelRu: 'Начальный (Алеф)', labelHe: 'רָמָה א׳'),
  a2(label: 'A2', labelRu: 'Базовый (Бет)', labelHe: 'רָמָה ב׳'),
  b1(label: 'B1', labelRu: 'Средний (Гимель)', labelHe: 'רָמָה ג׳');

  final String label;
  final String labelRu;
  final String labelHe;

  const CefrLevel({
    required this.label,
    required this.labelRu,
    required this.labelHe,
  });
}

/// Linguistic skill focus tested by the diagnostic question.
enum SkillFocus {
  vocabulary(
    labelRu: 'Словарь и лексика',
    labelHe: 'אוֹצַר מִלִּים',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF1E88E5),
  ),
  grammar(
    labelRu: 'Грамматика и Биньяны',
    labelHe: 'דִּקְדּוּק וּבִנְיָנִים',
    icon: Icons.account_tree_rounded,
    color: Color(0xFF00897B),
  ),
  syntax(
    labelRu: 'Синтаксис и предлоги',
    labelHe: 'מִבְנֶה וּמִלּוֹת יַחַס',
    icon: Icons.view_quilt_rounded,
    color: Color(0xFFF57C00),
  ),
  listening(
    labelRu: 'Аудирование и речь',
    labelHe: 'הַאֲזָנָה וְהִגּוּי',
    icon: Icons.headphones_rounded,
    color: Color(0xFFD81B60),
  );

  final String labelRu;
  final String labelHe;
  final IconData icon;
  final Color color;

  const SkillFocus({
    required this.labelRu,
    required this.labelHe,
    required this.icon,
    required this.color,
  });
}

/// A diagnostic multiple-choice question in the Hebrew level assessment test.
final class LevelQuizQuestion extends Equatable {
  final String id;
  final String promptRussian;
  final String? promptHebrew;
  final String? audioPath;
  final List<String> options;
  final int correctOptionIndex;
  final String explanationRu;
  final CefrLevel level;
  final SkillFocus skillFocus;
  final String? keyWord;
  final String? keyWordRussian;

  const LevelQuizQuestion({
    required this.id,
    required this.promptRussian,
    this.promptHebrew,
    this.audioPath,
    required this.options,
    required this.correctOptionIndex,
    required this.explanationRu,
    required this.level,
    required this.skillFocus,
    this.keyWord,
    this.keyWordRussian,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctOptionIndex;

  String get correctOption => options[correctOptionIndex];

  @override
  List<Object?> get props => [
        id,
        promptRussian,
        promptHebrew,
        audioPath,
        options,
        correctOptionIndex,
        explanationRu,
        level,
        skillFocus,
        keyWord,
        keyWordRussian,
      ];
}
