import '../entities/pin.dart';

abstract interface class PinRepository {
  Future<PinPage> discover({
    String query = '',
    int page = 1,
    bool videos = false,
    bool refresh = false,
  });
  Future<Pin?> find(String id);
  Future<void> registerDownload(Pin pin);
}
