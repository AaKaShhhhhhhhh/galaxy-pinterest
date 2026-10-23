import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/file_service.dart';
import '../../core/services/network_service.dart';
import '../../data/datasources/demo_data_source.dart';
import '../../data/datasources/pexels_data_source.dart';
import '../../data/datasources/unsplash_data_source.dart';
import '../../data/repositories/pin_repository_impl.dart';
import '../../data/repositories/local_library_repository.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/entities/pin.dart';
import '../../domain/entities/library.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../domain/usecases/discover_pins.dart';
import 'library_controller.dart';

final cacheProvider = Provider<CacheService>(
  (ref) => throw UnimplementedError('Override in main'),
);
final fileServiceProvider = Provider<FileService>((ref) => FileService());
final sessionProvider = StateProvider<String>((ref) => 'guest');
final repositoryProvider = Provider<PinRepository>(
  (ref) => PinRepositoryImpl(
    DemoDataSource(),
    PexelsDataSource(NetworkService()),
    ref.watch(cacheProvider),
    UnsplashDataSource(),
  ),
);
final discoverPinsProvider = Provider(
  (ref) => DiscoverPins(ref.watch(repositoryProvider)),
);
final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LocalLibraryRepository(ref.watch(cacheProvider)),
);
final libraryProvider = StateNotifierProvider<LibraryController, Library>(
  (ref) => LibraryController(
    ref.watch(libraryRepositoryProvider),
    ref.watch(sessionProvider),
  ),
);
final pinProvider = FutureProvider.family<Pin?, String>((ref, id) async {
  final local = ref.watch(libraryProvider).pins[id];
  return local ?? ref.watch(repositoryProvider).find(id);
});
