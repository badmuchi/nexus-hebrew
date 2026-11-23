import 'dart:convert';

import '../entities/sabra_league.dart';

/// Storage interface for persisting Sabra League weekly competition state.
abstract interface class SabraLeagueStorage {
  Future<String?> readLeagueJson();
  Future<void> writeLeagueJson(String json);
}

/// In-memory storage implementation for tests or fallback.
class InMemorySabraLeagueStorage implements SabraLeagueStorage {
  String? _data;

  InMemorySabraLeagueStorage([this._data]);

  @override
  Future<String?> readLeagueJson() async => _data;

  @override
  Future<void> writeLeagueJson(String json) async {
    _data = json;
  }
}

/// Predefined peers who compete in the Sabra Leagues.
class LeaguePeerTemplate {
  final String id;
  final String nameRu;
  final String nameHebrew;
  final String avatarEmoji;
  final double baseWeight; // 0.1 to 1.5

  const LeaguePeerTemplate({
    required this.id,
    required this.nameRu,
    required this.nameHebrew,
    required this.avatarEmoji,
    required this.baseWeight,
  });
}

/// Service managing the Sabra Leagues competition lifecycle, XP tracking,
/// leaderboards, and tier promotions.
class SabraLeagueService {
  final SabraLeagueStorage? _storage;
  SabraLeagueState? _cachedState;

  SabraLeagueService({SabraLeagueStorage? storage}) : _storage = storage;

  static const List<LeaguePeerTemplate> defaultPeerTemplates = [
    LeaguePeerTemplate(
      id: 'peer_1',
      nameRu: 'Ноа Коэн',
      nameHebrew: 'נוֹעָה כֹּהֵן',
      avatarEmoji: '👩‍🦰',
      baseWeight: 1.35,
    ),
    LeaguePeerTemplate(
      id: 'peer_2',
      nameRu: 'Итай Леви',
      nameHebrew: 'אִיתַי לֵוִי',
      avatarEmoji: '👨‍💻',
      baseWeight: 1.15,
    ),
    LeaguePeerTemplate(
      id: 'peer_3',
      nameRu: 'Шира Перец',
      nameHebrew: 'שִׁירָה פֶּרֶץ',
      avatarEmoji: '👩‍🎓',
      baseWeight: 0.95,
    ),
    LeaguePeerTemplate(
      id: 'peer_4',
      nameRu: 'Йоси Мизрахи',
      nameHebrew: 'יוֹסִי מִזְרָחִי',
      avatarEmoji: '🧗‍♂️',
      baseWeight: 0.85,
    ),
    LeaguePeerTemplate(
      id: 'peer_5',
      nameRu: 'Майя Битон',
      nameHebrew: 'מַאיָה בֵּיטוֹן',
      avatarEmoji: '👩‍🔬',
      baseWeight: 0.75,
    ),
    LeaguePeerTemplate(
      id: 'peer_6',
      nameRu: 'Даниэль Авраам',
      nameHebrew: 'דָּנִיאֵל אַבְרָהָם',
      avatarEmoji: '👨‍🎨',
      baseWeight: 0.65,
    ),
    LeaguePeerTemplate(
      id: 'peer_7',
      nameRu: 'Таль Шапира',
      nameHebrew: 'טַל שָׁפִירָא',
      avatarEmoji: '👨‍🏫',
      baseWeight: 0.50,
    ),
    LeaguePeerTemplate(
      id: 'peer_8',
      nameRu: 'Тамар Фридман',
      nameHebrew: 'תָּמָר פְרִידְמָן',
      avatarEmoji: '👩‍💼',
      baseWeight: 0.40,
    ),
    LeaguePeerTemplate(
      id: 'peer_9',
      nameRu: 'Ронен Гольдберг',
      nameHebrew: 'רוֹנֵן גּוֹלְדְבֶּרְג',
      avatarEmoji: '🚴',
      baseWeight: 0.30,
    ),
    LeaguePeerTemplate(
      id: 'peer_10',
      nameRu: 'Лиор Шемеш',
      nameHebrew: 'לִיאוֹר שֶׁמֶשׁ',
      avatarEmoji: '🏄‍♂️',
      baseWeight: 0.20,
    ),
  ];

  /// Calculates the week identifier (e.g. "2026-W47").
  static String calculateWeekKey(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final diffDays = date.difference(startOfYear).inDays;
    final weekNum = (diffDays / 7).floor() + 1;
    return '${date.year}-W$weekNum';
  }

  /// Calculates remaining days in the Israeli week (Sunday to Shabbat).
  static int daysRemainingInWeek(DateTime date) {
    // In Dart: 1 is Mon, 6 is Sat, 7 is Sun
    // Israel week: Sun (day 0) to Sat (day 6)
    final dayOfIsraelWeek = date.weekday % 7; // 0 for Sun, 1 for Mon, ..., 6 for Sat
    return (6 - dayOfIsraelWeek).clamp(0, 6);
  }

  /// Generates the leaderboard cohort for a specific tier and user XP.
  static List<LeagueMember> generateCohort({
    required SabraLeagueTier tier,
    required int userXp,
    int? previousUserRank,
  }) {
    final tierMultiplier = switch (tier) {
      SabraLeagueTier.bronze => 100,
      SabraLeagueTier.silver => 250,
      SabraLeagueTier.gold => 500,
      SabraLeagueTier.ruby => 850,
      SabraLeagueTier.diamond => 1500,
    };

    final members = <LeagueMember>[];

    for (final template in defaultPeerTemplates) {
      final peerXp = (template.baseWeight * tierMultiplier).round();
      members.add(
        LeagueMember(
          id: template.id,
          nameRu: template.nameRu,
          nameHebrew: template.nameHebrew,
          avatarEmoji: template.avatarEmoji,
          weeklyXp: peerXp,
          isCurrentUser: false,
          rank: 0,
        ),
      );
    }

    // Add current user
    members.add(
      LeagueMember(
        id: 'current_user',
        nameRu: 'Вы (Сабра)',
        nameHebrew: 'אַתָּה (סַבְּרָה)',
        avatarEmoji: '🌵',
        weeklyXp: userXp,
        isCurrentUser: true,
        rank: 0,
      ),
    );

    // Sort descending by XP, ties favor current user
    members.sort((a, b) {
      final xpComp = b.weeklyXp.compareTo(a.weeklyXp);
      if (xpComp != 0) return xpComp;
      if (a.isCurrentUser) return -1;
      if (b.isCurrentUser) return 1;
      return a.id.compareTo(b.id);
    });

    final rankedMembers = <LeagueMember>[];
    for (int i = 0; i < members.length; i++) {
      final m = members[i];
      final currentRank = i + 1;
      int rankChange = 0;
      if (m.isCurrentUser && previousUserRank != null) {
        rankChange = previousUserRank - currentRank; // positive means moved up!
      }
      rankedMembers.add(m.copyWith(rank: currentRank, rankChange: rankChange));
    }

    return rankedMembers;
  }

  /// Loads current league state from storage or creates initial Bronze tier state.
  Future<SabraLeagueState> loadLeagueState({DateTime? now}) async {
    final currentMoment = now ?? DateTime.now();
    final currentWeek = calculateWeekKey(currentMoment);
    final daysLeft = daysRemainingInWeek(currentMoment);

    if (_cachedState != null) {
      return _cachedState!;
    }

    final rawJson = await _storage?.readLeagueJson();
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        final savedWeek = map['weekKey'] as String?;
        final savedTierId = map['tierId'] as String?;
        final savedXp = (map['userWeeklyXp'] as num?)?.toInt() ?? 0;
        final savedTier = SabraLeagueTier.fromId(savedTierId);

        if (savedWeek == currentWeek) {
          final cohort = generateCohort(
            tier: savedTier,
            userXp: savedXp,
          );
          final state = SabraLeagueState(
            tier: savedTier,
            userWeeklyXp: savedXp,
            leaderboard: cohort,
            daysRemainingInWeek: daysLeft,
          );
          _cachedState = state;
          return state;
        } else {
          // New week started! Check if previous week qualified for promotion
          final nextTier = (savedXp >= savedTier.promotionThresholdXp)
              ? savedTier.nextTier
              : savedTier;
          final freshCohort = generateCohort(
            tier: nextTier,
            userXp: 0,
          );
          final state = SabraLeagueState(
            tier: nextTier,
            userWeeklyXp: 0,
            leaderboard: freshCohort,
            daysRemainingInWeek: daysLeft,
          );
          _cachedState = state;
          await _persistState(state, currentWeek);
          return state;
        }
      } catch (_) {
        // Fallback to default on parse error
      }
    }

    // Default initial bronze state
    final defaultCohort = generateCohort(
      tier: SabraLeagueTier.bronze,
      userXp: 45,
    );
    final initialState = SabraLeagueState(
      tier: SabraLeagueTier.bronze,
      userWeeklyXp: 45,
      leaderboard: defaultCohort,
      daysRemainingInWeek: daysLeft,
    );
    _cachedState = initialState;
    await _persistState(initialState, currentWeek);
    return initialState;
  }

  /// Records newly earned XP, updates leaderboard rankings, and persists.
  Future<SabraLeagueState> recordXp(int pointsEarned, {DateTime? now}) async {
    final currentMoment = now ?? DateTime.now();
    final current = await loadLeagueState(now: currentMoment);
    final previousRank = current.userRank;
    final updatedXp = current.userWeeklyXp + pointsEarned;

    final updatedLeaderboard = generateCohort(
      tier: current.tier,
      userXp: updatedXp,
      previousUserRank: previousRank,
    );

    final newState = SabraLeagueState(
      tier: current.tier,
      userWeeklyXp: updatedXp,
      leaderboard: updatedLeaderboard,
      daysRemainingInWeek: daysRemainingInWeek(currentMoment),
    );

    _cachedState = newState;
    await _persistState(newState, calculateWeekKey(currentMoment));
    return newState;
  }

  /// Promotes the user to the next league tier immediately (e.g. on victory/claim).
  Future<SabraLeagueState> advanceToNextTier({DateTime? now}) async {
    final currentMoment = now ?? DateTime.now();
    final current = await loadLeagueState(now: currentMoment);
    final nextTier = current.tier.nextTier;

    final updatedLeaderboard = generateCohort(
      tier: nextTier,
      userXp: current.userWeeklyXp,
    );

    final newState = SabraLeagueState(
      tier: nextTier,
      userWeeklyXp: current.userWeeklyXp,
      leaderboard: updatedLeaderboard,
      daysRemainingInWeek: daysRemainingInWeek(currentMoment),
    );

    _cachedState = newState;
    await _persistState(newState, calculateWeekKey(currentMoment));
    return newState;
  }

  Future<void> _persistState(SabraLeagueState state, String weekKey) async {
    if (_storage == null) return;
    final map = {
      'weekKey': weekKey,
      'tierId': state.tier.id,
      'userWeeklyXp': state.userWeeklyXp,
    };
    await _storage.writeLeagueJson(jsonEncode(map));
  }
}
