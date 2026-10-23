import '../entities/library.dart';

/// A device-local collection, scoped to a guest or authenticated user.
abstract interface class LibraryRepository {
  Library read(String session);
  Future<void> save(String session, Library library);
}
