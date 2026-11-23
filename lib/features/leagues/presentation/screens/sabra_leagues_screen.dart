import 'package:flutter/material.dart';

import '../../domain/entities/sabra_league.dart';
import '../../domain/services/sabra_league_service.dart';
import '../widgets/league_member_tile.dart';
import '../widgets/league_tier_header.dart';

/// Screen displaying the weekly Sabra competitive league leaderboard,
/// tier progression, and XP earning actions.
class SabraLeaguesScreen extends StatefulWidget {
  final SabraLeagueService? service;

  const SabraLeaguesScreen({
    super.key,
    this.service,
  });

  @override
  State<SabraLeaguesScreen> createState() => _SabraLeaguesScreenState();
}

class _SabraLeaguesScreenState extends State<SabraLeaguesScreen> {
  late final SabraLeagueService _service;
  SabraLeagueState? _state;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SabraLeagueService();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await _service.loadLeagueState();
    if (mounted) {
      setState(() {
        _state = state;
        _isLoading = false;
      });
    }
  }

  Future<void> _earnXp(int points, String sourceName) async {
    final updated = await _service.recordXp(points);
    if (!mounted) return;

    setState(() {
      _state = updated;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+$points XP за $sourceName! Вы на #${updated.userRank} месте.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _claimPromotion() async {
    final promoted = await _service.advanceToNextTier();
    if (!mounted) return;

    setState(() {
      _state = promoted;
    });

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Text('🎉', style: TextStyle(fontSize: 48)),
        title: const Text(
          'כָּל הַכָּבוֹד! עָלִיתָ לִיגָה!',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: TextStyle(height: 1.5, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Поздравляем! Ты перешел в «${promoted.tier.titleRu}» (${promoted.tier.badgeEmoji})!\n'
          'Продолжай практиковать иврит каждый день, чтобы войти в Бриллиантовую элиту!',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('К победам! (לְנִצָּחוֹן)'),
          ),
        ],
      ),
    );
  }

  void _showRulesSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'חֻקֵּי לִיגַת הַסַּבְּרָה',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Правила еженедельных соревнований',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(height: 32),

            _buildRuleItem(
              emoji: '📅',
              title: 'Недельный цикл (מחזור שבועי)',
              description:
                  'Каждая лига длится 7 дней — с утра воскресенья (יום ראשון) по вечер субботы (מוצאי שבת).',
            ),
            _buildRuleItem(
              emoji: '⬆️',
              title: 'Топ-3: Зона повышения (עליה)',
              description:
                  'Участники, занявшие 1-е, 2-е и 3-е места в таблице, автоматически переходят в следующую лигу.',
            ),
            _buildRuleItem(
              emoji: '⬇️',
              title: '8-10 места: Зона понижения (ירידה)',
              description:
                  'Участники на нижних позициях опускаются на одну лигу назад (за исключением начальной Бронзовой лиги).',
            ),
            _buildRuleItem(
              emoji: '⚡',
              title: 'Как зарабатывать XP (נקודות)',
              description:
                  '• Карточка FSRS: +15 XP\n• Дневной квест Сабры: +30 XP\n• Аудио-диалог или сценарий: +50 XP\n• Пройденный тест Яэль: +100 XP',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Понятно (הֵבַנְתִּי)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem({
    required String emoji,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _state == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Лиги Сабры'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final state = _state!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лиги Сабры'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Правила лиги',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: _showRulesSheet,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Tier Header Banner
          SliverToBoxAdapter(
            child: LeagueTierHeader(
              state: state,
              onRulesTap: _showRulesSheet,
            ),
          ),

          // Quick XP practice buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Быстрый набор XP в лиге:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ActionChip(
                          avatar: const Text('🃏'),
                          label: const Text('+15 XP Карточки'),
                          onPressed: () => _earnXp(15, 'повторение карточек'),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Text('🌵'),
                          label: const Text('+30 XP Квест Сабры'),
                          onPressed: () => _earnXp(30, 'квест Сабры'),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Text('🎙️'),
                          label: const Text('+50 XP Диалог'),
                          onPressed: () => _earnXp(50, 'голосовой диалог'),
                        ),
                        if (state.isPromotionZone &&
                            state.tier != SabraLeagueTier.diamond) ...[
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Text('👑'),
                            backgroundColor: Colors.amber.withAlpha(50),
                            label: const Text(
                              'Перейти в лигу!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: _claimPromotion,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.leaderboard_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Еженедельная таблица лидеров',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Leaderboard list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final member = state.leaderboard[index];
                final showPromoDivider = member.rank == 3;
                final showDemoDivider =
                    member.rank == 7 && state.leaderboard.length >= 8;

                return LeagueMemberTile(
                  member: member,
                  showPromotionDivider: showPromoDivider,
                  showDemotionDivider: showDemoDivider,
                );
              },
              childCount: state.leaderboard.length,
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}
