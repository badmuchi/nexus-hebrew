import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/scenes/data/datasources/israeli_scenes_seed_data.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/entities/israeli_life_scene.dart';

void main() {
  group('IsraeliLifeScene Entities & Seed Data', () {
    test('PhraseRole properties are correct', () {
      expect(PhraseRole.theySay.isIncoming, isTrue);
      expect(PhraseRole.theySay.labelRu, 'Вам скажут 👂');

      expect(PhraseRole.youSay.isIncoming, isFalse);
      expect(PhraseRole.youSay.labelRu, 'Вы ответите 🗣️');
    });

    test('IsraeliScenesSeedData contains exactly 6 unique scenes', () {
      const scenes = IsraeliScenesSeedData.scenes;
      expect(scenes.length, equals(6));

      final ids = scenes.map((s) => s.id).toSet();
      expect(ids.length, equals(6));

      expect(ids, containsAll([
        'scene_supermarket',
        'scene_transport',
        'scene_clinic',
        'scene_cafe',
        'scene_rental',
        'scene_bureaucracy',
      ]));
    });

    test('Every scene has valid words with Hebrew vocalization, transliteration and translation', () {
      const scenes = IsraeliScenesSeedData.scenes;

      for (final scene in scenes) {
        expect(scene.titleRussian, isNotEmpty, reason: 'Empty title for ${scene.id}');
        expect(scene.titleHebrew, isNotEmpty);
        expect(scene.emoji, isNotEmpty);
        expect(scene.cultureLifehack, isNotEmpty);
        expect(scene.cefrLevel, isNotEmpty);

        expect(scene.words, isNotEmpty, reason: 'No words for ${scene.id}');
        final wordIds = <String>{};
        for (final word in scene.words) {
          expect(wordIds.add(word.id), isTrue, reason: 'Duplicate word id ${word.id} in ${scene.id}');
          expect(word.hebrewVocalized, isNotEmpty);
          expect(word.hebrewNormalized, isNotEmpty);
          expect(word.transliteration, isNotEmpty);
          expect(word.russianMeaning, isNotEmpty);
        }
      }
    });

    test('Every scene has survival phrases with incoming and outgoing roles', () {
      const scenes = IsraeliScenesSeedData.scenes;

      for (final scene in scenes) {
        expect(scene.phrases, isNotEmpty, reason: 'No phrases for ${scene.id}');

        final incomingPhrases = scene.phrases.where((p) => p.role.isIncoming).toList();
        final outgoingPhrases = scene.phrases.where((p) => !p.role.isIncoming).toList();

        expect(incomingPhrases, isNotEmpty, reason: 'Expected incoming phrases for ${scene.id}');
        expect(outgoingPhrases, isNotEmpty, reason: 'Expected outgoing phrases for ${scene.id}');

        final phraseIds = <String>{};
        for (final phrase in scene.phrases) {
          expect(phraseIds.add(phrase.id), isTrue, reason: 'Duplicate phrase id ${phrase.id}');
          expect(phrase.hebrewVocalized, isNotEmpty);
          expect(phrase.hebrewNormalized, isNotEmpty);
          expect(phrase.transliteration, isNotEmpty);
          expect(phrase.russianTranslation, isNotEmpty);
        }
      }
    });

    test('Every scene has challenges with valid options and correctIndex', () {
      const scenes = IsraeliScenesSeedData.scenes;

      for (final scene in scenes) {
        expect(scene.challenges, isNotEmpty, reason: 'No challenges for ${scene.id}');

        final challengeIds = <String>{};
        for (final challenge in scene.challenges) {
          expect(challengeIds.add(challenge.id), isTrue, reason: 'Duplicate challenge id ${challenge.id}');
          expect(challenge.situationRu, isNotEmpty);
          expect(challenge.options.length, greaterThanOrEqualTo(2));
          expect(challenge.correctIndex, inInclusiveRange(0, challenge.options.length - 1));
          expect(challenge.explanationRu, isNotEmpty);
        }
      }
    });

    test('Equatable props work correctly for IsraeliLifeScene', () {
      final scene1 = IsraeliScenesSeedData.scenes.first;
      final scene2 = IsraeliScenesSeedData.scenes.first;
      final sceneOther = IsraeliScenesSeedData.scenes.last;

      expect(scene1, equals(scene2));
      expect(scene1 == sceneOther, isFalse);
    });
  });
}
