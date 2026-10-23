import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/network_service.dart';
import '../../domain/entities/pin.dart';
import '../../domain/usecases/discover_pins.dart';
import 'providers.dart';

typedef FeedQuery = ({String query, bool videos});
const defaultFeed = (query: '', videos: false);
final feedProvider = StateNotifierProvider.autoDispose
    .family<FeedController, FeedState, FeedQuery>(
      (ref, query) => FeedController(ref.watch(discoverPinsProvider), query),
    );

class FeedState {
  const FeedState({
    this.pins = const [],
    this.loading = true,
    this.loadingMore = false,
    this.hasMore = true,
    this.error,
    this.pageError,
  });
  final List<Pin> pins;
  final bool loading, loadingMore, hasMore;
  final String? error, pageError;
}

class FeedController extends StateNotifier<FeedState> {
  FeedController(this.discover, this.query) : super(const FeedState()) {
    refresh();
  }
  final DiscoverPins discover;
  final FeedQuery query;
  int _page = 1, _generation = 0;
  Future<void> refresh({bool force = false}) async {
    final generation = ++_generation;
    state = FeedState(pins: state.pins, loading: state.pins.isEmpty);
    try {
      final result = await discover(
        query: query.query,
        videos: query.videos,
        refresh: force,
      );
      if (!mounted || generation != _generation) {
        return;
      }
      _page = 1;
      state = FeedState(
        pins: result.pins,
        loading: false,
        hasMore: result.hasMore,
      );
    } catch (e) {
      if (mounted && generation == _generation) {
        state = FeedState(
          pins: state.pins,
          loading: false,
          error: NetworkService.message(e),
          hasMore: false,
        );
      }
    }
  }

  Future<void> next() async {
    if (state.loading || state.loadingMore || !state.hasMore) {
      return;
    }
    final generation = _generation;
    state = FeedState(
      pins: state.pins,
      loading: false,
      loadingMore: true,
      hasMore: true,
    );
    try {
      final result = await discover(
        query: query.query,
        page: _page + 1,
        videos: query.videos,
      );
      if (!mounted || generation != _generation) {
        return;
      }
      _page++;
      final seen = state.pins.map((p) => p.id).toSet();
      state = FeedState(
        pins: [...state.pins, ...result.pins.where((p) => seen.add(p.id))],
        loading: false,
        hasMore: result.hasMore,
      );
    } catch (e) {
      if (mounted && generation == _generation) {
        state = FeedState(
          pins: state.pins,
          loading: false,
          hasMore: true,
          pageError: NetworkService.message(e),
        );
      }
    }
  }
}
