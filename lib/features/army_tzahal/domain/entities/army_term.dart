import 'package:flutter/foundation.dart';

/// Categories for military, draft, and national civil service concepts.
enum ArmyCategory {
  slang(
    id: 'slang',
    titleHebrew: 'סְלֶנְג צְבָאִי',
    titleRu: 'Армейский сленг',
    iconEmoji: '🪖',
  ),
  tsavRishon(
    id: 'tsavRishon',
    titleHebrew: 'צַו רִאשׁוֹן וּמִיּוּן',
    titleRu: 'Цав Ришон и отбор',
    iconEmoji: '📋',
  ),
  ranks(
    id: 'ranks',
    titleHebrew: 'דַּרְגּוֹת וּמִבְנֶה',
    titleRu: 'Звания и командный состав',
    iconEmoji: '🎖️',
  ),
  sherutLeumi(
    id: 'sherutLeumi',
    titleHebrew: 'שֵׁרוּת לְאֻמִּי',
    titleRu: 'Шерут Леуми (гражданская служба)',
    iconEmoji: '🕊️',
  );

  final String id;
  final String titleHebrew;
  final String titleRu;
  final String iconEmoji;

  const ArmyCategory({
    required this.id,
    required this.titleHebrew,
    required this.titleRu,
    required this.iconEmoji,
  });
}

/// A military/service vocabulary item with cultural context and abbreviation breakdown.
@immutable
class ArmyTerm {
  final String id;
  final String hebrewWithNikkud;
  final String hebrewNormalized;
  final String? abbreviationExpansionHebrew;
  final String transcriptionRu;
  final String meaningRu;
  final String culturalContextRu;
  final String exampleHebrewWithNikkud;
  final String exampleRu;
  final ArmyCategory category;

  const ArmyTerm({
    required this.id,
    required this.hebrewWithNikkud,
    required this.hebrewNormalized,
    this.abbreviationExpansionHebrew,
    required this.transcriptionRu,
    required this.meaningRu,
    required this.culturalContextRu,
    required this.exampleHebrewWithNikkud,
    required this.exampleRu,
    required this.category,
  });
}

/// A simulated interview question during Tsav Rishon (the initial IDF draft evaluation).
@immutable
class TsavRishonScenario {
  final String id;
  final String stageTitleRu;
  final String interviewerRoleRu;
  final String interviewerSpeechHebrewWithNikkud;
  final String interviewerSpeechRu;
  final List<String> optionsHebrew;
  final List<String> optionsRu;
  final int bestOptionIndex;
  final String explanationRu;
  final String insiderTipRu;

  const TsavRishonScenario({
    required this.id,
    required this.stageTitleRu,
    required this.interviewerRoleRu,
    required this.interviewerSpeechHebrewWithNikkud,
    required this.interviewerSpeechRu,
    required this.optionsHebrew,
    required this.optionsRu,
    required this.bestOptionIndex,
    required this.explanationRu,
    required this.insiderTipRu,
  });
}
