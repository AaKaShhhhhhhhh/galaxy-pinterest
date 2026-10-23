import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../core/services/file_service.dart';
import '../../core/widgets/common.dart';
import '../../domain/entities/pin.dart';
import '../providers/providers.dart';
import '../providers/feed_controller.dart';
import '../widgets/board_sheet.dart';
import '../widgets/pin_card.dart';
import '../widgets/pin_grid.dart';
import '../widgets/pin_image.dart';

class PinDetailScreen extends ConsumerWidget {
  const PinDetailScreen({super.key, required this.id, this.data});
  final String id;
  final PinRouteData? data;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pin = data?.pin;
    if (pin != null) {
      return _Detail(pin: pin, heroTag: data!.heroTag);
    }
    return ref
        .watch(pinProvider(id))
        .when(
          data: (p) => p == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const EmptyState(
                    icon: Icons.push_pin_outlined,
                    title: 'This Pin isn’t here',
                    message:
                        'It may have been removed. There are plenty more ideas to explore.',
                  ),
                )
              : _Detail(pin: p, heroTag: 'detail-$id'),
          error: (e, s) => Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.cloud_off,
              title: 'Couldn’t load this Pin',
              message: 'Please check your connection.',
              action: FilledButton(
                onPressed: () => ref.invalidate(pinProvider(id)),
                child: const Text('Try again'),
              ),
            ),
          ),
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
        );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.pin, required this.heroTag});
  final Pin pin;
  final String heroTag;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(libraryProvider.select((s) => s.isSaved(pin.id)));
    final liked = ref.watch(
      libraryProvider.select((s) => s.likes.contains(pin.id)),
    );
    final related = ref.watch(
      feedProvider((
        query: pin.category == 'For you' ? '' : pin.category,
        videos: false,
      )),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: _FloatingIcon(
            icon: Icons.arrow_back_rounded,
            label: 'Back',
            onTap: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _FloatingIcon(
              icon: Icons.more_horiz,
              label: 'More options',
              onTap: () => pinOptions(context, ref, pin),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: Hero(
                        tag: heroTag,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(28),
                          ),
                          child: AspectRatio(
                            aspectRatio: pin.aspectRatio,
                            child: pin.isVideo
                                ? _VideoPin(pin: pin)
                                : PinImage(pin: pin),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              tooltip: liked ? 'Unlike Pin' : 'Like Pin',
                              onPressed: () {
                                haptic();
                                perform(
                                  context,
                                  () => ref
                                      .read(libraryProvider.notifier)
                                      .like(pin),
                                );
                              },
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                child: Icon(
                                  liked
                                      ? Icons.favorite
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(liked),
                                  color: liked ? const Color(0xffe60023) : null,
                                  size: 29,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Share Pin',
                              icon: const Icon(
                                Icons.ios_share_rounded,
                                size: 27,
                              ),
                              onPressed: () => perform(
                                context,
                                () => FileService().sharePin(
                                  pin,
                                  shareOrigin(context),
                                ),
                              ),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: () => chooseBoard(context, pin),
                              style: FilledButton.styleFrom(
                                backgroundColor: saved
                                    ? Theme.of(context).colorScheme.onSurface
                                    : null,
                                foregroundColor: saved
                                    ? Theme.of(context).colorScheme.surface
                                    : null,
                              ),
                              child: Text(saved ? 'Saved' : 'Save'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          pin.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.18,
                            letterSpacing: -.5,
                          ),
                        ),
                        if (pin.description.isNotEmpty &&
                            pin.description != pin.title) ...[
                          const SizedBox(height: 10),
                          Text(
                            pin.description,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Avatar(name: pin.creator, size: 42),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: pin.creatorUrl.isEmpty
                                        ? null
                                        : () => launchUrl(
                                            Uri.parse(pin.creatorUrl),
                                            mode:
                                                LaunchMode.externalApplication,
                                          ),
                                    child: Text(
                                      pin.creator,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Photo on ${pin.source}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (pin.sourceUrl.isNotEmpty)
                              OutlinedButton(
                                onPressed: () => perform(context, () async {
                                  if (!await launchUrl(
                                    Uri.parse(pin.sourceUrl),
                                    mode: LaunchMode.externalApplication,
                                  )) {
                                    throw StateError('Could not open source');
                                  }
                                }),
                                child: const Text('Visit'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  'More like this',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (related.pins.isNotEmpty)
              PinGrid(
                pins: related.pins.where((p) => p.id != pin.id).toList(),
                heroPrefix: 'related-${pin.id}',
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 35)),
          ],
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: .95),
    shape: const CircleBorder(),
    child: IconButton(
      tooltip: label,
      icon: Icon(icon, size: 26),
      onPressed: onTap,
    ),
  );
}

class _VideoPin extends StatefulWidget {
  const _VideoPin({required this.pin});
  final Pin pin;
  @override
  State<_VideoPin> createState() => _VideoPinState();
}

class _VideoPinState extends State<_VideoPin> with WidgetsBindingObserver {
  late final VideoPlayerController controller;
  String? error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.pin.videoUrl!),
    );
    controller
        .initialize()
        .then((_) async {
          await controller.setLooping(true);
          await controller.setVolume(0);
          if (mounted) {
            setState(() {});
          }
        })
        .catchError((Object e) {
          if (mounted) {
            setState(() => error = 'Couldn’t load this video');
          }
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (controller.value.isInitialized)
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        )
      else
        PinImage(pin: widget.pin),
      Center(
        child: error != null
            ? Text(error!, style: const TextStyle(color: Colors.white))
            : IconButton.filled(
                tooltip: controller.value.isPlaying
                    ? 'Pause video'
                    : 'Play video',
                iconSize: 42,
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                onPressed: !controller.value.isInitialized
                    ? null
                    : () async {
                        if (controller.value.isPlaying) {
                          await controller.pause();
                        } else {
                          await controller.play();
                        }
                        if (mounted) {
                          setState(() {});
                        }
                      },
                icon: Icon(
                  controller.value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              ),
      ),
    ],
  );
}
