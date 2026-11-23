import 'package:flutter/material.dart';

/// The 5 competitive league tiers in Nexus Hebrew.
enum SabraLeagueTier {
  bronze(
    id: 'bronze',
    titleHebrewWithNikkud: 'לִיגַת אֲרָד',
    titleRu: 'Бронзовая лига',
    badgeEmoji: '🥉',
    color: Color(0xFFCD7F32),
    minWeeklyXp: 0,
    promotionThresholdXp: 150,
  ),
  silver(
    id: 'silver',
    titleHebrewWithNikkud: 'לִיגַת כֶּסֶף',
    titleRu: 'Серебряная лига',
    badgeEmoji: '🥈',
    color: Color(0xFFA8A8A8),
    minWeeklyXp: 150,
    promotionThresholdXp: 350,
  ),
  gold(
    id: 'gold',
    titleHebrewWithNikkud: 'לִיגַת זָהָב',
    titleRu: 'Золотая лига',
    badgeEmoji: '🥇',
    color: Color(0xFFFFB300),
    minWeeklyXp: 350,
    promotionThresholdXp: 650,
  ),
  ruby(
    id: 'ruby',
    titleHebrewWithNikkud: 'לִיגַת רֻבִּין',
    titleRu: 'Рубиновая лига',
    badgeEmoji: '💎',
    color: Color(0xFFE91E63),
    minWeeklyXp: 650,
    promotionThresholdXp: 1000,
  ),
  diamond(
    id: 'diamond',
    titleHebrewWithNikkud: 'לִיגַת יַהֲלוֹם',
    titleRu: 'Бриллиантовая лига',
    badgeEmoji: '👑',
    color: Color(0xFF00B0FF),
    minWeeklyXp: 1000,
    promotionThresholdXp: 2000,
  );

  final String id;
  final String titleHebrewWithNikkud;
  final String titleRu;
  final String badgeEmoji;
  final Color color;
  final int minWeeklyXp;
  final int promotionThresholdXp;

  const SabraLeagueTier({
    required this.id,
    required this.titleHebrewWithNikkud,
    required this.titleRu,
    required this.badgeEmoji,
    required this.color,
    required this.minWeeklyXp,
    required this.promotionThresholdXp,
  });

  static SabraLeagueTier fromId(String? id) {
    return SabraLeagueTier.values.firstWhere(
      (t) => t.id == id,
      orElse: () => SabraLeagueTier.bronze,
    );
  }

  SabraLeagueTier get nextTier {
    final idx = SabraLeagueTier.values.indexOf(this);
    if (idx + 1 < SabraLeagueTier.values.length) {
      return SabraLeagueTier.values[idx + 1];
    }
    return this;
  }
}

/// A competitor on the weekly leaderboard.
@immutable
class LeagueMember {
  final String id;
  final String nameRu;
  final String nameHebrew;
  final String avatarEmoji;
  final int weeklyXp;
  final bool isCurrentUser;
  final int rank;
  final int rankChange; // e.g. +2 climbed, 0 same, -1 dropped

  const LeagueMember({
    required this.id,
    required this.nameRu,
    required this.nameHebrew,
    required this.avatarEmoji,
    required this.weeklyXp,
    required this.isCurrentUser,
    required this.rank,
    this.rankChange = 0,
  });

  LeagueMember copyWith({
    String? id,
    String? nameRu,
    String? nameHebrew,
    String? avatarEmoji,
    int? weeklyXp,
    bool? isCurrentUser,
    int? rank,
    int? rankChange,
  }) {
    return LeagueMember(
      id: id ?? this.id,
      nameRu: nameRu ?? this.nameRu,
      nameHebrew: nameHebrew ?? this.nameHebrew,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      weeklyXp: weeklyXp ?? this.weeklyXp,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      rank: rank ?? this.rank,
      rankChange: rankChange ?? this.rankChange,
    );
  }
}

/// The state of the current week's league.
@immutable
class SabraLeagueState {
  final SabraLeagueTier tier;
  final int userWeeklyXp;
  final List<LeagueMember> leaderboard;
  final int daysRemainingInWeek;

  const SabraLeagueState({
    required this.tier,
    required this.userWeeklyXp,
    required this.leaderboard,
    this.daysRemainingInWeek = 4,
  });

  int get userRank {
    final userIdx = leaderboard.indexWhere((m) => m.isCurrentUser);
    return userIdx != -1 ? userIdx + 1 : leaderboard.length;
  }

  bool get isPromotionZone => userRank <= 3;
  bool get isDemotionZone =>
      tier != SabraLeagueTier.bronze && userRank >= 8 && leaderboard.length >= 8;

  int get xpToPromotion {
    if (leaderboard.length < 3) return 0;
    final thirdXp = leaderboard[2].weeklyXp;
    return (thirdXp - userWeeklyXp + 5).clamp(0, 9999);
  }
}
