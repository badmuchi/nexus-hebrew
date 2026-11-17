import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../dictionary/domain/entities/dictionary_entry.dart';
import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../entities/morphology_models.dart';

class HebrewMorphologyEngine {
  const HebrewMorphologyEngine();

  static final RegExp _punctuationRegex = RegExp(r'[.,!?:;"״׳()[\]{}—–\-]');
  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  SentenceMorphology analyzeSentence({
    required String sentence,
    String? russianTranslation,
    List<DictionaryEntry> dictionaryEntries = const <DictionaryEntry>[],
    List<VerbLexeme> verbs = const <VerbLexeme>[],
  }) {
    final tokens = sentence.trim().split(_whitespaceRegex);
    final words = <WordMorphology>[];

    for (final rawToken in tokens) {
      final clean = cleanPunctuation(rawToken);
      if (clean.isEmpty) continue;

      final wordMorph = analyzeWord(
        rawToken: rawToken,
        cleanToken: clean,
        dictionaryEntries: dictionaryEntries,
        verbs: verbs,
      );
      words.add(wordMorph);
    }

    return SentenceMorphology(
      originalSentence: sentence,
      russianTranslation: russianTranslation,
      words: words,
    );
  }

  WordMorphology analyzeWord({
    required String rawToken,
    String? cleanToken,
    List<DictionaryEntry> dictionaryEntries = const <DictionaryEntry>[],
    List<VerbLexeme> verbs = const <VerbLexeme>[],
  }) {
    final vocalized = cleanToken ?? cleanPunctuation(rawToken);
    final normalized = HebrewNormalizer.stripNikkud(vocalized);

    // 1. Попытка точного совпадения всего слова без префиксов
    final directDict = _findInDictionary(normalized, dictionaryEntries);
    final directVerb = _findInVerbs(normalized, verbs);

    // Если слово найдено целиком в словаре и не начинается с явных комбо-префиксов (как וכש, ומה, ובה)
    if ((directDict != null || directVerb != null) &&
        !_hasMandatoryComboPrefix(normalized)) {
      if (directDict != null) {
        return WordMorphology(
          rawToken: rawToken,
          cleanVocalized: vocalized,
          cleanNormalized: normalized,
          prefixes: const [],
          lemma: directDict.hebrew.vocalized,
          lemmaNormalized: directDict.hebrew.normalized,
          translation: directDict.russianTranslation,
          partOfSpeech: directDict.category.name,
          root: directDict.root,
          suffix: null,
          explanation: directDict.russianTranslation,
        );
      } else if (directVerb != null) {
        final inf = directVerb.infinitive ?? directVerb.lemma;
        return WordMorphology(
          rawToken: rawToken,
          cleanVocalized: vocalized,
          cleanNormalized: normalized,
          prefixes: const [],
          lemma: inf.vocalized,
          lemmaNormalized: inf.normalized,
          translation: directVerb.russianMeaning,
          partOfSpeech: 'глагол',
          root: directVerb.root,
          binyan: directVerb.binyan,
          suffix: null,
          explanation:
              'Глагол биньяна ${directVerb.binyan.hebrewLabel} (${directVerb.binyan.transliteration}): ${directVerb.russianMeaning}',
        );
      }
    }

    // 2. Разбор префиксов и суффиксов
    final prefixResult = _extractPrefixes(vocalized, normalized, dictionaryEntries);
    final stemVocalized = prefixResult.stemVocalized;
    final stemNormalized = prefixResult.stemNormalized;
    final prefixes = prefixResult.prefixes;

    // Проверяем суффикс на остатке основы
    final suffixResult = _extractSuffix(stemVocalized, stemNormalized, dictionaryEntries);
    final finalStemVocalized = suffixResult.stemVocalized;
    final finalStemNormalized = suffixResult.stemNormalized;
    final suffix = suffixResult.suffix;

    // Ищем словарное соответствие для очищенной основы
    final stemDict = _findInDictionary(finalStemNormalized, dictionaryEntries);
    final stemVerb = _findInVerbs(finalStemNormalized, verbs);

    String lemma = finalStemVocalized;
    String lemmaNorm = finalStemNormalized;
    String translation = '';
    String? partOfSpeech;
    Shoresh? root;
    Binyan? binyan;

    if (stemDict != null) {
      lemma = stemDict.hebrew.vocalized;
      lemmaNorm = stemDict.hebrew.normalized;
      translation = stemDict.russianTranslation;
      partOfSpeech = stemDict.category.name;
      root = stemDict.root;
    } else if (stemVerb != null) {
      final inf = stemVerb.infinitive ?? stemVerb.lemma;
      lemma = inf.vocalized;
      lemmaNorm = inf.normalized;
      translation = stemVerb.russianMeaning;
      partOfSpeech = 'глагол';
      root = stemVerb.root;
      binyan = stemVerb.binyan;
    } else if (directDict != null) {
      // Откат если после отделения префикса не нашли, но все слово было в словаре
      lemma = directDict.hebrew.vocalized;
      lemmaNorm = directDict.hebrew.normalized;
      translation = directDict.russianTranslation;
      partOfSpeech = directDict.category.name;
      root = directDict.root;
    } else {
      translation = _deduceMeaning(finalStemNormalized);
    }

    // Генерируем подробное объяснение формулы
    final explanation = _buildExplanation(
      prefixes: prefixes,
      lemma: lemma,
      translation: translation,
      suffix: suffix,
    );

    return WordMorphology(
      rawToken: rawToken,
      cleanVocalized: vocalized,
      cleanNormalized: normalized,
      prefixes: prefixes,
      lemma: lemma,
      lemmaNormalized: lemmaNorm,
      translation: translation,
      partOfSpeech: partOfSpeech,
      root: root,
      binyan: binyan,
      suffix: suffix,
      explanation: explanation,
    );
  }

  static String cleanPunctuation(String input) {
    return input.replaceAll(_punctuationRegex, '').trim();
  }

  bool _hasMandatoryComboPrefix(String normalized) {
    return normalized.startsWith('וכש') ||
        normalized.startsWith('ובה') ||
        normalized.startsWith('ומה') ||
        normalized.startsWith('ולה') ||
        normalized.startsWith('וכ');
  }

  DictionaryEntry? _findInDictionary(
    String normalized,
    List<DictionaryEntry> entries,
  ) {
    for (final e in entries) {
      if (e.hebrew.normalized == normalized) {
        return e;
      }
    }
    return null;
  }

  VerbLexeme? _findInVerbs(
    String normalized,
    List<VerbLexeme> verbs,
  ) {
    for (final v in verbs) {
      if (v.lemma.normalized == normalized ||
          (v.infinitive != null && v.infinitive!.normalized == normalized)) {
        return v;
      }
      for (final form in v.conjugations) {
        if (form.form.normalized == normalized) {
          return v;
        }
      }
    }
    return null;
  }

  _PrefixExtractionResult _extractPrefixes(
    String vocalized,
    String normalized,
    List<DictionaryEntry> dictionary,
  ) {
    final prefixes = <PrefixToken>[];
    var currentNorm = normalized;
    var currentVoc = vocalized;

    // Проверяем союз "ו" (и, а)
    if (currentNorm.length >= 3 && currentNorm.startsWith('ו')) {
      final remainder = currentNorm.substring(1);
      final isRealWord = _isValidHebrewStem(remainder, dictionary);
      if (isRealWord ||
          currentNorm.startsWith('וכש') ||
          currentNorm.startsWith('וב') ||
          currentNorm.startsWith('ול') ||
          currentNorm.startsWith('ומ') ||
          currentNorm.startsWith('וה')) {
        final vocChar = currentVoc.isNotEmpty ? currentVoc[0] : 'ו';
        prefixes.add(
          PrefixToken(
            raw: vocChar,
            normalized: 'ו',
            meaning: 'Союз «и / а»',
            type: MorphemeType.conjunction,
          ),
        );
        currentNorm = remainder;
        currentVoc = _stripLeadingCharWithNikkud(currentVoc);
      }
    }

    // Проверяем относительный союз "כש" (когда)
    if (currentNorm.length >= 3 && currentNorm.startsWith('כש')) {
      final remainder = currentNorm.substring(2);
      if (_isValidHebrewStem(remainder, dictionary)) {
        prefixes.add(
          const PrefixToken(
            raw: 'כְּשֶׁ',
            normalized: 'כש',
            meaning: 'Союз «когда»',
            type: MorphemeType.relative,
          ),
        );
        currentNorm = remainder;
        currentVoc = _stripLeadingCharsWithNikkud(currentVoc, 2);
      }
    }
    // Проверяем относительный союз "ש" (что, который)
    else if (currentNorm.length >= 3 && currentNorm.startsWith('ש')) {
      final remainder = currentNorm.substring(1);
      if (_isValidHebrewStem(remainder, dictionary)) {
        prefixes.add(
          const PrefixToken(
            raw: 'שֶׁ',
            normalized: 'ש',
            meaning: 'Союз «что / который»',
            type: MorphemeType.relative,
          ),
        );
        currentNorm = remainder;
        currentVoc = _stripLeadingCharWithNikkud(currentVoc);
      }
    }

    // Проверяем предлоги אותיות בכ"ל / מ
    if (currentNorm.length >= 3) {
      final firstLetter = currentNorm[0];
      if (firstLetter == 'ב' ||
          firstLetter == 'ל' ||
          firstLetter == 'כ' ||
          firstLetter == 'מ') {
        final remainder = currentNorm.substring(1);
        if (_isValidHebrewStem(remainder, dictionary) ||
            remainder.startsWith('ה')) {
          final meaning = switch (firstLetter) {
            'ב' => 'Предлог «в / внутри / с помощью»',
            'ל' => 'Предлог «к / для / направление»',
            'כ' => 'Предлог «как / подобно / около»',
            'מ' => 'Предлог «из / от / начиная с»',
            _ => 'Предлог',
          };
          prefixes.add(
            PrefixToken(
              raw: currentVoc.isNotEmpty ? currentVoc[0] : firstLetter,
              normalized: firstLetter,
              meaning: meaning,
              type: MorphemeType.preposition,
            ),
          );
          currentNorm = remainder;
          currentVoc = _stripLeadingCharWithNikkud(currentVoc);
        }
      }
    }

    // Проверяем определенный артикль "ה" (тот самый / этот)
    if (currentNorm.length >= 3 && currentNorm.startsWith('ה')) {
      final remainder = currentNorm.substring(1);
      if (_isValidHebrewStem(remainder, dictionary)) {
        prefixes.add(
          const PrefixToken(
            raw: 'הַ',
            normalized: 'ה',
            meaning: 'Определенный артикль «тот самый»',
            type: MorphemeType.definiteArticle,
          ),
        );
        currentNorm = remainder;
        currentVoc = _stripLeadingCharWithNikkud(currentVoc);
      }
    }

    return _PrefixExtractionResult(
      stemVocalized: currentVoc.isEmpty ? vocalized : currentVoc,
      stemNormalized: currentNorm.isEmpty ? normalized : currentNorm,
      prefixes: prefixes,
    );
  }

  _SuffixExtractionResult _extractSuffix(
    String vocalized,
    String normalized,
    List<DictionaryEntry> dictionary,
  ) {
    if (normalized.length < 4) {
      return _SuffixExtractionResult(
        stemVocalized: vocalized,
        stemNormalized: normalized,
        suffix: null,
      );
    }

    // Местоименные суффиксы принадлежности
    final suffixes = [
      (
        norm: 'נו',
        voc: 'נוּ',
        meaning: 'Суффикс «наш / мы»',
        type: MorphemeType.pronominalSuffix
      ),
      (
        norm: 'כם',
        voc: 'כֶם',
        meaning: 'Суффикс «ваш (м.р.)»',
        type: MorphemeType.pronominalSuffix
      ),
      (
        norm: 'כן',
        voc: 'כֶן',
        meaning: 'Суффикс «ваш (ж.р.)»',
        type: MorphemeType.pronominalSuffix
      ),
      (
        norm: 'הם',
        voc: 'הֶם',
        meaning: 'Суффикс «их (м.р.)»',
        type: MorphemeType.pronominalSuffix
      ),
      (
        norm: 'הן',
        voc: 'הֶן',
        meaning: 'Суффикс «их (ж.р.)»',
        type: MorphemeType.pronominalSuffix
      ),
      (
        norm: 'תי',
        voc: 'תִּי',
        meaning: 'Суффикс прошедшего времени «я»',
        type: MorphemeType.pastTenseSuffix
      ),
      (
        norm: 'ים',
        voc: 'ִים',
        meaning: 'Окончание мн. числа (м.р.)',
        type: MorphemeType.genderNumberSuffix
      ),
      (
        norm: 'ות',
        voc: 'וֹת',
        meaning: 'Окончание мн. числа (ж.р.)',
        type: MorphemeType.genderNumberSuffix
      ),
      (
        norm: 'י',
        voc: 'ִי',
        meaning: 'Суффикс «мой»',
        type: MorphemeType.pronominalSuffix
      ),
      (
        norm: 'ך',
        voc: 'ךָ',
        meaning: 'Суффикс «твой»',
        type: MorphemeType.pronominalSuffix
      ),
      (
        norm: 'ו',
        voc: 'וֹ',
        meaning: 'Суффикс «его»',
        type: MorphemeType.pronominalSuffix
      ),
      (
        norm: 'ה',
        voc: 'ָהּ',
        meaning: 'Суффикс «её»',
        type: MorphemeType.pronominalSuffix
      ),
    ];

    for (final s in suffixes) {
      if (normalized.endsWith(s.norm)) {
        final remainder =
            normalized.substring(0, normalized.length - s.norm.length);
        if (_isValidHebrewStem(remainder, dictionary)) {
          final vocRemainder =
              _stripTrailingCharsWithNikkud(vocalized, s.norm.length);
          return _SuffixExtractionResult(
            stemVocalized: vocRemainder.isEmpty ? remainder : vocRemainder,
            stemNormalized: remainder,
            suffix: SuffixToken(
              raw: s.voc,
              normalized: s.norm,
              meaning: s.meaning,
              type: s.type,
            ),
          );
        }
      }
    }

    return _SuffixExtractionResult(
      stemVocalized: vocalized,
      stemNormalized: normalized,
      suffix: null,
    );
  }

  bool _isValidHebrewStem(String stem, List<DictionaryEntry> dictionary) {
    if (stem.length >= 3) return true;
    if (stem.length == 2) {
      const shortValidWords = {
        'ים',
        'יד',
        'דם',
        'עץ',
        'לב',
        'פה',
        'הר',
        'שר',
        'חג',
        'בת',
        'בן',
        'רב',
        'קל',
        'מר',
        'חי',
        'אב',
        'אח',
        'גן',
        'דג',
        'טל',
        'כד',
        'סל',
      };
      if (shortValidWords.contains(stem)) return true;
      for (final e in dictionary) {
        if (e.hebrew.normalized == stem) return true;
      }
    }
    return false;
  }

  String _stripLeadingCharWithNikkud(String vocalized) {
    if (vocalized.isEmpty) return vocalized;
    var i = 1;
    while (i < vocalized.length && _isNikkudCodeUnit(vocalized.codeUnitAt(i))) {
      i++;
    }
    return vocalized.substring(i);
  }

  String _stripLeadingCharsWithNikkud(String vocalized, int letterCount) {
    var result = vocalized;
    for (var count = 0; count < letterCount; count++) {
      result = _stripLeadingCharWithNikkud(result);
    }
    return result;
  }

  String _stripTrailingCharsWithNikkud(String vocalized, int letterCount) {
    var lettersRemoved = 0;
    var idx = vocalized.length - 1;
    while (idx >= 0 && lettersRemoved < letterCount) {
      if (!_isNikkudCodeUnit(vocalized.codeUnitAt(idx))) {
        lettersRemoved++;
      }
      idx--;
    }
    return idx >= 0 ? vocalized.substring(0, idx + 1) : '';
  }

  bool _isNikkudCodeUnit(int code) => code >= 0x0591 && code <= 0x05C7;

  String _deduceMeaning(String normalized) {
    if (normalized.isEmpty) return '';
    return 'Основа: $normalized';
  }

  String _buildExplanation({
    required List<PrefixToken> prefixes,
    required String lemma,
    required String translation,
    required SuffixToken? suffix,
  }) {
    final parts = <String>[];
    for (final p in prefixes) {
      parts.add('${p.raw} (${p.meaning})');
    }
    parts.add('$lemma ($translation)');
    if (suffix != null) {
      parts.add('${suffix.raw} (${suffix.meaning})');
    }
    return parts.join(' + ');
  }
}

final class _PrefixExtractionResult {
  final String stemVocalized;
  final String stemNormalized;
  final List<PrefixToken> prefixes;

  const _PrefixExtractionResult({
    required this.stemVocalized,
    required this.stemNormalized,
    required this.prefixes,
  });
}

final class _SuffixExtractionResult {
  final String stemVocalized;
  final String stemNormalized;
  final SuffixToken? suffix;

  const _SuffixExtractionResult({
    required this.stemVocalized,
    required this.stemNormalized,
    required this.suffix,
  });
}
