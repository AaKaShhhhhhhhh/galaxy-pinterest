import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';
import '../../core/widgets/common.dart';
import '../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final signedIn = ref.watch(sessionProvider) != 'guest';
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 14),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Make it yours',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          SwitchListTile.adaptive(
            title: const Text('Dark appearance'),
            subtitle: const Text('A little easier on your eyes'),
            value: library.darkMode,
            onChanged: (v) => perform(
              context,
              () => ref.read(libraryProvider.notifier).darkMode(v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.visibility_outlined),
            title: const Text('Reset hidden Pins'),
            subtitle: Text('${library.hidden.length} Pins hidden'),
            onTap: () => perform(
              context,
              () => ref.read(libraryProvider.notifier).unhideAll(),
              success: 'Hidden Pins will appear in your feed again',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Clear search history'),
            onTap: () => perform(
              context,
              () => ref.read(libraryProvider.notifier).clearSearches(),
              success: 'Search history cleared',
            ),
          ),
          const Divider(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            leading: Icon(signedIn ? Icons.logout : Icons.login),
            title: Text(signedIn ? 'Log out' : 'Log in or sign up'),
            onTap: () async {
              if (!signedIn) {
                context.push('/auth');
                return;
              }
              if (AppConfig.hasClerk && !kIsWeb) {
                final success = await perform(
                  context,
                  () => ClerkAuth.of(context).signOut(),
                );
                if (success && context.mounted) {
                  context.go('/home');
                }
              }
            },
          ),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About this app'),
            subtitle: const Text('Galaxy.ai internship assignment · v1.0.0'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Galaxy Pinterest',
              applicationVersion: '1.0.0',
              children: [
                const Text(
                  'An educational Pinterest-inspired Flutter application. Independently built for an internship assignment; not affiliated with Pinterest.',
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(
              'Photos provided by ${AppConfig.hasUnsplash ? 'Unsplash' : 'Pexels'}',
            ),
            subtitle: const Text(
              'Discover the photographers behind your inspiration',
            ),
            onTap: () => launchUrl(
              Uri.parse(
                AppConfig.hasUnsplash
                    ? 'https://unsplash.com/?utm_source=galaxy_pinterest&utm_medium=referral'
                    : 'https://www.pexels.com/',
              ),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy'),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Your privacy'),
                content: const SingleChildScrollView(
                  child: Text(
                    'Boards, likes, created Pins, search history and profile edits are stored on this device, separately for guests and each signed-in account. They are not synced to other devices.\n\nClerk handles sign-in and session data. Searches and media requests go to the configured photo provider. Unsplash receives image-view and download events as required by its API.\n\nNo analytics or advertising SDKs are included. Removing the app clears its local collection.',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
