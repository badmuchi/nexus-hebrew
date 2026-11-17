import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';

enum Binyan {
  paal('paal', 'פָּעַל', "Pa'al"),
  piel('piel', 'פִּעֵל', "Pi'el"),
  hifil('hifil', 'הִפְעִיל', "Hif'il"),
  hitpael('hitpael', 'הִתְפַּעֵל', "Hitpa'el"),
  nifal('nifal', 'נִפְעַל', "Nif'al"),
  pual('pual', 'פֻּעַל', "Pu'al"),
  hufal('hufal', 'הֻפְעַל', "Huf'al"),
  none('none', '', '');

  final String id;
  final String hebrewLabel;
  final String transliteration;

  const Binyan(this.id, this.hebrewLabel, this.transliteration);

  static Result<Binyan, ParsingFailure> parseStrict(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final value in Binyan.values) {
      if (value.id == normalized) {
        return Success(value);
      }
    }
    return Error(ParsingFailure('Unknown binyan value: "$raw"'));
  }
}
