import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService(this.preferences);
  final SharedPreferences preferences;
  Map<String, dynamic>? read(String key) {
    try {
      final raw = preferences.getString(key);
      return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> write(String key, Map<String, dynamic> value) async {
    if (!await preferences.setString(key, jsonEncode(value))) {
      throw StateError('Could not save your changes. Please try again.');
    }
    if (key.startsWith('feed_')) {
      final keys = [
        ...preferences.getStringList('feed_cache_keys') ?? <String>[],
      ]..remove(key);
      keys.add(key);
      while (keys.length > 16) {
        await preferences.remove(keys.removeAt(0));
      }
      await preferences.setStringList('feed_cache_keys', keys);
    }
  }
}
