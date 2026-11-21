import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/srs_card.dart';
import '../../domain/services/match_pairs_engine.dart';

/// Fast-paced 60-second vocabulary memory matching game.
class MatchPairsScreen extends StatefulWidget {
  final List<SrsCard> cards;
  final AudioPlaybackService? audioService;
  final ValueChanged<int>? onXpEarned;

  const MatchPairsScreen({
    super.key,
    required this.cards,
    this.audioService,
    this.onXpEarned,
  });

  @override
  State<MatchPairsScreen> createState() => _MatchPairsScreenState();
}

class _MatchPairsScreenState extends State<MatchPairsScreen> {
  static const int _initialTimerSeconds = 60;
  final MatchPairsEngine _engine = MatchPairsEngine();

  List<MatchPairTile> _tiles = [];
  int _totalPairs = 0;
  final Set<String> _matchedPairIds = {};
  MatchPairTile? _selectedFirstTile;
  final Set<String> _wrongTileIds = {};

  Timer? _timer;
  int _secondsLeft = _initialTimerSeconds;
  int _score = 0;
  int _combo = 1;
  int _mistakes = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _timer?.cancel();
    final tiles = _engine.generateTiles(widget.cards, pairCount: 6);
    setState(() {
      _tiles = tiles;
      _totalPairs = tiles.length ~/ 2;
      _matchedPairIds.clear();
      _selectedFirstTile = null;
      _wrongTileIds.clear();
      _secondsLeft = _initialTimerSeconds;
      _score = 0;
      _combo = 1;
      _mistakes = 0;
      _isGameOver = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _onTimeExpired();
      } else {
        setState(() {
          _secondsLeft -= 1;
        });
      }
    });
  }

  void _onTimeExpired() {
    setState(() {
      _secondsLeft = 0;
      _isGameOver = true;
    });
    _showFinishDialog(isVictory: false);
  }

  Future<void> _playTileHebrew(MatchPairTile tile) async {
    if (!tile.isHebrew) return;
    try {
      await widget.audioService?.playWithTtsFallback(
        sourcePath: tile.audioUrl,
        fallbackHebrewText: tile.text,
      );
    } catch (_) {}
  }

  void _onTileTapped(MatchPairTile tile) {
    if (_isGameOver) return;
    if (_matchedPairIds.contains(tile.pairId)) return;
    if (_wrongTileIds.isNotEmpty) return; // Wait for mismatch animation

    if (_selectedFirstTile == null) {
      setState(() {
        _selectedFirstTile = tile;
      });
      _playTileHebrew(tile);
      return;
    }

    if (_selectedFirstTile!.id == tile.id) {
      setState(() {
        _selectedFirstTile = null;
      });
      return;
    }

    final first = _selectedFirstTile!;
    final second = tile;

    if (first.pairId == second.pairId) {
      // MATCH!
      _playTileHebrew(first.isHebrew ? first : second);
      setState(() {
        _matchedPairIds.add(first.pairId);
        _score += 150 * _combo;
        _combo = (_combo + 1).clamp(1, 5);
        _selectedFirstTile = null;
      });

      if (_matchedPairIds.length == _totalPairs) {
        _timer?.cancel();
        setState(() {
          _isGameOver = true;
          _score += _secondsLeft * 20; // Time bonus
        });
        _showFinishDialog(isVictory: true);
      }
    } else {
      // MISMATCH!
      setState(() {
        _mistakes += 1;
        _combo = 1;
        _wrongTileIds.addAll([first.id, second.id]);
        _selectedFirstTile = null;
      });

      Future<void>.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        setState(() {
          _wrongTileIds.clear();
        });
      });
    }
  }

  void _showFinishDialog({required bool isVictory}) {
    final xp = _engine.calculateEarnedXp(
      matchedCount: _matchedPairIds.length,
      totalPairs: _totalPairs,
      remainingSeconds: _secondsLeft,
      mistakes: _mistakes,
    );

    widget.onXpEarned?.call(xp);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Text(isVictory ? '🎉 Победа!' : '⏰ Время вышло!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isVictory
                    ? 'Все пары найдены за ${_initialTimerSeconds - _secondsLeft} сек!'
                    : 'Собрано пар: ${_matchedPairIds.length} из $_totalPairs',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      'Очки: $_score',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '+$xp XP начислено в прогресс!',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Завершить'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _startNewGame();
              },
              child: const Text('Сыграть снова'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Быстрые пары 🃏'),
        actions: [
          IconButton(
            tooltip: 'Перезапустить раунд',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _secondsLeft <= 10
                          ? theme.colorScheme.errorContainer
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: _secondsLeft <= 10
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_secondsLeftс',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _secondsLeft <= 10
                                ? theme.colorScheme.onErrorContainer
                                : theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_combo > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade700),
                      ),
                      child: Text(
                        'x$_combo 🔥',
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '$_score очков',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Cards Grid
            Expanded(
              child: _tiles.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth > 500 ? 4 : 3;
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.35,
                            ),
                            itemCount: _tiles.length,
                            itemBuilder: (context, index) {
                              final tile = _tiles[index];
                              final isMatched =
                                  _matchedPairIds.contains(tile.pairId);
                              final isSelected =
                                  _selectedFirstTile?.id == tile.id;
                              final isWrong = _wrongTileIds.contains(tile.id);

                              return _MatchTileWidget(
                                tile: tile,
                                isMatched: isMatched,
                                isSelected: isSelected,
                                isWrong: isWrong,
                                onTap: () => _onTileTapped(tile),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchTileWidget extends StatelessWidget {
  final MatchPairTile tile;
  final bool isMatched;
  final bool isSelected;
  final bool isWrong;
  final VoidCallback onTap;

  const _MatchTileWidget({
    required this.tile,
    required this.isMatched,
    required this.isSelected,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor = theme.colorScheme.surfaceContainerLow;
    Color borderColor = theme.colorScheme.outlineVariant;
    Color textColor = theme.colorScheme.onSurface;

    if (isMatched) {
      bgColor = Colors.green.withValues(alpha: 0.15);
      borderColor = Colors.green.shade400;
      textColor = Colors.green.shade900;
    } else if (isWrong) {
      bgColor = theme.colorScheme.errorContainer.withValues(alpha: 0.4);
      borderColor = theme.colorScheme.error;
      textColor = theme.colorScheme.error;
    } else if (isSelected) {
      bgColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
      borderColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.primary;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isMatched ? 0.4 : 1.0,
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: isSelected ? 2.0 : 1.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isMatched ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Center(
              child: Text(
                tile.text,
                textDirection:
                    tile.isHebrew ? TextDirection.rtl : TextDirection.ltr,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: tile.isHebrew ? 16 : 13,
                  height: tile.isHebrew ? 1.4 : 1.2,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
