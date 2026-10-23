import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/widgets/common.dart';
import '../../core/services/file_service.dart';
import '../../domain/entities/pin.dart';
import '../providers/providers.dart';
import 'pin_image.dart';
import 'board_sheet.dart';

class PinRouteData {
  const PinRouteData(this.pin, this.heroTag);
  final Pin pin;
  final String heroTag;
}

class PinCard extends ConsumerStatefulWidget {
  const PinCard({
    super.key,
    required this.pin,
    required this.heroPrefix,
    this.boardId,
  });
  final Pin pin;
  final String heroPrefix;
  final String? boardId;
  @override
  ConsumerState<PinCard> createState() => _PinCardState();
}

class _PinCardState extends ConsumerState<PinCard> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    final pin = widget.pin;
    final saved = ref.watch(libraryProvider.select((s) => s.isSaved(pin.id)));
    final tag = '${widget.heroPrefix}-${pin.id}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => pressed = true),
          onTapCancel: () => setState(() => pressed = false),
          onTapUp: (_) => setState(() => pressed = false),
          onTap: () {
            haptic();
            context.push('/pin/${pin.id}', extra: PinRouteData(pin, tag));
          },
          onLongPress: () {
            haptic();
            pinOptions(context, ref, pin, boardId: widget.boardId);
          },
          child: Semantics(
            button: true,
            label: 'Open ${pin.title}',
            child: AnimatedScale(
              scale: pressed ? .97 : 1,
              duration: const Duration(milliseconds: 100),
              child: Hero(
                tag: tag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: pin.aspectRatio,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PinImage(pin: pin),
                        if (pin.isVideo)
                          const Positioned(
                            left: 10,
                            top: 10,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        if (saved)
                          const Positioned(
                            right: 10,
                            bottom: 10,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.check,
                                size: 17,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    pin.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 21,
                  tooltip: 'More options for ${pin.title}',
                  onPressed: () =>
                      pinOptions(context, ref, pin, boardId: widget.boardId),
                  icon: const Icon(Icons.more_horiz),
                ),
              ),
            ],
          ),
        ),
        if (pin.source == 'Unsplash')
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 1),
            child: InkWell(
              onTap: () => launchUrl(
                Uri.parse(pin.creatorUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                '${pin.creator} · Unsplash',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .55),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> pinOptions(
  BuildContext context,
  WidgetRef ref,
  Pin pin, {
  String? boardId,
}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  builder: (sheetContext) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'More ideas, your way',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 15),
          ListTile(
            leading: const Icon(Icons.push_pin_outlined),
            title: const Text('Save to board'),
            onTap: () {
              Navigator.pop(sheetContext);
              chooseBoard(context, pin);
            },
          ),
          ListTile(
            leading: const Icon(Icons.ios_share_rounded),
            title: const Text('Share Pin'),
            onTap: () {
              Navigator.pop(sheetContext);
              perform(
                context,
                () => FileService().sharePin(pin, shareOrigin(context)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Download image'),
            onTap: () {
              Navigator.pop(sheetContext);
              perform(context, () async {
                final origin = shareOrigin(context);
                await ref.read(repositoryProvider).registerDownload(pin);
                await FileService().exportImage(pin, origin);
              });
            },
          ),
          if (boardId != null)
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove from this board'),
              onTap: () {
                Navigator.pop(sheetContext);
                perform(
                  context,
                  () => ref
                      .read(libraryProvider.notifier)
                      .removePin(pin.id, boardId),
                  success: 'Pin removed',
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.visibility_off_outlined),
            title: const Text('Hide Pin from your feed'),
            onTap: () {
              Navigator.pop(sheetContext);
              perform(
                context,
                () => ref.read(libraryProvider.notifier).hide(pin.id),
                success: 'Pin hidden. You can reset hidden Pins in Settings.',
              );
            },
          ),
        ],
      ),
    ),
  ),
);
