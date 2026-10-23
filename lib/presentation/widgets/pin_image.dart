import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/pin.dart';

class PinImage extends StatelessWidget {
  const PinImage({super.key, required this.pin, this.fit = BoxFit.cover});
  final Pin pin;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    if (pin.imageBase64 case final bytes?) {
      return Image.memory(
        base64Decode(bytes),
        fit: fit,
        gaplessPlayback: true,
        semanticLabel: pin.title,
      );
    }
    if (pin.assetPath case final path?) {
      return Image.asset(
        path,
        fit: fit,
        cacheWidth: 800,
        semanticLabel: pin.title,
      );
    }
    return CachedNetworkImage(
      imageUrl: pin.imageUrl,
      fit: fit,
      memCacheWidth: 800,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Color(pin.color),
        highlightColor: Theme.of(context).colorScheme.surface,
        child: ColoredBox(color: Color(pin.color)),
      ),
      errorWidget: (context, url, error) => ColoredBox(
        color: Color(pin.color),
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.black45,
          ),
        ),
      ),
      imageBuilder: (context, provider) =>
          Image(image: provider, fit: fit, semanticLabel: pin.title),
    );
  }
}

class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    highlightColor: Theme.of(context).colorScheme.surface,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          2,
          (col) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      height: (i + col) % 2 == 0 ? 240 : 190,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
