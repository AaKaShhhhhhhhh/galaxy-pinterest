import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/common.dart';
import '../providers/providers.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(libraryProvider.select((s) => s.activity));
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey('updates'),
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Text(
                'Updates',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.5,
                ),
              ),
            ),
          ),
          if (activity.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'Your inspiration, in motion',
                message:
                    'Your saved Pins and new boards will appear here. Let’s find something you love.',
                action: FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Explore ideas'),
                ),
              ),
            )
          else ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Your recent activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: activity.length,
              itemBuilder: (context, i) => ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xfffce4e8),
                  child: Icon(
                    Icons.push_pin_outlined,
                    color: Color(0xffe60023),
                  ),
                ),
                title: Text(
                  activity[i],
                  style: const TextStyle(fontSize: 14, height: 1.45),
                ),
                subtitle: Text(
                  i == 0 ? 'Latest activity' : 'In your collection',
                ),
                onTap: () => context.go('/saved'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
