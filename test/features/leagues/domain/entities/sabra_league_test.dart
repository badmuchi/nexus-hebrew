import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/leagues/domain/entities/sabra_league.dart';

void main() {
  group('SabraLeagueTier', () {
    test('fromId correctly resolves tiers and defaults to bronze', () {
      expect(SabraLeagueTier.fromId('bronze'), SabraLeagueTier.bronze);
      expect(SabraLeagueTier.fromId('silver'), SabraLeagueTier.silver);
      expect(SabraLeagueTier.fromId('gold'), SabraLeagueTier.gold);
      expect(SabraLeagueTier.fromId('ruby'), SabraLeagueTier.ruby);
      expect(SabraLeagueTier.fromId('diamond'), SabraLeagueTier.diamond);
      expect(SabraLeagueTier.fromId('unknown'), SabraLeagueTier.bronze);
      expect(SabraLeagueTier.fromId(null), SabraLeagueTier.bronze);
    });

    test('nextTier advances sequentially and caps at diamond', () {
      expect(SabraLeagueTier.bronze.nextTier, SabraLeagueTier.silver);
      expect(SabraLeagueTier.silver.nextTier, SabraLeagueTier.gold);
      expect(SabraLeagueTier.gold.nextTier, SabraLeagueTier.ruby);
      expect(SabraLeagueTier.ruby.nextTier, SabraLeagueTier.diamond);
      expect(SabraLeagueTier.diamond.nextTier, SabraLeagueTier.diamond);
    });
  });

  group('LeagueMember', () {
    test('copyWith updates properties correctly', () {
      const member = LeagueMember(
        id: 'user_1',
        nameRu: 'Ноа',
        nameHebrew: 'נוֹעָה',
        avatarEmoji: '👩‍🦰',
        weeklyXp: 120,
        isCurrentUser: false,
        rank: 3,
        rankChange: 0,
      );

      final updated = member.copyWith(weeklyXp: 180, rank: 2, rankChange: 1);
      expect(updated.weeklyXp, 180);
      expect(updated.rank, 2);
      expect(updated.rankChange, 1);
      expect(updated.nameRu, 'Ноа');
    });
  });

  group('SabraLeagueState', () {
    test('calculates userRank and promotion zone correctly', () {
      const members = [
        LeagueMember(
          id: 'p1',
          nameRu: 'Ноа',
          nameHebrew: 'נוֹעָה',
          avatarEmoji: '👩‍🦰',
          weeklyXp: 200,
          isCurrentUser: false,
          rank: 1,
        ),
        LeagueMember(
          id: 'me',
          nameRu: 'Вы',
          nameHebrew: 'אַתָּה',
          avatarEmoji: '🌵',
          weeklyXp: 150,
          isCurrentUser: true,
          rank: 2,
        ),
        LeagueMember(
          id: 'p2',
          nameRu: 'Итай',
          nameHebrew: 'אִיתַי',
          avatarEmoji: '👨‍💻',
          weeklyXp: 100,
          isCurrentUser: false,
          rank: 3,
        ),
      ];

      const state = SabraLeagueState(
        tier: SabraLeagueTier.silver,
        userWeeklyXp: 150,
        leaderboard: members,
        daysRemainingInWeek: 3,
      );

      expect(state.userRank, 2);
      expect(state.isPromotionZone, isTrue);
      expect(state.isDemotionZone, isFalse);
    });

    test('Bronze tier never has demotion zone', () {
      final members = List.generate(
        10,
        (i) => LeagueMember(
          id: 'id_$i',
          nameRu: 'User $i',
          nameHebrew: 'משתמש',
          avatarEmoji: '👤',
          weeklyXp: 100 - i * 10,
          isCurrentUser: i == 9,
          rank: i + 1,
        ),
      );

      final bronzeState = SabraLeagueState(
        tier: SabraLeagueTier.bronze,
        userWeeklyXp: 10,
        leaderboard: members,
      );

      expect(bronzeState.userRank, 10);
      expect(bronzeState.isDemotionZone, isFalse);

      final silverState = SabraLeagueState(
        tier: SabraLeagueTier.silver,
        userWeeklyXp: 10,
        leaderboard: members,
      );
      expect(silverState.isDemotionZone, isTrue);
    });
  });
}
