import '../entities/library.dart';
import '../entities/pin.dart';

/// Idempotent board membership and its resulting collection snapshot.
class SavePin {
  const SavePin();
  Library call(Library library, Pin pin, String boardId) {
    if (!library.boards.any((board) => board.id == boardId)) {
      throw StateError('Board no longer exists.');
    }
    final ids = [...library.saved[boardId] ?? <String>[]];
    if (ids.contains(pin.id)) {
      return library;
    }
    ids.add(pin.id);
    final board = library.boards.firstWhere((board) => board.id == boardId);
    return library.copyWith(
      pins: {...library.pins, pin.id: pin},
      saved: {...library.saved, boardId: ids},
      activity: [
        'Saved “${pin.title}” to ${board.name}',
        ...library.activity,
      ].take(50).toList(),
    );
  }
}
