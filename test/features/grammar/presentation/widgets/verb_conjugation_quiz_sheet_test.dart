import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/grammar/presentation/widgets/verb_conjugation_quiz_sheet.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

void main() {
  final testVerb = VerbLexeme(
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
    conjugations: const [
      ConjugatedForm(
        tense: VerbTense.past,
        person: GrammaticalPerson.firstSingular,
        form: HebrewText.fixture(vocalized: 'כָּתַבְתִּי', normalized: 'כתבתי'),
        transliteration: 'katavti',
      ),
      ConjugatedForm(
        tense: VerbTense.past,
        person: GrammaticalPerson.secondMasculineSingular,
        form: HebrewText.fixture(vocalized: 'כָּתַבְתָּ', normalized: 'כתבת'),
        transliteration: 'katavta',
      ),
      ConjugatedForm(
        tense: VerbTense.future,
        person: GrammaticalPerson.firstSingular,
        form: HebrewText.fixture(vocalized: 'אֶכְתֹּב', normalized: 'אכתוב'),
        transliteration: 'echtov',
      ),
      ConjugatedForm(
        tense: VerbTense.present,
        person: GrammaticalPerson.masculineSingular,
        form: HebrewText.fixture(vocalized: 'כּוֹתֵב', normalized: 'כותב'),
        transliteration: 'kotev',
      ),
    ],
    attribution: const ContentAttribution(
      sourceName: 'Wiktionary',
      licenseName: 'CC BY-SA 4.0',
    ),
  );

  Widget buildWidget({
    ValueChanged<ConjugatedForm>? onSaveToSrs,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: VerbConjugationQuizSheet(
            verbs: [testVerb],
            showNikkud: true,
            onSaveToSrs: onSaveToSrs,
          ),
        ),
      ),
    );
  }

  group('VerbConjugationQuizSheet', () {
    testWidgets('рендерит глагол, задание и варианты ответа', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('писать (Pa\'al)'), findsOneWidget);
      expect(find.text('Выберите правильную форму:'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNWidgets(4));
    });

    testWidgets('выбор ответа показывает фидбек и кнопку перехода к следующему вопросу',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final firstOption = find.byType(OutlinedButton).first;
      await tester.tap(firstOption);
      await tester.pumpAndSettle();

      expect(find.text('Следующий вопрос'), findsOneWidget);

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Следующий вопрос'));
      await tester.pumpAndSettle();

      expect(find.byType(OutlinedButton), findsNWidgets(4));
    });
  });
}
