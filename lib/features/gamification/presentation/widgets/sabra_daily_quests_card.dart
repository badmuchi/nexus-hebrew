import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/hebrew_normalizer.dart';
import '../../domain/entities/sabra_quest.dart';
import '../../domain/services/sabra_quest_service.dart';

/// Interactive Material 3 card presenting the 3 daily Sabra practice quests,
/// streak cactus evolution stage, and daily bonus chest.
class SabraDailyQuestsCard extends StatefulWidget {
  final SabraDailyQuestsState? initialState;
  final SabraQuestService? questService;
  final int streakDays;
  final ValueChanged<int>? onXpClaimed;
  final VoidCallback? onNavigateToDialogue;
  final VoidCallback? onNavigateToSrs;
  final VoidCallback? onNavigateToShoresh;
  final bool showNikkud;

  const SabraDailyQuestsCard({
    super.key,
    this.initialState,
    this.questService,
    this.streakDays = 0,
    this.onXpClaimed,
    this.onNavigateToDialogue,
    this.onNavigateToSrs,
    this.onNavigateToShoresh,
    this.showNikkud = true,
  });

  @override
  State<SabraDailyQuestsCard> createState() => _SabraDailyQuestsCardState();
}

class _SabraDailyQuestsCardState extends State<SabraDailyQuestsCard> {
  late SabraDailyQuestsState _state;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState ??
        SabraQuestService.generateDefaultQuests(
          date: DateTime.now(),
          streakDays: widget.streakDays,
        );
    _initOrSync();
  }

  @override
  void didUpdateWidget(covariant SabraDailyQuestsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialState != null && widget.initialState != _state) {
      setState(() => _state = widget.initialState!);
    } else if (widget.streakDays != oldWidget.streakDays) {
      setState(() => _state = _state.copyWith(streakDays: widget.streakDays));
    }
  }

  Future<void> _initOrSync() async {
    final service = widget.questService;
    if (service != null && widget.initialState == null) {
      final loaded = await service.loadOrCreateToday(
        currentStreak: widget.streakDays,
      );
      if (mounted) {
        setState(() {
          _state = loaded;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _claimQuest(SabraQuest quest) async {
    if (!quest.canClaim) return;
    unawaited(HapticFeedback.mediumImpact());

    final (updated, earnedXp) = SabraQuestService.claimQuest(
      current: _state,
      questId: quest.id,
    );

    setState(() => _state = updated);
    widget.onXpClaimed?.call(earnedXp);

    if (widget.questService != null) {
      await widget.questService!.saveState(updated);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 +$earnedXp XP за квест "${quest.type.titleRussian}"!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _claimChest() async {
    if (!_state.canClaimChest) return;
    unawaited(HapticFeedback.heavyImpact());

    final (updated, earnedXp) = SabraQuestService.claimChest(current: _state);

    setState(() => _state = updated);
    widget.onXpClaimed?.call(earnedXp);

    if (widget.questService != null) {
      await widget.questService!.saveState(updated);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🏆 СУНДУК САБРЫ ОТКРЫТ! +$earnedXp XP получено!'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _onQuestTap(SabraQuest quest) {
    if (quest.canClaim) {
      _claimQuest(quest);
      return;
    }
    switch (quest.type) {
      case SabraQuestType.conversational:
        widget.onNavigateToDialogue?.call();
      case SabraQuestType.ironMemory:
        widget.onNavigateToSrs?.call();
      case SabraQuestType.shoreshHunter:
        widget.onNavigateToShoresh?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final stage = _state.streakStage;
    final allDone = _state.allQuestsCompleted;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: allDone
              ? const Color(0xFF4CAF50).withValues(alpha: 0.6)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: allDone ? 1.5 : 1.0,
        ),
      ),
      color: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: isDark ? 0.35 : 0.25,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Avatar, Title, Streak Pill
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(stage.emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Text(
                            'Квесты Сабры',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              widget.showNikkud
                                  ? 'מְשִׂימוֹת צַבָּר'
                                  : HebrewNormalizer.stripNikkud('מְשִׂימוֹת צַבָּר'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stage.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '${_state.streakDays} дн.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Quests List
            for (final quest in _state.quests) ...[
              _buildQuestRow(context, quest, theme),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 4),

            // Sabra Chest Banner
            _buildChestBanner(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestRow(BuildContext context, SabraQuest quest, ThemeData theme) {
    final isDone = quest.isCompleted;
    final isClaimed = quest.isClaimed;
    final canClaim = quest.canClaim;

    return InkWell(
      onTap: () => _onQuestTap(quest),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsetsDirectional.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: canClaim
                ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: canClaim ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(quest.type.iconEmoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          quest.type.titleRussian,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          quest.type.titleHebrew,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quest.type.descriptionRussian,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: quest.progress,
                            minHeight: 5,
                            backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDone ? const Color(0xFF4CAF50) : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${quest.currentCount}/${quest.targetCount}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDone ? const Color(0xFF2E7D32) : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (canClaim)
              FilledButton(
                onPressed: () => _claimQuest(quest),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  '+${quest.xpReward} XP',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              )
            else if (isClaimed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF2E7D32)),
                    SizedBox(width: 4),
                    Text(
                      'Забрано',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${quest.xpReward} XP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChestBanner(BuildContext context, ThemeData theme) {
    final canClaim = _state.canClaimChest;
    final isClaimed = _state.isChestClaimed;

    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: canClaim
              ? [const Color(0xFFFFB300).withValues(alpha: 0.25), const Color(0xFFFF8F00).withValues(alpha: 0.15)]
              : [theme.colorScheme.surface, theme.colorScheme.surface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canClaim
              ? const Color(0xFFFFB300)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: canClaim ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(isClaimed ? '✨' : '🎁', style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      'Сундук Сабры',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '+100 XP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF57F17),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isClaimed
                      ? 'Бонус дня забран! Отличная работа!'
                      : 'Выполнено ${_state.completedCount}/3 квестов дня',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (canClaim)
            ElevatedButton(
              onPressed: _claimChest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.black87,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Открыть! 🎁',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            )
          else if (isClaimed)
            const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 24)
          else
            Icon(Icons.lock_outline_rounded, color: theme.colorScheme.outline, size: 22),
        ],
      ),
    );
  }
}
