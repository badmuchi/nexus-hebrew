import 'package:equatable/equatable.dart';

/// Common abbreviations used in Israeli real estate ads (Yad2, Facebook, Madlan).
final class Yad2Abbreviation extends Equatable {
  final String id;
  final String abbreviationHebrew;
  final String fullHebrewWithNikkud;
  final String transcriptionRu;
  final String translationRu;
  final String significanceRu;

  const Yad2Abbreviation({
    required this.id,
    required this.abbreviationHebrew,
    required this.fullHebrewWithNikkud,
    required this.transcriptionRu,
    required this.translationRu,
    required this.significanceRu,
  });

  @override
  List<Object?> get props => [
        id,
        abbreviationHebrew,
        fullHebrewWithNikkud,
        transcriptionRu,
        translationRu,
        significanceRu,
      ];
}

/// A real-life Israeli apartment rental listing.
final class ApartmentListing extends Equatable {
  final String id;
  final String cityRu;
  final String neighborhoodRu;
  final String neighborhoodHebrewWithNikkud;
  final double roomsCount; // e.g. 2.5, 3.0
  final int squareMeters;
  final int priceMonthlyShekels;
  final int floor;
  final bool hasElevator;
  final bool hasMamad; // Protected residential secure space
  final bool hasBalcony;
  final bool hasDudShemesh; // Solar water heater
  final bool hasParking;
  final String rawAdTextHebrew;
  final List<Yad2Abbreviation> abbreviationsUsed;
  final String hiddenTrapWarningRu;

  const ApartmentListing({
    required this.id,
    required this.cityRu,
    required this.neighborhoodRu,
    required this.neighborhoodHebrewWithNikkud,
    required this.roomsCount,
    required this.squareMeters,
    required this.priceMonthlyShekels,
    required this.floor,
    required this.hasElevator,
    required this.hasMamad,
    required this.hasBalcony,
    required this.hasDudShemesh,
    required this.hasParking,
    required this.rawAdTextHebrew,
    required this.abbreviationsUsed,
    required this.hiddenTrapWarningRu,
  });

  @override
  List<Object?> get props => [
        id,
        cityRu,
        neighborhoodRu,
        neighborhoodHebrewWithNikkud,
        roomsCount,
        squareMeters,
        priceMonthlyShekels,
        floor,
        hasElevator,
        hasMamad,
        hasBalcony,
        hasDudShemesh,
        hasParking,
        rawAdTextHebrew,
        abbreviationsUsed,
        hiddenTrapWarningRu,
      ];
}
