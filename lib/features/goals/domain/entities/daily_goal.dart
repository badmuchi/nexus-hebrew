import 'package:flutter/foundation.dart';

/// Predefined daily goal intensity levels.
enum DailyGoalIntensity {
  casual(
    id: 'casual',
    titleRu: 'Лёгкий',
    titleHebrewWithNikkud: 'קַל',
    targetMinutes: 5,
    targetCards: 10,
    targetQuests: 1,
    descriptionRu: '5 минут в день — быстрый старт без перегрузки',
  ),
  regular(
    id: 'regular',
    titleRu: 'Оптимальный',
    titleHebrewWithNikkud: 'רָגִיל',
    targetMinutes: 15,
    targetCards: 20,
    targetQuests: 2,
    descriptionRu: '15 минут в день — рекомендуемый темп для устойчивого прогресса',
  ),
  serious(
    id: 'serious',
    titleRu: 'Интенсивный',
    titleHebrewWithNikkud: 'רְצִינִי',
    targetMinutes: 30,
    targetCards: 35,
    targetQuests: 3,
    descriptionRu: '30 минут в день — глубокое погружение в грамматику и диалоги',
  ),
  ulpanHero(
    id: 'ulpanHero',
    titleRu: 'Ульпан Герой',
    titleHebrewWithNikkud: 'גִּבּוֹר אֻלְפָּן',
    targetMinutes: 45,
    targetCards: 50,
    targetQuests: 3,
    descriptionRu: '45 минут в день — максимальный прогресс к уровню Гимель/Далет',
  );

  final String id;
  final String titleRu;
  final String titleHebrewWithNikkud;
  final int targetMinutes;
  final int targetCards;
  final int targetQuests;
  final String descriptionRu;

  const DailyGoalIntensity({
    required this.id,
    required this.titleRu,
    required this.titleHebrewWithNikkud,
    required this.targetMinutes,
    required this.targetCards,
    required this.targetQuests,
    required this.descriptionRu,
  });

  static DailyGoalIntensity fromId(String? id) {
    return DailyGoalIntensity.values.firstWhere(
      (e) => e.id == id,
      orElse: () => DailyGoalIntensity.regular,
    );
  }
}

/// Represents the learner's daily activity rings and habit progress.
@immutable
class DailyGoalProgress {
  final String dateKey; // YYYY-MM-DD
  final DailyGoalIntensity intensity;
  final int cardsReviewed;
  final int practiceMinutes;
  final int questsCompleted;
  final int streakDays;
  final DateTime lastUpdated;

  const DailyGoalProgress({
    required this.dateKey,
    this.intensity = DailyGoalIntensity.regular,
    this.cardsReviewed = 0,
    this.practiceMinutes = 0,
    this.questsCompleted = 0,
    this.streakDays = 0,
    required this.lastUpdated,
  });

  int get targetCards => intensity.targetCards;
  int get targetMinutes => intensity.targetMinutes;
  int get targetQuests => intensity.targetQuests;

  /// Progress ratio clamped between 0.0 and 1.0
  double get cardsProgress =>
      targetCards > 0 ? (cardsReviewed / targetCards).clamp(0.0, 1.0) : 0.0;

  double get minutesProgress =>
      targetMinutes > 0 ? (practiceMinutes / targetMinutes).clamp(0.0, 1.0) : 0.0;

  double get questsProgress =>
      targetQuests > 0 ? (questsCompleted / targetQuests).clamp(0.0, 1.0) : 0.0;

  /// Whether each ring is closed
  bool get isCardsRingClosed => cardsReviewed >= targetCards;
  bool get isMinutesRingClosed => practiceMinutes >= targetMinutes;
  bool get isQuestsRingClosed => questsCompleted >= targetQuests;

  /// Number of completed activity rings (0 to 3)
  int get closedRingsCount {
    int count = 0;
    if (isCardsRingClosed) count++;
    if (isMinutesRingClosed) count++;
    if (isQuestsRingClosed) count++;
    return count;
  }

  /// Overall completion percentage (0 - 100)
  int get overallPercent {
    final avg = (cardsProgress + minutesProgress + questsProgress) / 3.0;
    return (avg * 100).round();
  }

  /// True when all 3 daily rings are completed
  bool get isAllGoalsMet =>
      isCardsRingClosed && isMinutesRingClosed && isQuestsRingClosed;

  DailyGoalProgress copyWith({
    String? dateKey,
    DailyGoalIntensity? intensity,
    int? cardsReviewed,
    int? practiceMinutes,
    int? questsCompleted,
    int? streakDays,
    DateTime? lastUpdated,
  }) {
    return DailyGoalProgress(
      dateKey: dateKey ?? this.dateKey,
      intensity: intensity ?? this.intensity,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      practiceMinutes: practiceMinutes ?? this.practiceMinutes,
      questsCompleted: questsCompleted ?? this.questsCompleted,
      streakDays: streakDays ?? this.streakDays,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'intensity': intensity.id,
      'cardsReviewed': cardsReviewed,
      'practiceMinutes': practiceMinutes,
      'questsCompleted': questsCompleted,
      'streakDays': streakDays,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory DailyGoalProgress.fromJson(Map<String, dynamic> json) {
    return DailyGoalProgress(
      dateKey: json['dateKey'] as String? ?? '',
      intensity: DailyGoalIntensity.fromId(json['intensity'] as String?),
      cardsReviewed: json['cardsReviewed'] as int? ?? 0,
      practiceMinutes: json['practiceMinutes'] as int? ?? 0,
      questsCompleted: json['questsCompleted'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyGoalProgress &&
        other.dateKey == dateKey &&
        other.intensity == intensity &&
        other.cardsReviewed == cardsReviewed &&
        other.practiceMinutes == practiceMinutes &&
        other.questsCompleted == questsCompleted &&
        other.streakDays == streakDays;
  }

  @override
  int get hashCode => Object.hash(
        dateKey,
        intensity,
        cardsReviewed,
        practiceMinutes,
        questsCompleted,
        streakDays,
      );
}
