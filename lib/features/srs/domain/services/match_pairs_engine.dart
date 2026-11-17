import 'dart:math';

import 'package:equatable/equatable.dart';

import '../entities/srs_card.dart';

final class MatchPairTile extends Equatable {
  const MatchPairTile({
    required this.id,
    required this.pairId,
    required this.text,
    required this.isHebrew,
    this.audioUrl,
  });

  final String id;
  final String pairId;
  final String text;
  final bool isHebrew;
  final String? audioUrl;

  @override
  List<Object?> get props => [id, pairId, text, isHebrew, audioUrl];
}

final class MatchPairsEngine {
  final Random _random;

  MatchPairsEngine({Random? random}) : _random = random ?? Random();

  /// Generates a randomized list of tiles (6 pairs = 12 tiles) from cards or dictionary entries.
  List<MatchPairTile> generateTiles(List<SrsCard> cards, {int pairCount = 6}) {
    if (cards.isEmpty) return const [];

    final availableCards = List<SrsCard>.from(cards)..shuffle(_random);
    final chosenCards = availableCards.take(pairCount).toList();

    final tiles = <MatchPairTile>[];
    for (final card in chosenCards) {
      tiles.add(
        MatchPairTile(
          id: '${card.id}_he',
          pairId: card.id,
          text: card.hebrew.vocalized,
          isHebrew: true,
          audioUrl: card.audioUrl,
        ),
      );
      tiles.add(
        MatchPairTile(
          id: '${card.id}_ru',
          pairId: card.id,
          text: card.russianTranslation,
          isHebrew: false,
        ),
      );
    }

    tiles.shuffle(_random);
    return tiles;
  }

  /// Calculates XP earned based on matches, mistakes, and remaining time.
  int calculateEarnedXp({
    required int matchedCount,
    required int totalPairs,
    required int remainingSeconds,
    required int mistakes,
  }) {
    if (matchedCount == 0) return 0;
    var xp = (matchedCount / totalPairs * 20).round();
    if (matchedCount == totalPairs) {
      xp += 10; // Completion bonus
      if (mistakes == 0) {
        xp += 5; // Flawless bonus
      }
      if (remainingSeconds > 20) {
        xp += 5; // Speed bonus
      }
    }
    return xp.clamp(5, 40);
  }
}
