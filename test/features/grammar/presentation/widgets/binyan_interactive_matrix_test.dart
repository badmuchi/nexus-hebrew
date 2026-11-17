import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/grammar/presentation/widgets/binyan_interactive_matrix.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

void main() {
  final sampleVerbs = [
    VerbLexeme(
      id: 'verb_paal_katav',
      lemma: const HebrewText.fixture(vocalized: 'כָּתַב', normalized: 'כתב'),
      infinitive: const HebrewText.fixture(
        vocalized: 'לִכְתֹּב',
        normalized: 'לכתוב',
      ),
      root: const Shoresh.fixture(<String>['כ', 'ת', 'ב']),
      binyan: Binyan.paal,
      russianMeaning: 'писать',
      grammarNotesRu: 'Пааль',
      conjugations: const [],
      attribution: const ContentAttribution(
        sourceName: 'Wiktionary',
        licenseName: 'CC BY-SA 4.0',
      ),
    ),
    VerbLexeme(
      id: 'verb_hifil_hichtiv',
      lemma: const HebrewText.fixture(vocalized: 'הִכְתִּיב', normalized: 'הכתיב'),
      infinitive: const HebrewText.fixture(
        vocalized: 'לְהַכְתִּיב',
        normalized: 'להכתיב',
      ),
      root: const Shoresh.fixture(<String>['כ', 'ת', 'ב']),
      binyan: Binyan.hifil,
      russianMeaning: 'диктовать',
      grammarNotesRu: 'Ифъиль',
      conjugations: const [],
      attribution: const ContentAttribution(
        sourceName: 'Wiktionary',
        licenseName: 'CC BY-SA 4.0',
      ),
    ),
  ];

  Widget buildWidget({
    ValueChanged<VerbLexeme>? onSelectVerb,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BinyanInteractiveMatrix(
          allVerbs: sampleVerbs,
          showNikkud: true,
          onSelectVerb: onSelectVerb,
        ),
      ),
    );
  }

  group('BinyanInteractiveMatrix', () {
    testWidgets('рендерит карточки 7 биньянов в режиме Атласа', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('7 Биньянов'), findsOneWidget);
      expect(find.text('Трансформация корня'), findsOneWidget);

      expect(find.text("Pa'al (Qal)"), findsOneWidget);
      expect(find.text("Nif'al"), findsOneWidget);
      expect(find.text("Pi'el"), findsOneWidget);

      await tester.scrollUntilVisible(find.text("Hif'il"), 100);
      expect(find.text("Hif'il"), findsOneWidget);
    });

    testWidgets('переключается в режим трансформации корня и вызывает onSelectVerb',
        (tester) async {
      VerbLexeme? selected;
      await tester.pumpWidget(
        buildWidget(onSelectVerb: (v) => selected = v),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Трансформация корня'));
      await tester.pumpAndSettle();

      expect(find.text('Выберите корень (שורש):'), findsOneWidget);
      expect(find.text('Превращения корня:'), findsOneWidget);
      expect(find.text('писать'), findsOneWidget);
      expect(find.text('диктовать'), findsOneWidget);

      final openConjugationBtn = find.byTooltip('Открыть спряжение').first;
      await tester.tap(openConjugationBtn);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'verb_paal_katav');
    });
  });
}
