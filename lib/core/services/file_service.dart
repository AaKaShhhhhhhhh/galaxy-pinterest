import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/pin.dart';

class FileService {
  Future<Uint8List?> pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      imageQuality: 88,
    );
    if (file == null) {
      return null;
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > 8 * 1024 * 1024) {
      throw StateError('Choose an image smaller than 8 MB.');
    }
    return bytes;
  }

  Future<void> sharePin(Pin pin, Rect origin) async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            '${pin.title}\n${pin.sourceUrl.isEmpty ? 'An idea from my collection' : pin.sourceUrl}',
        sharePositionOrigin: origin,
      ),
    );
  }

  Future<void> exportImage(Pin pin, Rect origin) async {
    final Uint8List bytes;
    if (pin.imageBase64 != null) {
      bytes = base64Decode(pin.imageBase64!);
    } else if (pin.assetPath != null) {
      bytes = (await rootBundle.load(pin.assetPath!)).buffer.asUint8List();
    } else {
      final response = await Dio().get<List<int>>(
        pin.imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      bytes = Uint8List.fromList(response.data!);
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'image/jpeg')],
        fileNameOverrides: ['pin-${pin.id}.jpg'],
        text: 'Photo by ${pin.creator} on ${pin.source}',
        sharePositionOrigin: origin,
      ),
    );
  }
}

Rect shareOrigin(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  return box == null
      ? const Rect.fromLTWH(0, 0, 100, 100)
      : box.localToGlobal(Offset.zero) & box.size;
}
