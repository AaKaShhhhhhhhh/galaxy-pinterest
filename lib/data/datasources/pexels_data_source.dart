import '../../core/services/network_service.dart';
import '../../domain/entities/pin.dart';

class PexelsDataSource {
  PexelsDataSource(this.network);
  final NetworkService network;
  Future<PinPage> discover(String query, int page, bool videos) async {
    final path = videos
        ? (query.isEmpty ? '/v1/videos/popular' : '/v1/videos/search')
        : (query.isEmpty ? '/v1/curated' : '/v1/search');
    final response = await network.dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {
        'page': page,
        'per_page': 24,
        if (query.isNotEmpty) 'query': query,
      },
    );
    final data = response.data!;
    final pins = ((data[videos ? 'videos' : 'photos'] as List?) ?? []).map((
      raw,
    ) {
      final j = Map<String, dynamic>.from(raw);
      if (videos) {
        final files =
            (j['video_files'] as List)
                .cast<Map<String, dynamic>>()
                .where((f) => f['file_type'] == 'video/mp4')
                .toList()
              ..sort(
                (a, b) => (a['width'] as num? ?? 9999).compareTo(
                  b['width'] as num? ?? 9999,
                ),
              );
        final suitable = files
            .where((f) => (f['width'] as num? ?? 0) >= 540)
            .toList();
        return Pin(
          id: 'video_${j['id']}',
          title: query.isEmpty ? 'A moment worth keeping' : query,
          imageUrl: j['image'] as String,
          videoUrl:
              (suitable.isNotEmpty ? suitable.first : files.first)['link']
                  as String,
          creator: (j['user'] as Map?)?['name'] as String? ?? 'Pexels creator',
          width: j['width'] as int,
          height: j['height'] as int,
          sourceUrl: j['url'] as String,
          category: query.isEmpty ? 'Videos' : query,
        );
      }
      final src = j['src'] as Map;
      final alt = j['alt'] as String? ?? '';
      return Pin(
        id: j['id'].toString(),
        title: alt.isEmpty ? 'An idea to keep' : alt,
        description: alt,
        imageUrl: src['large'] as String,
        creator: j['photographer'] as String,
        width: j['width'] as int,
        height: j['height'] as int,
        sourceUrl: j['url'] as String,
        color:
            int.tryParse(
              (j['avg_color'] as String? ?? '#e9e4de').replaceFirst('#', 'ff'),
              radix: 16,
            ) ??
            0xffe9e4de,
        category: query.isEmpty ? 'For you' : query,
      );
    }).toList();
    return PinPage(pins, hasMore: data['next_page'] != null);
  }

  Future<Pin?> find(String id) async {
    if (id.startsWith('video_')) {
      return null;
    }
    final r = await network.dio.get<Map<String, dynamic>>('/v1/photos/$id');
    final j = r.data!;
    return Pin(
      id: id,
      title: j['alt'] as String? ?? 'An idea to keep',
      imageUrl: (j['src'] as Map)['large'] as String,
      creator: j['photographer'] as String,
      width: j['width'] as int,
      height: j['height'] as int,
      sourceUrl: j['url'] as String,
    );
  }
}
