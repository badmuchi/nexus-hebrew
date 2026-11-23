import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/holidays/data/datasources/holidays_seed_data.dart';
import 'package:nexus_hebrew_app/features/holidays/domain/entities/jewish_holiday.dart';

void main() {
  group('Holidays & Shabbat Entities & Seed Data', () {
    test('Shabbat rules contain 4 consecutive stages from Friday morning to Motzei Shabbat', () {
      const stages = HolidaysSeedData.shabbatStages;
      expect(stages.length, 4);

      expect(stages[0].id, 'shabbat_1_friday_prep');
      expect(stages[0].hebrewTitleWithNikkud, contains('יוֹם שִׁישִׁי'));
      expect(stages[0].transportAndShopsRu, isNotEmpty);
      expect(stages[0].etiquetteTipRu, isNotEmpty);

      expect(stages[1].id, 'shabbat_2_knisat_shabbat');
      expect(stages[1].hebrewTitleWithNikkud, contains('כְּנִיסַת שַׁבָּת'));

      expect(stages[2].id, 'shabbat_3_saturday_day');
      expect(stages[2].hebrewTitleWithNikkud, contains('יוֹם הַשַּׁבָּת'));

      expect(stages[3].id, 'shabbat_4_motzash_havdalah');
      expect(stages[3].hebrewTitleWithNikkud, contains('מוֹצָאֵי שַׁבָּת'));
    });

    test('All Jewish holidays have valid seasons, Hebrew names with nikkud and greetings', () {
      const holidays = HolidaysSeedData.jewishHolidays;
      expect(holidays.length, greaterThanOrEqualTo(8));

      for (final h in holidays) {
        expect(h.russianTitle, isNotEmpty);
        expect(h.hebrewNameWithNikkud, isNotEmpty);
        expect(h.greetingHebrewWithNikkud, isNotEmpty);
        expect(h.greetingRussian, isNotEmpty);
        expect(h.customsAndFoodRu, isNotEmpty);
        expect(h.modernIsraeliRealityRu, isNotEmpty);
      }

      final roshHashanah = holidays.firstWhere((h) => h.id == 'hol_1_rosh_hashanah');
      expect(roshHashanah.season, HolidaySeason.autumn);
      expect(roshHashanah.customsAndFoodRu, contains('Яблоки'));

      final yomKippur = holidays.firstWhere((h) => h.id == 'hol_2_yom_kippur');
      expect(yomKippur.greetingHebrewWithNikkud, contains('גְּמַר חֲתִימָה טוֹבָה'));

      final pesach = holidays.firstWhere((h) => h.id == 'hol_6_passover');
      expect(pesach.season, HolidaySeason.spring);
      expect(pesach.customsAndFoodRu, contains('мацы'));

      final memorial = holidays.firstWhere((h) => h.id == 'hol_7_yom_hazikaron');
      expect(memorial.season, HolidaySeason.nationalDays);
      expect(memorial.greetingHebrewWithNikkud, contains('יְהִי זִכְרָם בָּרוּךְ'));
    });

    test('Holiday etiquette scenarios have valid options and explanations', () {
      const scenarios = HolidaysSeedData.holidayScenarios;
      expect(scenarios.length, greaterThanOrEqualTo(4));

      for (final s in scenarios) {
        expect(s.situationRu, isNotEmpty);
        expect(s.interlocutorRoleRu, isNotEmpty);
        expect(s.responseOptions.length, greaterThanOrEqualTo(3));
        expect(s.bestOptionIndex, inInclusiveRange(0, s.responseOptions.length - 1));
        expect(s.explanationRu, isNotEmpty);
        expect(s.etiquetteTipRu, isNotEmpty);
      }
    });

    test('Glossary items contain Hebrew, Russian and tips', () {
      const glossary = HolidaysSeedData.holidaysGlossary;
      expect(glossary.length, greaterThanOrEqualTo(12));

      for (final term in glossary) {
        expect(term['hebrew'], isNotEmpty);
        expect(term['transcription'], isNotEmpty);
        expect(term['translation'], isNotEmpty);
        expect(term['tip'], isNotEmpty);
      }
    });
  });
}
