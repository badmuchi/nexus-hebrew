import 'package:equatable/equatable.dart';

/// Key Israeli mortgage (Машканта) tracks and their terms.
final class MortgageTrackInfo extends Equatable {
  final String id;
  final String titleRu;
  final String titleHebrewWithNikkud;
  final String abbreviationHebrew;
  final String interestTypeRu;
  final String riskProfileRu;
  final String prosRu;
  final String consRu;
  final String insiderRecommendationRu;

  const MortgageTrackInfo({
    required this.id,
    required this.titleRu,
    required this.titleHebrewWithNikkud,
    required this.abbreviationHebrew,
    required this.interestTypeRu,
    required this.riskProfileRu,
    required this.prosRu,
    required this.consRu,
    required this.insiderRecommendationRu,
  });

  @override
  List<Object?> get props => [
        id,
        titleRu,
        titleHebrewWithNikkud,
        abbreviationHebrew,
        interestTypeRu,
        riskProfileRu,
        prosRu,
        consRu,
        insiderRecommendationRu,
      ];
}
