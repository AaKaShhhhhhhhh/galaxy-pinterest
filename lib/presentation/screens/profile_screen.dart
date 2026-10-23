import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/common.dart';
import '../providers/providers.dart';
import '../widgets/pin_grid.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final guest = ref.watch(sessionProvider) == 'guest';
    final created = library.pins.values.where((p) => p.isCreated).toList();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
              child: Column(
                children: [
                  Avatar(name: library.name, size: 110),
                  const SizedBox(height: 18),
                  Text(
                    library.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.6,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '@${library.username}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    library.bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    '${library.pinsFor(null).length} saved ${library.pinsFor(null).length == 1 ? 'Pin' : 'Pins'} · ${library.boards.length} ${library.boards.length == 1 ? 'board' : 'boards'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 23),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => _editProfile(context, ref),
                        child: const Text('Edit profile'),
                      ),
                      FilledButton(
                        onPressed: () =>
                            context.push(guest ? '/auth' : '/settings'),
                        child: Text(guest ? 'Log in' : 'Account'),
                      ),
                    ],
                  ),
                  if (guest) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Browsing as a guest · saved on this device',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                'Created Pins',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ),
          ),
          if (created.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.auto_awesome_outlined,
                title: 'A space for your creativity',
                message:
                    'Create a Pin to share your perspective with your own collection.',
                action: FilledButton(
                  onPressed: () => context.push('/create'),
                  child: const Text('Create Pin'),
                ),
              ),
            )
          else
            PinGrid(pins: created, heroPrefix: 'profile'),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
  final profile = ref.read(libraryProvider);
  final name = TextEditingController(text: profile.name),
      username = TextEditingController(text: profile.username),
      bio = TextEditingController(text: profile.bio);
  final form = GlobalKey<FormState>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit profile',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: name,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: username,
                maxLength: 30,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) =>
                    RegExp(r'^[a-zA-Z0-9_]{3,30}$').hasMatch(v?.trim() ?? '')
                    ? null
                    : 'Use 3–30 letters, numbers or underscores',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bio,
                maxLength: 200,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'About you'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  if (!form.currentState!.validate()) {
                    return;
                  }
                  final success = await perform(
                    context,
                    () => ref
                        .read(libraryProvider.notifier)
                        .profile(name.text, username.text, bio.text),
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  // Keep controllers alive until the bottom sheet's exit animation completes.
  await Future<void>.delayed(const Duration(milliseconds: 350));
  name.dispose();
  username.dispose();
  bio.dispose();
}
