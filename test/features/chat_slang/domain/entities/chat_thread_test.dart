import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/chat_slang/data/datasources/chat_slang_seed_data.dart';
import 'package:nexus_hebrew_app/features/chat_slang/domain/entities/chat_channel.dart';

void main() {
  group('Chat Slang Entities & Seed Data', () {
    test('Contains 3 authentic chat channels with messages and challenge', () {
      const threads = ChatSlangSeedData.threads;
      expect(threads.length, 3);

      expect(threads[0].category, ChatChannelCategory.buildingCommittee);
      expect(threads[0].groupNameHebrew, contains('וַעַד בַּיִת'));
      expect(threads[0].messages, isNotEmpty);
      expect(threads[0].challenge.optionsHebrewWithNikkud.length, 3);
      expect(threads[0].challenge.bestOptionIndex, inInclusiveRange(0, 2));

      expect(threads[1].category, ChatChannelCategory.highTechTeam);
      expect(threads[1].groupNameRu, contains('Хайтек Dev Team'));
      expect(threads[1].messages.any((m) => m.slangDictionary.containsKey('חֲבָלָ״ז')), isTrue);

      expect(threads[2].category, ChatChannelCategory.weekendFriends);
      expect(threads[2].groupNameRu, contains('Друзья'));
      expect(threads[2].messages.any((m) => m.slangDictionary.containsKey('זוֹרֵם')), isTrue);
    });

    test('Chat slang glossary contains at least 16 abbreviations and terms', () {
      const glossary = ChatSlangSeedData.chatSlangGlossary;
      expect(glossary.length, greaterThanOrEqualTo(16));

      for (final item in glossary) {
        expect(item['abbreviation'], isNotEmpty);
        expect(item['fullHebrew'], isNotEmpty);
        expect(item['transcription'], isNotEmpty);
        expect(item['meaningRu'], isNotEmpty);
        expect(item['category'], isNotEmpty);
      }

      // Check key Israeli slang abbreviations
      final amlak = glossary.firstWhere((item) => item['abbreviation'] == 'אמלק');
      expect(amlak['meaningRu'], contains('Слишком длинно, не читал'));

      final chavalaz = glossary.firstWhere((item) => item['abbreviation'] == 'חבלז');
      expect(chavalaz['fullHebrew'], contains('חֲבָל עַל הַזְּמַן'));

      final sofash = glossary.firstWhere((item) => item['abbreviation'] == 'סופ״ש');
      expect(sofash['fullHebrew'], contains('סוֹף שָׁבוּעַ'));
    });
  });
}
