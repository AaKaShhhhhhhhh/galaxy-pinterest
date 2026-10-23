import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/pin.dart';

class DemoDataSource {
  List<Pin>? _pins;
  Future<List<Pin>> load() async => _pins ??=
      (jsonDecode(await rootBundle.loadString('assets/data/pins.json')) as List)
          .map((e) => Pin.fromJson(Map<String, dynamic>.from(e)))
          .toList();
  Future<PinPage> search(String query, int page, bool videos) async {
    final pins = await load();
    final normalized = query.toLowerCase();
    final matches = pins
        .where(
          (p) =>
              (!videos || p.isVideo) &&
              (normalized.isEmpty ||
                  '${p.title} ${p.category} ${p.description} ${p.creator}'
                      .toLowerCase()
                      .contains(normalized)),
        )
        .toList();
    const pageSize = 12;
    final offset = (page - 1) * pageSize;
    return PinPage(
      matches.skip(offset).take(pageSize).toList(),
      hasMore: offset + pageSize < matches.length,
    );
  }
}
