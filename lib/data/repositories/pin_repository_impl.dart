import '../../core/config/app_config.dart';
import '../../core/services/cache_service.dart';
import '../../domain/entities/pin.dart';
import '../../domain/repositories/pin_repository.dart';
import '../datasources/demo_data_source.dart';
import '../datasources/unsplash_data_source.dart';
import '../datasources/pexels_data_source.dart';

class PinRepositoryImpl implements PinRepository {
  PinRepositoryImpl(this.demo, this.remote, this.cache, this.unsplash);
  final DemoDataSource demo;
  final PexelsDataSource remote;
  final CacheService cache;
  final UnsplashDataSource unsplash;
  final Map<String, Pin> _known = {};
  @override
  Future<PinPage> discover({
    String query = '',
    int page = 1,
    bool videos = false,
    bool refresh = false,
  }) async {
    if (!AppConfig.hasLiveImages) {
      return demo.search(query, page, videos);
    }
    if (videos && !AppConfig.hasPexels) {
      return const PinPage([], hasMore: false);
    }
    final cacheKey =
        'feed_v2_${AppConfig.hasUnsplash}_${videos}_${query.toLowerCase()}_$page';
    if (!refresh && page == 1) {
      final cached = cache.read(cacheKey);
      final timestamp = cached?['timestamp'] as int? ?? 0;
      if (cached != null &&
          DateTime.now().millisecondsSinceEpoch - timestamp < 900000) {
        return PinPage(
          (cached['pins'] as List)
              .map((e) => Pin.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
          hasMore: cached['hasMore'] == true,
        );
      }
    }
    try {
      final result = AppConfig.hasUnsplash && !videos
          ? await unsplash.discover(query, page)
          : await remote.discover(query, page, videos);
      for (final pin in result.pins) {
        _known[pin.id] = pin;
      }
      // Cache only the first page of each category, avoiding unbounded storage.
      if (page == 1) {
        await cache.write(cacheKey, {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'pins': result.pins.map((p) => p.toJson()).toList(),
          'hasMore': result.hasMore,
        });
      }
      return result;
    } catch (_) {
      final cached = cache.read(cacheKey);
      if (cached == null || refresh) {
        rethrow;
      }
      return PinPage(
        (cached['pins'] as List)
            .map((e) => Pin.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        hasMore: false,
      );
    }
  }

  @override
  Future<Pin?> find(String id) async {
    if (_known[id] case final pin?) {
      return pin;
    }
    for (final pin in await demo.load()) {
      if (pin.id == id) {
        return pin;
      }
    }
    return id.startsWith('unsplash_') && AppConfig.hasUnsplash
        ? unsplash.find(id)
        : AppConfig.hasPexels
        ? remote.find(id)
        : null;
  }

  @override
  Future<void> registerDownload(Pin pin) async {
    if (pin.source == 'Unsplash') {
      await unsplash.registerDownload(pin);
    }
  }
}
