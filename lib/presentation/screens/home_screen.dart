import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../providers/providers.dart';
import '../widgets/pin_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final pager = PageController();
  final topics = ['For you', 'Interiors', 'Style', 'Travel', 'Food', 'Art'];
  int selected = 0;
  @override
  void dispose() {
    pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 8, 10, 4),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.red,
                child: Text(
                  'P',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
                    fontSize: 27,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'For you',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.7,
                ),
              ),
              const Spacer(),
              if (!AppConfig.hasLiveImages)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    'Demo',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              IconButton(
                tooltip: 'Your profile',
                onPressed: () => context.push('/profile'),
                icon: Avatar(
                  name: ref.watch(libraryProvider.select((s) => s.name)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 62,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 7, 12, 10),
            children: List.generate(
              topics.length,
              (i) => Pill(
                label: topics[i],
                selected: i == selected,
                onTap: () {
                  setState(() => selected = i);
                  pager.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: pager,
            onPageChanged: (i) => setState(() => selected = i),
            children: List.generate(
              topics.length,
              (i) => FeedView(
                scrollKey: 'home-${topics[i]}',
                query: (query: i == 0 ? '' : topics[i], videos: false),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
