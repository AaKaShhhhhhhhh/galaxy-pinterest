import 'package:dio/dio.dart';
import '../config/app_config.dart';

class NetworkService {
  NetworkService()
    : dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.pexels.com',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Authorization': AppConfig.pexelsApiKey},
        ),
      );
  final Dio dio;
  static String message(Object error) {
    if (error is DioException) {
      return switch (error.response?.statusCode) {
        401 || 403 =>
          'Your image API key could not be verified. Check your app configuration.',
        429 =>
          'The image provider is taking a little break. Please try again later.',
        _ => 'Couldn’t connect. Check your connection and try again.',
      };
    }
    return 'Something went wrong. Please try again.';
  }
}
