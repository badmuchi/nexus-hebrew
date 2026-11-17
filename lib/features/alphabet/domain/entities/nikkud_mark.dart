import 'package:equatable/equatable.dart';

/// Phonetic groups of Hebrew vowel marks (Nikkud).
enum NikkudVowelGroup {
  a('Звук [А]', 'Традиционно обозначается камацем или патахом'),
  e('Звук [Э]', 'Цейре, сэголь или хатаф-сэголь'),
  i('Звук [И]', 'Хирик (с буквой йод или без)'),
  o('Звук [О]', 'Холам хасер, холам мале или хатаф-камац'),
  u('Звук [У]', 'Кубуц или шурук с буквой вав'),
  sheva('Шва (разделитель / [Э])', 'Служит разделителем слогов (нах) или кратким звуком (на)'),
  dagesh('Дагеш / Точка', 'Усиливает согласный (בּ, כּ, פּ) или указывает на удвоение');

  final String title;
  final String description;

  const NikkudVowelGroup(this.title, this.description);
}

/// Domain entity representing a Hebrew diacritical mark (Nikkud).
class NikkudMark extends Equatable {
  final String id;
  final String nameHebrew;
  final String nameRussian;
  final String symbol; // Diacritic glyph with dotted circle base (e.g. ◌ָ)
  final String exampleWithLetter; // E.g. בָּ
  final String sound; // E.g. [А]
  final String description;
  final NikkudVowelGroup group;
  final String exampleWordHebrew;
  final String exampleWordRussian;
  final String exampleWordTranscription;

  const NikkudMark({
    required this.id,
    required this.nameHebrew,
    required this.nameRussian,
    required this.symbol,
    required this.exampleWithLetter,
    required this.sound,
    required this.description,
    required this.group,
    required this.exampleWordHebrew,
    required this.exampleWordRussian,
    required this.exampleWordTranscription,
  });

  @override
  List<Object?> get props => [
        id,
        nameHebrew,
        nameRussian,
        symbol,
        exampleWithLetter,
        sound,
        description,
        group,
        exampleWordHebrew,
        exampleWordRussian,
        exampleWordTranscription,
      ];
}
