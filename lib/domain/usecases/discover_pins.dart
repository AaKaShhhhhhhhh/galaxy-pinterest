import '../entities/pin.dart';
import '../repositories/pin_repository.dart';

class DiscoverPins {
  const DiscoverPins(this.repository);
  final PinRepository repository;
  Future<PinPage> call({
    String query = '',
    int page = 1,
    bool videos = false,
    bool refresh = false,
  }) => repository.discover(
    query: query.trim(),
    page: page,
    videos: videos,
    refresh: refresh,
  );
}
