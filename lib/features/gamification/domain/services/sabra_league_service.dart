import 'dart:math' as math;

import '../../../progress/domain/entities/learning_progress_summary.dart';
import '../../../srs/domain/entities/fsrs_analytics_data.dart';
import '../entities/sabra_league.dart';

/// Pure domain service calculating Sabra League rankings, weekly leaderboard,
/// and FSRS memory stability badges.
final class SabraLeagueService {
  const SabraLeagueService();

  static const List<Map<String, String>> _kCompetitorProfiles = [
    {
      'he': 'נוֹעָה',
      'ru': 'Ноа',
      'emoji': '👩‍💻',
      'city': 'Тель-Авив',
    },
    {
      'he': 'יוֹנָתָן',
      'ru': 'Йонатан',
      'emoji': '👨‍🎨',
      'city': 'Иерусалим',
    },
    {
      'he': 'מָאיָה',
      'ru': 'Майя',
      'emoji': '👩‍⚕️',
      'city': 'Хайфа',
    },
    {
      'he': 'אִיתַי',
      'ru': 'Итай',
      'emoji': '🧑‍🍳',
      'city': 'Герцлия',
    },
    {
      'he': 'שִׁירָה',
      'ru': 'Шира',
      'emoji': '👩‍🔬',
      'city': 'Беэр-Шева',
    },
    {
      'he': 'דָּנִיאֵל',
      'ru': 'Даниэль',
      'emoji': '🏄‍♂️',
      'city': 'Нетания',
    },
    {
      'he': 'עֲדִי',
      'ru': 'Ади',
      'emoji': '🧘‍♀️',
      'city': 'Рамат-Ган',
    },
    {
      'he': 'אֲרִיאֵל',
      'ru': 'Ариэль',
      'emoji': '🧑‍🏫',
      'city': 'Петах-Тиква',
    },
    {
      'he': 'תָּמָר',
      'ru': 'Тамар',
      'emoji': '🌱',
      'city': 'Эйлат',
    },
    {
      'he': 'עָמִית',
      'ru': 'Амит',
      'emoji': '🎧',
      'city': 'Ришон-ле-Цион',
    },
    {
      'he': 'גַּל',
      'ru': 'Галь',
      'emoji': '⛵',
      'city': 'Ашдод',
    },
    {
      'he': 'מִיכָאֵל',
      'ru': 'Михаэль',
      'emoji': '📸',
      'city': 'Тверия',
    },
  ];

  /// Resolves the league tier based on the user's weekly XP.
  static SabraLeagueTier resolveTier(int weeklyXp) {
    for (final tier in SabraLeagueTier.values.reversed) {
      if (weeklyXp >= tier.minXp) {
        return tier;
      }
    }
    return SabraLeagueTier.sabra;
  }

  /// Calculates the full league state, including weekly leaderboard rankings.
  static SabraLeagueStatus computeLeagueStatus({
    required int weeklyXp,
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final tier = resolveTier(weeklyXp);

    // Days until Sunday (end of Israeli learning week)
    // In Dart weekday: Mon=1, Sun=7.
    final daysRemaining = 7 - (now.weekday % 7);

    // Base XP offset around user's score to create dynamic competitive tension
    final competitors = <LeaderboardCompetitor>[];

    // Seed repeatable pseudo-random offsets based on calendar week
    final weekSeed = (now.year * 52) + ((now.month * 4) + (now.day ~/ 7));
    final rng = math.Random(weekSeed);

    for (var i = 0; i < _kCompetitorProfiles.length; i++) {
      final profile = _kCompetitorProfiles[i];
      // Generate XP within the current tier's boundaries
      final tierSpan = tier.maxXp - tier.minXp;
      final variance = (rng.nextDouble() * 0.8 + 0.1); // 10% to 90% of tier
      var score = (tier.minXp + (tierSpan * variance)).toInt();

      // Ensure some competitors are slightly ahead and some slightly behind
      if (i % 3 == 0 && weeklyXp > tier.minXp + 40) {
        score = weeklyXp + (10 + rng.nextInt(35));
      } else if (i % 3 == 1 && weeklyXp > tier.minXp + 30) {
        score = math.max(tier.minXp, weeklyXp - (10 + rng.nextInt(30)));
      }

      competitors.add(
        LeaderboardCompetitor(
          id: 'competitor_$i',
          nameHebrew: profile['he']!,
          nameRussian: profile['ru']!,
          avatarEmoji: profile['emoji']!,
          city: profile['city']!,
          weeklyXp: score,
          isCurrentUser: false,
          rank: 0,
        ),
      );
    }

    // Add current user
    competitors.add(
      LeaderboardCompetitor(
        id: 'current_user',
        nameHebrew: 'אַתָּה (Ты)',
        nameRussian: 'Вы',
        avatarEmoji: '⭐',
        city: 'Израиль',
        weeklyXp: weeklyXp,
        isCurrentUser: true,
        rank: 0,
      ),
    );

    // Sort descending by XP
    competitors.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));

    // Assign final ranks
    var userRank = 1;
    final rankedList = <LeaderboardCompetitor>[];
    for (var rank = 1; rank <= competitors.length; rank++) {
      final c = competitors[rank - 1];
      final ranked = LeaderboardCompetitor(
        id: c.id,
        nameHebrew: c.nameHebrew,
        nameRussian: c.nameRussian,
        avatarEmoji: c.avatarEmoji,
        city: c.city,
        weeklyXp: c.weeklyXp,
        isCurrentUser: c.isCurrentUser,
        rank: rank,
      );
      rankedList.add(ranked);
      if (c.isCurrentUser) {
        userRank = rank;
      }
    }

    return SabraLeagueStatus(
      tier: tier,
      weeklyXp: weeklyXp,
      userRank: userRank,
      totalParticipants: rankedList.length,
      daysRemainingInWeek: daysRemaining,
      leaderboard: rankedList,
    );
  }

  /// Evaluates memory stability badges based on progress and FSRS analytics.
  static List<MemoryStabilityBadge> evaluateMemoryBadges({
    required LearningProgressSummary summary,
  }) {
    final analytics = summary.fsrsAnalytics;
    final totalCards = summary.totalSrsCards;
    final currentRetention = analytics?.currentRetentionRate ?? 0.90;
    final permanentCount =
        analytics?.cardsByStabilityTier[FsrsStabilityTier.permanent] ?? 0;
    final totalReviews = summary.totalSrsReviews;
    final streak = summary.currentStreakDays;

    return [
      MemoryStabilityBadge(
        id: 'iron_memory',
        titleRu: 'Железная память',
        titleHebrew: 'זִכָּרוֹן בַּרְזֶל',
        descriptionRu: 'Удерживай 90%+ запоминания в колоде при 10+ словах',
        iconEmoji: '🛡️',
        isUnlocked: totalCards >= 10 && currentRetention >= 0.89,
        progressText: totalCards < 10
            ? '$totalCards / 10 карт.'
            : '${(currentRetention * 100).toStringAsFixed(0)}% / 90%',
        progressFraction: totalCards < 10
            ? (totalCards / 10).clamp(0.0, 1.0)
            : (currentRetention / 0.90).clamp(0.0, 1.0),
      ),
      MemoryStabilityBadge(
        id: 'permanent_vault',
        titleRu: 'Перманентный запас',
        titleHebrew: 'אוֹצָר קָבוּעַ',
        descriptionRu: 'Закрепи 5+ слов со стабильностью памяти S ≥ 90 дней',
        iconEmoji: '🏛️',
        isUnlocked: permanentCount >= 5,
        progressText: '$permanentCount / 5 слов',
        progressFraction: (permanentCount / 5.0).clamp(0.0, 1.0),
      ),
      MemoryStabilityBadge(
        id: 'srs_streak',
        titleRu: 'Покоритель плато',
        titleHebrew: 'הַתְמָדָה שְׁבוּעִית',
        descriptionRu: 'Занимайся ивритом каждый день 7 дней подряд',
        iconEmoji: '🚀',
        isUnlocked: streak >= 7,
        progressText: '$streak / 7 дней',
        progressFraction: (streak / 7.0).clamp(0.0, 1.0),
      ),
      MemoryStabilityBadge(
        id: 'review_master',
        titleRu: 'Мастер повторений',
        titleHebrew: 'מֻמְחֶה חֲזָרוֹת',
        descriptionRu: 'Выполни 50+ интервальных повторений карточек FSRS',
        iconEmoji: '🔄',
        isUnlocked: totalReviews >= 50,
        progressText: '$totalReviews / 50 ревью',
        progressFraction: (totalReviews / 50.0).clamp(0.0, 1.0),
      ),
      MemoryStabilityBadge(
        id: 'sabra_lexicon',
        titleRu: 'Словарь Сабры',
        titleHebrew: 'מִלּוֹן צַבָּר',
        descriptionRu: 'Собери 30+ карточек в личной FSRS колоде',
        iconEmoji: '🇮🇱',
        isUnlocked: totalCards >= 30,
        progressText: '$totalCards / 30 карт.',
        progressFraction: (totalCards / 30.0).clamp(0.0, 1.0),
      ),
    ];
  }
}
