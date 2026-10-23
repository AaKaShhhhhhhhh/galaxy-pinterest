import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:galaxy_pinterest/domain/entities/pin.dart';
import 'package:galaxy_pinterest/domain/repositories/pin_repository.dart';
import 'package:galaxy_pinterest/domain/usecases/discover_pins.dart';
import 'package:galaxy_pinterest/presentation/providers/feed_controller.dart';

class FakeRepository implements PinRepository {
  final requests = <Completer<PinPage>>[];
  @override
  Future<PinPage> discover({
    String query = '',
    int page = 1,
    bool videos = false,
    bool refresh = false,
  }) {
    final c = Completer<PinPage>();
    requests.add(c);
    return c.future;
  }

  @override
  Future<Pin?> find(String id) async => null;
  @override
  Future<void> registerDownload(Pin pin) async {}
}

const a = Pin(id: 'a', title: 'A', imageUrl: '', width: 1, height: 2);
const b = Pin(id: 'b', title: 'B', imageUrl: '', width: 1, height: 2);
void main() {
  test('Stale first-page responses cannot replace a newer refresh', () async {
    final repository = FakeRepository();
    final c = FeedController(DiscoverPins(repository), defaultFeed);
    final newest = c.refresh();
    repository.requests[1].complete(const PinPage([b], hasMore: false));
    await newest;
    repository.requests[0].complete(const PinPage([a], hasMore: true));
    await Future<void>.delayed(Duration.zero);
    expect(c.state.pins.single.id, 'b');
    c.dispose();
  });
  test(
    'Pagination deduplicates repeated Pins and stops at last page',
    () async {
      final repository = FakeRepository();
      final c = FeedController(DiscoverPins(repository), defaultFeed);
      repository.requests[0].complete(const PinPage([a], hasMore: true));
      await Future<void>.delayed(Duration.zero);
      final next = c.next();
      repository.requests[1].complete(const PinPage([a, b], hasMore: false));
      await next;
      expect(c.state.pins.map((p) => p.id), ['a', 'b']);
      await c.next();
      expect(repository.requests.length, 2);
      c.dispose();
    },
  );
  test('Next-page failure preserves Pins and allows retry', () async {
    final repository = FakeRepository();
    final c = FeedController(DiscoverPins(repository), defaultFeed);
    repository.requests[0].complete(const PinPage([a], hasMore: true));
    await Future<void>.delayed(Duration.zero);
    final next = c.next();
    repository.requests[1].completeError(StateError('offline'));
    await next;
    expect(c.state.pins.single.id, 'a');
    expect(c.state.pageError, isNotNull);
    final retry = c.next();
    repository.requests[2].complete(const PinPage([b], hasMore: false));
    await retry;
    expect(c.state.pins.length, 2);
    c.dispose();
  });
}
