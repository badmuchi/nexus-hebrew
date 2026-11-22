import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/audio_drill_config.dart';

void main() {
  group('AudioDrillConfig', () {
    test('default configuration has correct properties', () {
      const config = AudioDrillConfig();

      expect(config.direction, equals(AudioDrillDirection.hebrewToRussian));
      expect(config.filter, equals(AudioDrillFilter.weakWordsOnly));
      expect(config.pauseSeconds, equals(3.0));
      expect(config.includeExamples, isFalse);
      expect(config.repeatCount, equals(1));
      expect(config.isLooping, isTrue);
    });

    test('copyWith updates fields correctly', () {
      const config = AudioDrillConfig();
      final updated = config.copyWith(
        direction: AudioDrillDirection.russianToHebrew,
        filter: AudioDrillFilter.dueTodayOnly,
        pauseSeconds: 5.0,
        includeExamples: true,
        repeatCount: 2,
        isLooping: false,
      );

      expect(updated.direction, equals(AudioDrillDirection.russianToHebrew));
      expect(updated.filter, equals(AudioDrillFilter.dueTodayOnly));
      expect(updated.pauseSeconds, equals(5.0));
      expect(updated.includeExamples, isTrue);
      expect(updated.repeatCount, equals(2));
      expect(updated.isLooping, isFalse);
    });

    test('AudioDrillDirection metadata has icons and labels', () {
      for (final dir in AudioDrillDirection.values) {
        expect(dir.labelRu, isNotEmpty);
        expect(dir.description, isNotEmpty);
        expect(dir.icon, isNotEmpty);
      }
    });

    test('AudioDrillFilter metadata has icons and labels', () {
      for (final filter in AudioDrillFilter.values) {
        expect(filter.labelRu, isNotEmpty);
        expect(filter.description, isNotEmpty);
        expect(filter.icon, isNotEmpty);
      }
    });
  });
}
