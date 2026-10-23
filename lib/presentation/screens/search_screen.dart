import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/common.dart';
import '../providers/providers.dart';
import '../widgets/pin_grid.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final controller = TextEditingController();
  Timer? debounce;
  String query = '';
  bool videos = false;
  final topics = const [
    ('Interiors', 'Make yourself at home', '1571460'),
    ('Travel', 'Your next adventure', '2662116'),
    ('Style', 'Find your everyday style', '1488463'),
    ('Food', 'Something delicious', '1640777'),
    ('Art', 'Let creativity happen', '1266808'),
    ('Flowers', 'A little joy in bloom', '102104'),
  ];
  @override
  void dispose() {
    debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  void submit(String value) {
    debounce?.cancel();
    final q = value.trim();
    controller.text = q;
    setState(() => query = q);
    FocusScope.of(context).unfocus();
    if (q.isNotEmpty) {
      perform(context, () => ref.read(libraryProvider.notifier).search(q));
    }
  }

  @override
  Widget build(BuildContext context) {
    final recent = ref.watch(libraryProvider.select((s) => s.searches));
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search for ideas',
                prefixIcon: const Icon(Icons.search_rounded, size: 26),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          controller.clear();
                          debounce?.cancel();
                          setState(() => query = '');
                        },
                      ),
              ),
              onSubmitted: submit,
              onChanged: (v) {
                setState(() {});
                debounce?.cancel();
                debounce = Timer(const Duration(milliseconds: 650), () {
                  if (mounted) {
                    setState(() => query = v.trim());
                  }
                });
              },
            ),
          ),
          if (query.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Pill(
                    label: 'All Pins',
                    selected: !videos,
                    onTap: () => setState(() => videos = false),
                  ),
                  Pill(
                    label: 'Videos',
                    selected: videos,
                    onTap: () => setState(() => videos = true),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FeedView(
                key: ValueKey('$query-$videos'),
                query: (query: query, videos: videos),
                scrollKey: 'search-$query-$videos',
              ),
            ),
          ] else
            Expanded(
              child: CustomScrollView(
                key: const PageStorageKey('discover'),
                slivers: [
                  if (recent.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Recent searches',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => perform(
                                    context,
                                    () => ref
                                        .read(libraryProvider.notifier)
                                        .clearSearches(),
                                  ),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: recent
                                  .map(
                                    (r) => ActionChip(
                                      label: Text(r),
                                      avatar: const Icon(
                                        Icons.history,
                                        size: 18,
                                      ),
                                      onPressed: () => submit(r),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find your next',
                            style: TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -.8,
                            ),
                          ),
                          Text(
                            'great idea.',
                            style: TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -.8,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'A little inspiration can lead to something big.',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 280,
                            childAspectRatio: 1.1,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                      itemCount: topics.length,
                      itemBuilder: (context, i) {
                        final t = topics[i];
                        return GestureDetector(
                          onTap: () => submit(t.$1),
                          child: Semantics(
                            button: true,
                            label: 'Explore ${t.$1}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(19),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/images/${t.$3}.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                  const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black87,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 15,
                                    bottom: 16,
                                    right: 12,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.$2,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t.$1,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
