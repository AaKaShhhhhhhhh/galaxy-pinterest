import '../../core/services/cache_service.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/library.dart';
import '../../domain/repositories/library_repository.dart';

class LocalLibraryRepository implements LibraryRepository {
  LocalLibraryRepository(this.cache);
  final CacheService cache;

  @override
  Library read(String session) {
    try {
      final json = cache.read('library_v1_$session');
      if (json != null) {
        return Library.fromJson(json);
      }
    } catch (_) {
      // An incompatible local schema must not prevent app startup.
    }
    return const Library(
      boards: [Board(id: 'inspiration', name: 'My inspiration')],
    );
  }

  @override
  Future<void> save(String session, Library library) =>
      cache.write('library_v1_$session', library.toJson());
}
