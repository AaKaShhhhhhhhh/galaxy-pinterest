import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../domain/entities/pin.dart';
import '../../core/widgets/common.dart';
import '../providers/feed_controller.dart';
import '../providers/providers.dart';
import 'pin_card.dart';
import 'pin_image.dart';

class PinGrid extends StatelessWidget {
  const PinGrid({
    super.key,
    required this.pins,
    required this.heroPrefix,
    this.boardId,
  });
  final List<Pin> pins;
  final String heroPrefix;
  final String? boardId;
  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    sliver: SliverLayoutBuilder(
      builder: (context, constraints) => SliverMasonryGrid.count(
        crossAxisCount: constraints.crossAxisExtent < 600
            ? 2
            : (constraints.crossAxisExtent / 220).floor().clamp(2, 6),
        mainAxisSpacing: 16,
        crossAxisSpacing: 10,
        childCount: pins.length,
        itemBuilder: (context, index) => PinCard(
          key: ValueKey(pins[index].id),
          pin: pins[index],
          heroPrefix: heroPrefix,
          boardId: boardId,
        ),
      ),
    ),
  );
}

class FeedView extends ConsumerStatefulWidget {
  const FeedView({
    super.key,
    this.query = defaultFeed,
    this.header,
    this.scrollKey = 'feed',
  });
  final FeedQuery query;
  final Widget? header;
  final String scrollKey;
  @override
  ConsumerState<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends ConsumerState<FeedView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(feedProvider(widget.query));
    final hidden = ref.watch(libraryProvider.select((s) => s.hidden));
    final pins = state.pins.where((p) => !hidden.contains(p.id)).toList();
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 700 && state.pageError == null) {
          ref.read(feedProvider(widget.query).notifier).next();
        }
        return false;
      },
      child: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: () =>
            ref.read(feedProvider(widget.query).notifier).refresh(force: true),
        child: CustomScrollView(
          key: PageStorageKey(widget.scrollKey),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (widget.header != null) SliverToBoxAdapter(child: widget.header),
            if (state.loading)
              const SliverToBoxAdapter(child: GridSkeleton())
            else if (pins.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: state.error == null
                      ? Icons.search_rounded
                      : Icons.cloud_off_outlined,
                  title: state.error == null
                      ? 'A fresh start for your ideas'
                      : 'Let’s try that again',
                  message:
                      state.error ??
                      (widget.query.videos
                          ? 'Add a Pexels API key to explore video Pins.'
                          : 'No Pins found. Try another search or topic.'),
                  action: state.error == null
                      ? null
                      : FilledButton(
                          onPressed: () => ref
                              .read(feedProvider(widget.query).notifier)
                              .refresh(force: true),
                          child: const Text('Try again'),
                        ),
                ),
              )
            else ...[
              if (state.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(state.error!),
                  ),
                ),
              PinGrid(pins: pins, heroPrefix: widget.scrollKey),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: state.loadingMore
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : state.pageError != null
                        ? TextButton.icon(
                            onPressed: () => ref
                                .read(feedProvider(widget.query).notifier)
                                .next(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Load more · try again'),
                          )
                        : !state.hasMore
                        ? Text(
                            'You’re all caught up. Keep feeling inspired.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: .5),
                            ),
                          )
                        : const SizedBox(height: 24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
