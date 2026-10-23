import 'package:galaxy_pinterest/data/repositories/local_library_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galaxy_pinterest/core/services/cache_service.dart';
import 'package:galaxy_pinterest/domain/entities/pin.dart';
import 'package:galaxy_pinterest/presentation/providers/library_controller.dart';

const pin = Pin(
  id: 'test',
  title: 'Test idea',
  imageUrl: 'https://example.com/photo.jpg',
  width: 800,
  height: 1200,
);
void main() {
  late CacheService cache;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cache = CacheService(await SharedPreferences.getInstance());
  });
  test('Saving is idempotent and survives controller recreation', () async {
    final controller = LibraryController(
      LocalLibraryRepository(cache),
      'guest',
    );
    await controller.savePin(pin, 'inspiration');
    await controller.savePin(pin, 'inspiration');
    expect(controller.state.pinsFor('inspiration').length, 1);
    final restored = LibraryController(LocalLibraryRepository(cache), 'guest');
    expect(restored.state.pinsFor('inspiration').single.id, 'test');
    controller.dispose();
    restored.dispose();
  });
  test(
    'Concurrent mutations are serialized without losing Pins or likes',
    () async {
      final controller = LibraryController(
        LocalLibraryRepository(cache),
        'guest',
      );
      await Future.wait([
        controller.savePin(pin, 'inspiration'),
        controller.like(pin),
        controller.search('Travel'),
      ]);
      expect(controller.state.isSaved('test'), isTrue);
      expect(controller.state.likes, contains('test'));
      expect(controller.state.searches, ['Travel']);
      controller.dispose();
    },
  );
  test('Accounts have isolated collections', () async {
    final guest = LibraryController(LocalLibraryRepository(cache), 'guest');
    await guest.savePin(pin, 'inspiration');
    final account = LibraryController(
      LocalLibraryRepository(cache),
      'user_test',
    );
    expect(account.state.isSaved('test'), isFalse);
    expect(
      LibraryController(
        LocalLibraryRepository(cache),
        'guest',
      ).state.isSaved('test'),
      isTrue,
    );
    guest.dispose();
    account.dispose();
  });
  test('Removing from one board preserves other board membership', () async {
    final c = LibraryController(LocalLibraryRepository(cache), 'guest');
    final id = await c.createBoard('Weekend');
    await c.savePin(pin, id);
    await c.savePin(pin, 'inspiration');
    await c.removePin('test', id);
    expect(c.state.isSaved('test'), isTrue);
    expect(c.state.pinsFor(id), isEmpty);
    c.dispose();
  });
  test('Deleting a board removes membership but retains liked Pins', () async {
    final c = LibraryController(LocalLibraryRepository(cache), 'guest');
    final id = await c.createBoard('Weekend');
    await c.savePin(pin, id);
    await c.like(pin);
    await c.deleteBoard(id);
    expect(c.state.isSaved('test'), isFalse);
    expect(c.state.likes, contains('test'));
    c.dispose();
  });
  test('Recent searches deduplicate ignoring case and cap at ten', () async {
    final c = LibraryController(LocalLibraryRepository(cache), 'guest');
    for (var i = 0; i < 15; i++) {
      await c.search('Idea $i');
    }
    await c.search('IDEA 14');
    expect(c.state.searches.length, 10);
    expect(c.state.searches.first, 'IDEA 14');
    c.dispose();
  });
  test('Corrupted local JSON does not prevent startup', () async {
    await cache.preferences.setString('library_v1_guest', 'not json');
    final c = LibraryController(LocalLibraryRepository(cache), 'guest');
    expect(c.state.boards.single.id, 'inspiration');
    c.dispose();
  });
}
