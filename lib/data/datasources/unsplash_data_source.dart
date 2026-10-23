import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../domain/entities/pin.dart';

class UnsplashDataSource {
  UnsplashDataSource()
    : dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.unsplash.com',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Authorization': 'Client-ID ${AppConfig.unsplashAccessKey}',
            'Accept-Version': 'v1',
          },
        ),
      );
  final Dio dio;
  Pin parse(Map<String, dynamic> j, {String category = 'For you'}) {
    final user = j['user'] as Map;
    final title =
        j['description'] as String? ??
        j['alt_description'] as String? ??
        'An idea to keep';
    return Pin(
      id: 'unsplash_${j['id']}',
      title: title,
      description: title,
      imageUrl: (j['urls'] as Map)['regular'] as String,
      sourceUrl:
          '${(j['links'] as Map)['html']}?utm_source=galaxy_pinterest&utm_medium=referral',
      creator: user['name'] as String,
      creatorUrl:
          '${(user['links'] as Map)['html']}?utm_source=galaxy_pinterest&utm_medium=referral',
      downloadLocation: (j['links'] as Map)['download_location'] as String?,
      width: j['width'] as int,
      height: j['height'] as int,
      source: 'Unsplash',
      category: category,
      color:
          int.tryParse(
            (j['color'] as String? ?? '#e9e4de').replaceFirst('#', 'ff'),
            radix: 16,
          ) ??
          0xffe9e4de,
    );
  }

  Future<PinPage> discover(String query, int page) async {
    final r = await dio.get<dynamic>(
      query.isEmpty ? '/photos' : '/search/photos',
      queryParameters: {
        'page': page,
        'per_page': 20,
        if (query.isNotEmpty) 'query': query,
        'content_filter': 'high',
      },
    );
    final List items = query.isEmpty
        ? r.data as List
        : (r.data as Map)['results'] as List;
    return PinPage(
      items
          .map(
            (e) => parse(
              Map<String, dynamic>.from(e),
              category: query.isEmpty ? 'For you' : query,
            ),
          )
          .toList(),
      hasMore: query.isEmpty
          ? items.length == 20
          : page < ((r.data as Map)['total_pages'] as int),
    );
  }

  Future<Pin?> find(String id) async => parse(
    (await dio.get<Map<String, dynamic>>(
      '/photos/${id.replaceFirst('unsplash_', '')}',
    )).data!,
  );
  Future<void> registerDownload(Pin pin) async {
    final location = pin.downloadLocation;
    if (location != null &&
        Uri.tryParse(location)?.host == 'api.unsplash.com') {
      await dio.get<dynamic>(location);
    }
  }
}
