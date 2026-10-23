import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/usecases/save_pin.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/library.dart';
import '../../domain/entities/pin.dart';

class LibraryController extends StateNotifier<Library> {
  LibraryController(this.repository, this.session)
    : super(repository.read(session));
  final LibraryRepository repository;
  final String session;
  Future<void> _pending = Future.value();

  Future<void> _change(Library Function(Library) transform) {
    final operation = _pending.then((_) async {
      final next = transform(state);
      await repository.save(session, next);
      if (mounted) {
        state = next;
      }
    });
    _pending = operation.catchError((Object _) {});
    return operation;
  }

  List<String> _activity(Library s, String text) =>
      [text, ...s.activity].take(50).toList();
  Future<void> savePin(Pin pin, String boardId) =>
      _change((library) => const SavePin()(library, pin, boardId));
  Future<void> removePin(String pinId, String boardId) => _change(
    (s) => s.copyWith(
      saved: {
        ...s.saved,
        boardId: (s.saved[boardId] ?? []).where((id) => id != pinId).toList(),
      },
    ),
  );
  Future<String> createBoard(
    String name, {
    String description = '',
    bool secret = false,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty || clean.length > 60) {
      throw ArgumentError('Use a board name between 1 and 60 characters.');
    }
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _change(
      (s) => s.copyWith(
        boards: [
          ...s.boards,
          Board(
            id: id,
            name: clean,
            description: description.trim(),
            isSecret: secret,
          ),
        ],
        activity: _activity(s, 'Created the board “$clean”'),
      ),
    );
    return id;
  }

  Future<void> updateBoard(Board board) => _change(
    (s) => s.copyWith(
      boards: s.boards.map((b) => b.id == board.id ? board : b).toList(),
    ),
  );
  Future<void> deleteBoard(String id) => _change(
    (s) => s.copyWith(
      boards: s.boards.where((b) => b.id != id).toList(),
      saved: {...s.saved}..remove(id),
    ),
  );
  Future<void> like(Pin pin) => _change(
    (s) => s.copyWith(
      pins: {...s.pins, pin.id: pin},
      likes: s.likes.contains(pin.id)
          ? ({...s.likes}..remove(pin.id))
          : {...s.likes, pin.id},
    ),
  );
  Future<void> hide(String id) =>
      _change((s) => s.copyWith(hidden: {...s.hidden, id}));
  Future<void> unhideAll() => _change((s) => s.copyWith(hidden: {}));
  Future<void> search(String query) => _change(
    (s) => s.copyWith(
      searches: [
        query,
        ...s.searches.where((e) => e.toLowerCase() != query.toLowerCase()),
      ].take(10).toList(),
    ),
  );
  Future<void> clearSearches() => _change((s) => s.copyWith(searches: []));
  Future<void> profile(String name, String username, String bio) => _change(
    (s) => s.copyWith(
      name: name.trim(),
      username: username.trim(),
      bio: bio.trim(),
    ),
  );
  Future<void> darkMode(bool value) =>
      _change((s) => s.copyWith(darkMode: value));
  Future<void> createPin(Pin pin, String boardId) => savePin(pin, boardId);
}
