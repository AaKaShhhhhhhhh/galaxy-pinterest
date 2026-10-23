import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/common.dart';
import '../../domain/entities/board.dart';
import '../providers/providers.dart';
import '../widgets/board_sheet.dart';
import '../widgets/pin_grid.dart';
import '../widgets/pin_image.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});
  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  int tab = 0;
  String filter = '';
  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    final boards = library.boards
        .where((b) => b.name.toLowerCase().contains(filter.toLowerCase()))
        .toList();
    final pins = tab == 2
        ? library.pins.values.where((p) => p.isCreated).toList()
        : library.pinsFor(null);
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey('saved'),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
              child: Row(
                children: [
                  const Text(
                    'Your saved ideas',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.6,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Profile',
                    onPressed: () => context.push('/profile'),
                    icon: Avatar(name: library.name),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Row(
                children: [
                  Pill(
                    label: 'Boards',
                    selected: tab == 0,
                    onTap: () => setState(() => tab = 0),
                  ),
                  Pill(
                    label: 'Pins',
                    selected: tab == 1,
                    onTap: () => setState(() => tab = 1),
                  ),
                  Pill(
                    label: 'Created',
                    selected: tab == 2,
                    onTap: () => setState(() => tab = 2),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Create board',
                    onPressed: () => editBoard(context),
                    icon: const Icon(Icons.add, size: 28),
                  ),
                ],
              ),
            ),
          ),
          if (tab == 0) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search your boards',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => filter = v),
                ),
              ),
            ),
            if (boards.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.dashboard_outlined,
                  title: 'Make room for your ideas',
                  message: 'Create a board to start collecting what you love.',
                  action: FilledButton(
                    onPressed: () => editBoard(context),
                    child: const Text('Create board'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisExtent: 230,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: boards.length,
                  itemBuilder: (context, i) => _BoardCard(board: boards[i]),
                ),
              ),
          ] else if (pins.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: tab == 2
                    ? Icons.add_photo_alternate_outlined
                    : Icons.push_pin_outlined,
                title: tab == 2
                    ? 'Your ideas belong here'
                    : 'See it. Love it. Save it.',
                message: tab == 2
                    ? 'Turn your photos into Pins, and keep them in your own boards.'
                    : 'Tap Save on any Pin to start building your collection.',
                action: FilledButton(
                  onPressed: () =>
                      tab == 2 ? context.push('/create') : context.go('/home'),
                  child: Text(tab == 2 ? 'Create a Pin' : 'Find inspiration'),
                ),
              ),
            )
          else
            PinGrid(pins: pins, heroPrefix: 'saved-$tab'),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _BoardCard extends ConsumerWidget {
  const _BoardCard({required this.board});
  final Board board;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pins = ref.watch(libraryProvider).pinsFor(board.id);
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget tile(int i) =>
        pins.length > i ? PinImage(pin: pins[i]) : ColoredBox(color: bg);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push('/board/${board.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 162,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (pins.isEmpty)
                    ColoredBox(
                      color: bg,
                      child: Icon(
                        Icons.push_pin_outlined,
                        size: 35,
                        color: Colors.grey.shade400,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox.expand(child: tile(0)),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(child: SizedBox.expand(child: tile(1))),
                              const SizedBox(height: 2),
                              Expanded(child: SizedBox.expand(child: tile(2))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (board.isSecret)
                    const Positioned(
                      bottom: 10,
                      left: 10,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              board.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 3),
            child: Text(
              '${pins.length} ${pins.length == 1 ? 'Pin' : 'Pins'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final matches = library.boards.where((b) => b.id == id);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.dashboard_outlined,
          title: 'Board not found',
          message: 'Return to your saved ideas to find another board.',
        ),
      );
    }
    final board = matches.first, pins = library.pinsFor(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(board.name),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Board options',
            onSelected: (value) async {
              if (value == 'edit') {
                await editBoard(context, board: board);
                return;
              }
              final approved = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete board?'),
                  content: const Text(
                    'This removes the board and its saved Pins from your collection.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (approved == true && context.mounted) {
                final success = await perform(
                  context,
                  () => ref.read(libraryProvider.notifier).deleteBoard(id),
                );
                if (success && context.mounted) {
                  context.pop();
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit board')),
              PopupMenuItem(value: 'delete', child: Text('Delete board')),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                children: [
                  if (board.description.isNotEmpty)
                    Text(
                      board.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    '${pins.length} ${pins.length == 1 ? 'Pin' : 'Pins'}${board.isSecret ? ' · Secret board' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          if (pins.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.push_pin_outlined,
                title: 'Imagine the possibilities',
                message:
                    'The beginning of something you’ll love. Find an idea and save it here.',
                action: FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Find ideas'),
                ),
              ),
            )
          else
            PinGrid(pins: pins, heroPrefix: 'board-$id', boardId: id),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}
