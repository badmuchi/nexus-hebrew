import 'package:equatable/equatable.dart';

/// Shabbat timeline stages from Friday preparations to Saturday evening Havdalah.
final class ShabbatRule extends Equatable {
  final String id;
  final String titleRu;
  final String hebrewTitleWithNikkud;
  final String transcriptionRu;
  final String timeWindowRu;
  final String descriptionRu;
  final String transportAndShopsRu;
  final String etiquetteTipRu;
  final String iconEmoji;

  const ShabbatRule({
    required this.id,
    required this.titleRu,
    required this.hebrewTitleWithNikkud,
    required this.transcriptionRu,
    required this.timeWindowRu,
    required this.descriptionRu,
    required this.transportAndShopsRu,
    required this.etiquetteTipRu,
    required this.iconEmoji,
  });

  @override
  List<Object?> get props => [
        id,
        titleRu,
        hebrewTitleWithNikkud,
        transcriptionRu,
        timeWindowRu,
        descriptionRu,
        transportAndShopsRu,
        etiquetteTipRu,
        iconEmoji,
      ];
}
