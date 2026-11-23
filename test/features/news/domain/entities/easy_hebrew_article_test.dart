import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/news/data/datasources/easy_hebrew_news_seed_data.dart';
import 'package:nexus_hebrew_app/features/news/domain/entities/easy_hebrew_article.dart';

void main() {
  group('Easy Hebrew News Entities & Seed Data', () {
    test('Contains 4 adapted news articles with realistic Hebrew vocabulary and roots', () {
      const articles = EasyHebrewNewsSeedData.articles;
      expect(articles.length, 4);

      for (final a in articles) {
        expect(a.id, isNotEmpty);
        expect(a.titleHebrewWithNikkud, isNotEmpty);
        expect(a.titleHebrewNormalized, isNotEmpty);
        expect(a.titleRu, isNotEmpty);
        expect(a.readingLevelRu, isNotEmpty);
        expect(a.dateString, isNotEmpty);
        expect(a.readingMinutes, greaterThan(0));
        expect(a.paragraphs, isNotEmpty);
        expect(a.vocabulary, isNotEmpty);

        for (final p in a.paragraphs) {
          expect(p.hebrewWithNikkud, isNotEmpty);
          expect(p.hebrewNormalized, isNotEmpty);
          expect(p.translationRu, isNotEmpty);
        }

        for (final v in a.vocabulary) {
          expect(v.hebrewWithNikkud, isNotEmpty);
          expect(v.hebrewNormalized, isNotEmpty);
          expect(v.translationRu, isNotEmpty);
          expect(v.root, isNotNull);
        }
      }

      // Check specific articles
      final solar = articles.firstWhere((a) => a.id == 'news_1_solar_negev');
      expect(solar.category, NewsCategory.hightech);
      expect(solar.titleHebrewWithNikkud, contains('סְטַארְטְאַפּ יִשְׂרְאֵלִי'));

      final museum = articles.firstWhere((a) => a.id == 'news_2_scrolls_museum');
      expect(museum.category, NewsCategory.culture);
      expect(museum.titleRu, contains('Свитков Мёртвого моря'));
    });
  });
}
