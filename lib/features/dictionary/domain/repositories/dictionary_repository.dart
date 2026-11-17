import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/dictionary_entry.dart';

/// Offline-first repository for the Hebrew-Russian dictionary & open-source lookup.
abstract interface class DictionaryRepository {
  /// Returns all locally cached dictionary entries (seeded + user + online cache).
  Future<Result<List<DictionaryEntry>, Failure>> getAllEntries();

  /// Returns normalized Hebrew texts currently present in the user's FSRS deck.
  Future<Result<Set<String>, Failure>> getSrsNormalizedForms();

  /// Saves a custom or user-edited entry to the local dictionary database.
  Future<Result<DictionaryEntry, Failure>> saveCustomEntry(
    DictionaryEntry entry,
  );

  /// Queries open-licensed sources (Tatoeba / Wiktionary) in Hebrew or Russian
  /// and caches new matches locally.
  Future<Result<List<DictionaryEntry>, Failure>> searchOnlineAndCache({
    required String query,
    int limit = 12,
  });
}
