import 'package:equatable/equatable.dart';

/// Colors of sidewalk curbs (שפת מדרכה) in Israel.
enum CurbColorType {
  blueWhite(
    id: 'blue_white',
    titleRu: 'Сине-белый (כחול-לבן)',
    descriptionRu: 'Платная парковка (Pango / Cello), бесплатная для жителей с наклейкой',
    hebrewTitle: 'כָּחֹל-לָבָן',
  ),
  redWhite(
    id: 'red_white',
    titleRu: 'Красно-белый (אדום-לבן)',
    descriptionRu: 'Парковка и остановка строго запрещены. Штраф или эвакуатор!',
    hebrewTitle: 'אָדֹם-לָבָן',
  ),
  redYellow(
    id: 'red_yellow',
    titleRu: 'Красно-желтый (אדום-צהוב)',
    descriptionRu: 'Остановка общественного транспорта, такси или зона разгрузки',
    hebrewTitle: 'אָדֹם-צָהֹב',
  ),
  gray(
    id: 'gray',
    titleRu: 'Серый (אפור)',
    descriptionRu: 'Бесплатная парковка без ограничений по времени',
    hebrewTitle: 'אָפֹר',
  );

  final String id;
  final String titleRu;
  final String descriptionRu;
  final String hebrewTitle;

  const CurbColorType({
    required this.id,
    required this.titleRu,
    required this.descriptionRu,
    required this.hebrewTitle,
  });
}

/// A specific Israeli parking situation with curb color and municipal sign rules.
final class ParkingCurbCase extends Equatable {
  final String id;
  final CurbColorType curbType;
  final String titleRu;
  final String streetNameRu;
  final String streetNameHebrewWithNikkud;
  final String signTextHebrew;
  final String signTextRu;
  final String questionRu;
  final bool isParkingAllowed;
  final String? fineAmountTextRu;
  final String explanationRu;
  final String sabraDriverTipRu;

  const ParkingCurbCase({
    required this.id,
    required this.curbType,
    required this.titleRu,
    required this.streetNameRu,
    required this.streetNameHebrewWithNikkud,
    required this.signTextHebrew,
    required this.signTextRu,
    required this.questionRu,
    required this.isParkingAllowed,
    this.fineAmountTextRu,
    required this.explanationRu,
    required this.sabraDriverTipRu,
  });

  @override
  List<Object?> get props => [
        id,
        curbType,
        titleRu,
        streetNameRu,
        streetNameHebrewWithNikkud,
        signTextHebrew,
        signTextRu,
        questionRu,
        isParkingAllowed,
        fineAmountTextRu,
        explanationRu,
        sabraDriverTipRu,
      ];
}
