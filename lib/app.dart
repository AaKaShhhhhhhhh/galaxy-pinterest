import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/common.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/saved_screen.dart';
import 'presentation/screens/updates_screen.dart';
import 'presentation/screens/pin_detail_screen.dart';
import 'presentation/screens/create_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/widgets/pin_card.dart';

class GalaxyApp extends ConsumerStatefulWidget {
  const GalaxyApp({super.key});
  @override
  ConsumerState<GalaxyApp> createState() => _GalaxyAppState();
}

class _GalaxyAppState extends ConsumerState<GalaxyApp> {
  late final router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _NavigationShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/updates',
                builder: (context, state) => const UpdatesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/pin/:id',
        builder: (context, state) => PinDetailScreen(
          id: state.pathParameters['id']!,
          data: state.extra is PinRouteData
              ? state.extra as PinRouteData
              : null,
        ),
      ),
      GoRoute(
        path: '/board/:id',
        builder: (context, state) =>
            BoardScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/create',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                    .animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.explore_outlined,
        title: 'Let’s find your way back',
        message: 'This page isn’t available.',
        action: FilledButton(
          onPressed: () => context.go('/home'),
          child: const Text('Go home'),
        ),
      ),
    ),
  );
  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Galaxy Pinterest',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.build(Brightness.light),
    darkTheme: AppTheme.build(Brightness.dark),
    themeMode: ref.watch(libraryProvider.select((s) => s.darkMode))
        ? ThemeMode.dark
        : ThemeMode.light,
    routerConfig: router,
  );
}

class AuthRoot extends StatelessWidget {
  const AuthRoot({super.key});
  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasClerk || kIsWeb) {
      return const GalaxyApp();
    }
    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: AppConfig.clerkPublishableKey,
        telemetryPeriod: Duration.zero,
        supportsHardwareSecurityKeys: false,
      ),
      child: ClerkAuthBuilder(
        builder: (context, auth) =>
            _SessionBridge(userId: auth.user?.id, child: const GalaxyApp()),
      ),
    );
  }
}

class _SessionBridge extends ConsumerStatefulWidget {
  const _SessionBridge({required this.userId, required this.child});
  final String? userId;
  final Widget child;
  @override
  ConsumerState<_SessionBridge> createState() => _SessionBridgeState();
}

class _SessionBridgeState extends ConsumerState<_SessionBridge> {
  @override
  Widget build(BuildContext context) {
    final id = widget.userId ?? 'guest';
    if (ref.read(sessionProvider) != id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(sessionProvider.notifier).state = id;
        }
      });
    }
    return widget.child;
  }
}

class _NavigationShell extends ConsumerWidget {
  const _NavigationShell({required this.shell});
  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final current = shell.currentIndex < 2
        ? shell.currentIndex
        : shell.currentIndex + 1;
    const icons = [
      Icons.home_filled,
      Icons.search_rounded,
      Icons.add_rounded,
      Icons.notifications_none_rounded,
      Icons.person_outline_rounded,
    ];
    const active = [
      Icons.home_filled,
      Icons.search_rounded,
      Icons.add_rounded,
      Icons.notifications_rounded,
      Icons.person_rounded,
    ];
    const labels = ['Home', 'Search', 'Create', 'Updates', 'Saved'];
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.onSurface.withValues(alpha: .06)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                5,
                (i) => Expanded(
                  child: Semantics(
                    selected: current == i,
                    button: true,
                    label: labels[i],
                    child: InkWell(
                      onTap: () {
                        haptic();
                        if (i == 2) {
                          context.push('/create');
                        } else {
                          shell.goBranch(
                            i < 2 ? i : i - 1,
                            initialLocation: current == i,
                          );
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          i == 4
                              ? Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: current == i
                                          ? colors.onSurface
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Avatar(
                                    name: ref.watch(
                                      libraryProvider.select((s) => s.name),
                                    ),
                                    size: 24,
                                  ),
                                )
                              : Icon(
                                  current == i ? active[i] : icons[i],
                                  size: i == 2 ? 32 : 28,
                                  color: current == i
                                      ? colors.onSurface
                                      : colors.onSurface.withValues(alpha: .5),
                                ),
                          const SizedBox(height: 4),
                          Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: current == i
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: current == i
                                  ? colors.onSurface
                                  : colors.onSurface.withValues(alpha: .55),
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
        ),
      ),
    );
  }
}
