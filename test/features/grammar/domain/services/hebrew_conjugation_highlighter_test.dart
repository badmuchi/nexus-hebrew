import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/services/hebrew_conjugation_highlighter.dart';

void main() {
  const highlighter = HebrewConjugationHighlighter();
  final shoreshKtav = Shoresh.create('כ-ת-ב').getOrNull()!;

  group('HebrewConjugationHighlighter', () {
    test('выделяет корень и суффикс прошедшего времени (כָּתַבְתִּי)', () {
      final segments = highlighter.highlight(
        vocalizedForm: 'כָּתַבְתִּי',
        root: shoreshKtav,
      );

      expect(segments.length, 2);
      expect(segments[0].role, MorphologicalRole.root);
      expect(segments[0].text, 'כָּתַבְ');
      expect(segments[1].role, MorphologicalRole.suffix);
      expect(segments[1].text, 'תִּי');
    });

    test('выделяет приставку и корень будущего времени (אֶכְתֹּב)', () {
      final segments = highlighter.highlight(
        vocalizedForm: 'אֶכְתֹּב',
        root: shoreshKtav,
      );

      expect(segments.length, 2);
      expect(segments[0].role, MorphologicalRole.prefix);
      expect(segments[0].text, 'אֶ');
      expect(segments[1].role, MorphologicalRole.root);
      expect(segments[1].text, 'כְתֹּב');
    });

    test('выделяет приставку, корень и инфикс в биньяне Ифъиль (הִכְתִּיב)', () {
      final segments = highlighter.highlight(
        vocalizedForm: 'הִכְתִּיב',
        root: shoreshKtav,
      );

      expect(segments[0].role, MorphologicalRole.prefix);
      expect(segments[0].text, 'הִ');

      final rootAndInfix = segments.sublist(1);
      final roles = rootAndInfix.map((s) => s.role).toList();
      expect(roles, contains(MorphologicalRole.root));
      expect(roles, contains(MorphologicalRole.infix));

      final joinedText = segments.map((s) => s.text).join();
      expect(joinedText, 'הִכְתִּיב');
    });

    test('выделяет приставку и суффикс множественного числа (מִתְכַּתְּבִים)', () {
      final segments = highlighter.highlight(
        vocalizedForm: 'מִתְכַּתְּבִים',
        root: shoreshKtav,
      );

      expect(segments.first.role, MorphologicalRole.prefix);
      expect(segments.first.text, 'מִתְ');
      expect(segments.last.role, MorphologicalRole.suffix);
      expect(segments.last.text, 'ים');
    });

    test('корректно обрабатывает пустую строку и текст без букв', () {
      expect(highlighter.highlight(vocalizedForm: '', root: shoreshKtav), isEmpty);
      final fallback = highlighter.highlight(
        vocalizedForm: '123',
        root: shoreshKtav,
      );
      expect(fallback.first.role, MorphologicalRole.base);
      expect(fallback.first.text, '123');
    });
  });
}
