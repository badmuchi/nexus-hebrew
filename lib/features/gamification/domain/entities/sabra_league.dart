import 'package:equatable/equatable.dart';

/// The 5 prestigious authentic Israeli Sabra League tiers.
enum SabraLeagueTier {
  sabra(
    id: 'sabra',
    nameHebrew: 'לִיגַת צַבָּר',
    nameRussian: 'Лига Сабры',
    emoji: '🌵',
    minXp: 0,
    maxXp: 300,
    colorHex: 0xFF4CAF50, // Fresh green
    descriptionRussian: 'Первые шаги в иврите — колючий и упорный старт!',
  ),
  jaffaOrange(
    id: 'jaffa_orange',
    nameHebrew: 'לִיגַת תַּפּוּז יָפוֹ',
    nameRussian: 'Яффская апельсиновая лига',
    emoji: '🍊',
    minXp: 300,
    maxXp: 800,
    colorHex: 0xFFFF9800, // Vibrant orange
    descriptionRussian: 'Сочный прогресс на улочках старого Яффо и набережной.',
  ),
  galileeOlive(
    id: 'galilee_olive',
    nameHebrew: 'לִיגַת זַיִת גְּלִילִי',
    nameRussian: 'Галилейская оливковая лига',
    emoji: '🌿',
    minXp: 800,
    maxXp: 1600,
    colorHex: 0xFF558B2F, // Olive green
    descriptionRussian: 'Древняя мудрость, крепкие корни слов и уверенность.',
  ),
  carmelGrape(
    id: 'carmel_grape',
    nameHebrew: 'לִיגַת גֶּפֶן הַכַּרְמֶל',
    nameRussian: 'Кармельская виноградная лига',
    emoji: '🍇',
    minXp: 1600,
    maxXp: 3000,
    colorHex: 0xFF7E57C2, // Purple
    descriptionRussian: 'Богатый словарный запас и естественная беглость речи.',
  ),
  jerusalemDate(
    id: 'jerusalem_date',
    nameHebrew: 'לִיגַת תָּמָר יְרוּשַׁלְמִי',
    nameRussian: 'Золотая Иерусалимская лига',
    emoji: '🌴',
    minXp: 3000,
    maxXp: 10000,
    colorHex: 0xFFFFB300, // Golden amber
    descriptionRussian: 'Высшая лига мастеров иврита — уровень настоящего Сабры!',
  );

  final String id;
  final String nameHebrew;
  final String nameRussian;
  final String emoji;
  final int minXp;
  final int maxXp;
  final int colorHex;
  final String descriptionRussian;

  const SabraLeagueTier({
    required this.id,
    required this.nameHebrew,
    required this.nameRussian,
    required this.emoji,
    required this.minXp,
    required this.maxXp,
    required this.colorHex,
    required this.descriptionRussian,
  });
}

/// Competitor in the weekly league leaderboard.
final class LeaderboardCompetitor extends Equatable {
  final String id;
  final String nameHebrew;
  final String nameRussian;
  final String avatarEmoji;
  final String city;
  final int weeklyXp;
  final bool isCurrentUser;
  final int rank;

  const LeaderboardCompetitor({
    required this.id,
    required this.nameHebrew,
    required this.nameRussian,
    required this.avatarEmoji,
    required this.city,
    required this.weeklyXp,
    this.isCurrentUser = false,
    required this.rank,
  });

  @override
  List<Object?> get props => [
        id,
        nameHebrew,
        nameRussian,
        avatarEmoji,
        city,
        weeklyXp,
        isCurrentUser,
        rank,
      ];
}

/// Information about user's current league status and weekly progress.
final class SabraLeagueStatus extends Equatable {
  final SabraLeagueTier tier;
  final int weeklyXp;
  final int userRank;
  final int totalParticipants;
  final int daysRemainingInWeek;
  final List<LeaderboardCompetitor> leaderboard;

  const SabraLeagueStatus({
    required this.tier,
    required this.weeklyXp,
    required this.userRank,
    required this.totalParticipants,
    required this.daysRemainingInWeek,
    required this.leaderboard,
  });

  double get progressToNextTier {
    if (weeklyXp >= tier.maxXp) return 1.0;
    if (weeklyXp <= tier.minXp) return 0.0;
    final span = tier.maxXp - tier.minXp;
    return (weeklyXp - tier.minXp) / span;
  }

  int get xpToNextTier {
    if (weeklyXp >= tier.maxXp) return 0;
    return tier.maxXp - weeklyXp;
  }

  bool get isTopThree => userRank <= 3;
  bool get isInPromotionZone => userRank <= 5;

  @override
  List<Object?> get props => [
        tier,
        weeklyXp,
        userRank,
        totalParticipants,
        daysRemainingInWeek,
        leaderboard,
      ];
}

/// Specialized FSRS Memory Stability Badges.
final class MemoryStabilityBadge extends Equatable {
  final String id;
  final String titleRu;
  final String titleHebrew;
  final String descriptionRu;
  final String iconEmoji;
  final bool isUnlocked;
  final String progressText;
  final double progressFraction;

  const MemoryStabilityBadge({
    required this.id,
    required this.titleRu,
    required this.titleHebrew,
    required this.descriptionRu,
    required this.iconEmoji,
    required this.isUnlocked,
    required this.progressText,
    required this.progressFraction,
  });

  @override
  List<Object?> get props => [
        id,
        titleRu,
        titleHebrew,
        descriptionRu,
        iconEmoji,
        isUnlocked,
        progressText,
        progressFraction,
      ];
}
