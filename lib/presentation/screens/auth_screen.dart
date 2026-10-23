import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Welcome to your next idea')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.red,
                  child: Text(
                    'P',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      fontSize: 52,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (AppConfig.hasClerk && !kIsWeb)
                  ClerkErrorListener(
                    child: ClerkAuthBuilder(
                      signedInBuilder: (context, state) => Column(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                            size: 48,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'You’re in. Make yourself at home.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () => context.go('/saved'),
                            child: const Text('Explore your ideas'),
                          ),
                        ],
                      ),
                      signedOutBuilder: (context, state) => state.isNotAvailable
                          ? const EmptyState(
                              icon: Icons.cloud_off_outlined,
                              title: 'Connecting to your account',
                              message:
                                  'Check your internet connection if this takes a moment.',
                            )
                          : const ClerkAuthentication(),
                    ),
                  )
                else
                  EmptyState(
                    icon: Icons.person_outline_rounded,
                    title: kIsWeb
                        ? 'Take your ideas with you'
                        : 'You’re welcome to explore',
                    message: kIsWeb
                        ? 'Open the Android or iOS app to sign in with Clerk. You can explore and save ideas as a guest in this preview.'
                        : 'Clerk isn’t configured in this build. You can still explore ideas as a guest.',
                    action: FilledButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Explore ideas'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
