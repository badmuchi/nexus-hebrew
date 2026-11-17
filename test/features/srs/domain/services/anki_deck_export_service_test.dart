import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/services/anki_deck_export_service.dart';

void main() {
  const service = AnkiDeckExportService();

  final testCard = SrsCard(
    id: 'card-1',
    hebrew: const HebrewText.fixture(
      vocalized: 'שָׁלוֹם',
      normalized: 'שלום',
    ),
    russianTranslation: 'Привет, мир',
    root: const Shoresh.fixture(['ש', 'ל', 'מ']),
    binyan: Binyan.paal,
    audioUrl: 'assets/audio/srs/shalom.mp3',
    memory: FsrsMemoryState.initial(now: DateTime.utc(2026, 1, 1)),
    attribution: const ContentAttribution(
      sourceName: 'Seed',
      licenseName: 'CC-BY',
    ),
  );

  final testEntry = DictionaryEntry(
    id: 'dict-1',
    hebrew: const HebrewText.fixture(
      vocalized: 'תּוֹדָה',
      normalized: 'תודה',
    ),
    russianTranslation: 'Спасибо; благодарность',
    transliteration: 'toda',
    category: LexicalCategory.noun,
    binyan: Binyan.none,
    audioUrl: 'assets/audio/dict/toda.mp3',
    frequencyRank: 10,
    createdAt: DateTime.utc(2025, 1, 1),
    attribution: const ContentAttribution(
      sourceName: 'Seed',
      licenseName: 'CC-BY',
    ),
  );

  group('AnkiDeckExportService', () {
    test('экспортирует карточки SRS в формат Anki TSV с мета-заголовками', () {
      final tsv = service.exportSrsCards([testCard], format: AnkiExportFormat.tsv);

      expect(tsv, contains('#separator:tab'));
      expect(tsv, contains('#html:true'));
      expect(tsv, contains('Front\tBack\tTransliteration\tRoot\tBinyanOrCategory\tAudio\tTags'));
      expect(tsv, contains('שָׁלוֹם\tПривет, мир\t\tש-ל-מ\tפָּעַל (Pa\'al)\t[sound:shalom.mp3]\tnexus_hebrew srs fsrs paal'));
    });

    test('поддерживает отключение огласовок (никкуда) при экспорте', () {
      final tsv = service.exportSrsCards(
        [testCard],
        format: AnkiExportFormat.tsv,
        includeNikkud: false,
      );

      expect(tsv, contains('שלום\tПривет, мир'));
      expect(tsv, isNot(contains('שָׁלוֹם')));
    });

    test('экспортирует словарные статьи в CSV с корректным экранированием кавычек и запятых', () {
      final csv = service.exportDictionaryEntries([testEntry], format: AnkiExportFormat.csv);

      expect(csv, contains('Front,Back,Transliteration,Root,BinyanOrCategory,Audio,Tags'));
      expect(csv, contains('תּוֹדָה'));
      expect(csv, contains('"Спасибо; благодарность"'));
      expect(csv, contains('[sound:toda.mp3]'));
      expect(csv, contains('nexus_hebrew dictionary noun'));
    });

    test('корректно экранирует табы и переводы строк в TSV', () {
      const customRow = AnkiExportRow(
        hebrewVocalized: 'מַיִם',
        hebrewNormalized: 'מים',
        russianTranslation: 'Вода\tчистая\nхолодная',
        tags: ['test'],
      );

      final tsv = service.exportRows([customRow], format: AnkiExportFormat.tsv);
      // Табы и переводы строк внутри Back должны быть заменены на пробелы
      expect(tsv, contains('מַיִם\tВода чистая холодная\t\t\t\t\ttest'));
    });
  });
}
