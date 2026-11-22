import 'package:equatable/equatable.dart';

/// The 3 daily quest archetypes for authentic Israeli Hebrew practice.
enum SabraQuestType {
  conversational(
    id: 'conversational',
    titleHebrew: 'צַבָּר בְּשִׂיחָה',
    titleRussian: 'Сабра в диалоге',
    descriptionRussian: 'Пройди 1 диалог или аудиотренировку',
    iconEmoji: '💬',
    defaultTarget: 1,
    defaultXp: 50,
  ),
  ironMemory(
    id: 'iron_memory',
    titleHebrew: 'זִכָּרוֹן שֶׁל בַּרְזֶל',
    titleRussian: 'Железная память',
    descriptionRussian: 'Повтори 10 карточек FSRS',
    iconEmoji: '🧠',
    defaultTarget: 10,
    defaultXp: 40,
  ),
  shoreshHunter(
    id: 'shoresh_hunter',
    titleHebrew: 'צַיָּד שָׁרָשִׁים',
    titleRussian: 'Охотник за корнями',
    descriptionRussian: 'Разбери 1 корень или глагол в биньянах',
    iconEmoji: '🔍',
    defaultTarget: 1,
    defaultXp: 30,
  );

  final String id;
  final String titleHebrew;
  final String titleRussian;
  final String descriptionRussian;
  final String iconEmoji;
  final int defaultTarget;
  final int defaultXp;

  const SabraQuestType({
    required this.id,
    required this.titleHebrew,
    required this.titleRussian,
    required this.descriptionRussian,
    required this.iconEmoji,
    required this.defaultTarget,
    required this.defaultXp,
  });

  static SabraQuestType fromId(String id) {
    return SabraQuestType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => SabraQuestType.conversational,
    );
  }
}

/// An individual daily Sabra quest with progress, target, and XP rewards.
final class SabraQuest extends Equatable {
  final String id;
  final SabraQuestType type;
  final int targetCount;
  final int currentCount;
  final int xpReward;
  final bool isClaimed;

  const SabraQuest({
    required this.id,
    required this.type,
    required this.targetCount,
    this.currentCount = 0,
    required this.xpReward,
    this.isClaimed = false,
  });

  bool get isCompleted => currentCount >= targetCount;
  double get progress => targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;
  bool get canClaim => isCompleted && !isClaimed;

  SabraQuest copyWith({
    String? id,
    SabraQuestType? type,
    int? targetCount,
    int? currentCount,
    int? xpReward,
    bool? isClaimed,
  }) {
    return SabraQuest(
      id: id ?? this.id,
      type: type ?? this.type,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      xpReward: xpReward ?? this.xpReward,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.id,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'xpReward': xpReward,
        'isClaimed': isClaimed,
      };

  factory SabraQuest.fromJson(Map<String, dynamic> json) {
    final type = SabraQuestType.fromId(json['type'] as String? ?? 'conversational');
    return SabraQuest(
      id: json['id'] as String? ?? type.id,
      type: type,
      targetCount: json['targetCount'] as int? ?? type.defaultTarget,
      currentCount: json['currentCount'] as int? ?? 0,
      xpReward: json['xpReward'] as int? ?? type.defaultXp,
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, type, targetCount, currentCount, xpReward, isClaimed];
}

/// Dynamic Sabra Cactus stages evolving as daily streaks grow.
enum SabraStreakStage {
  sprout(
    id: 'sprout',
    titleHebrew: 'נֶבֶט צַבָּר',
    titleRussian: 'Росток сабры',
    emoji: '🌱',
    minDays: 0,
    maxDays: 2,
    description: 'Колючки еще мягкие, но корни уже крепнут!',
  ),
  youngCactus(
    id: 'young_cactus',
    titleHebrew: 'צַבָּר צָעִיר',
    titleRussian: 'Колючий сабра',
    emoji: '🌵',
    minDays: 3,
    maxDays: 6,
    description: 'Настоящий израильский характер — ни дня без иврита!',
  ),
  flowering(
    id: 'flowering',
    titleHebrew: 'צַבָּר פּוֹרֵחַ',
    titleRussian: 'Цветущий сабра',
    emoji: '🌸',
    minDays: 7,
    maxDays: 13,
    description: 'Недельный страйк! Цветет яркими желтыми цветами в пустыне.',
  ),
  fruitSabra(
    id: 'fruit_sabra',
    titleHebrew: 'צַבָּר עִם פֵּרוֹת',
    titleRussian: 'Спелый цабар',
    emoji: '🥭',
    minDays: 14,
    maxDays: 99999,
    description: 'Снаружи колючий, внутри сладкий — эталонный сабра!',
  );

  final String id;
  final String titleHebrew;
  final String titleRussian;
  final String emoji;
  final int minDays;
  final int maxDays;
  final String description;

  const SabraStreakStage({
    required this.id,
    required this.titleHebrew,
    required this.titleRussian,
    required this.emoji,
    required this.minDays,
    required this.maxDays,
    required this.description,
  });

  static SabraStreakStage fromDays(int days) {
    if (days >= 14) return SabraStreakStage.fruitSabra;
    if (days >= 7) return SabraStreakStage.flowering;
    if (days >= 3) return SabraStreakStage.youngCactus;
    return SabraStreakStage.sprout;
  }
}

/// Consolidated state of the learner's daily quests, chest, and streak.
final class SabraDailyQuestsState extends Equatable {
  final String dateKey; // Format: 'YYYY-MM-DD'
  final List<SabraQuest> quests;
  final int streakDays;
  final int chestRewardXp;
  final bool isChestClaimed;

  const SabraDailyQuestsState({
    required this.dateKey,
    required this.quests,
    this.streakDays = 0,
    this.chestRewardXp = 100,
    this.isChestClaimed = false,
  });

  SabraStreakStage get streakStage => SabraStreakStage.fromDays(streakDays);

  bool get allQuestsCompleted => quests.isNotEmpty && quests.every((q) => q.isCompleted);
  bool get canClaimChest => allQuestsCompleted && !isChestClaimed;
  int get completedCount => quests.where((q) => q.isCompleted).length;
  int get claimedCount => quests.where((q) => q.isClaimed).length;
  double get totalProgress => quests.isEmpty ? 0.0 : (completedCount / quests.length);

  SabraDailyQuestsState copyWith({
    String? dateKey,
    List<SabraQuest>? quests,
    int? streakDays,
    int? chestRewardXp,
    bool? isChestClaimed,
  }) {
    return SabraDailyQuestsState(
      dateKey: dateKey ?? this.dateKey,
      quests: quests ?? this.quests,
      streakDays: streakDays ?? this.streakDays,
      chestRewardXp: chestRewardXp ?? this.chestRewardXp,
      isChestClaimed: isChestClaimed ?? this.isChestClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'quests': quests.map((q) => q.toJson()).toList(),
        'streakDays': streakDays,
        'chestRewardXp': chestRewardXp,
        'isChestClaimed': isChestClaimed,
      };

  factory SabraDailyQuestsState.fromJson(Map<String, dynamic> json) {
    final rawQuests = json['quests'] as List<dynamic>? ?? [];
    return SabraDailyQuestsState(
      dateKey: json['dateKey'] as String? ?? '',
      quests: rawQuests
          .map((item) => SabraQuest.fromJson(item as Map<String, dynamic>))
          .toList(),
      streakDays: json['streakDays'] as int? ?? 0,
      chestRewardXp: json['chestRewardXp'] as int? ?? 100,
      isChestClaimed: json['isChestClaimed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [dateKey, quests, streakDays, chestRewardXp, isChestClaimed];
}
