# Galaxy.ai assignment mapping

Source: https://docs.google.com/document/d/1sV0QEmRIVwLqRjE8ByghJ6bXzguupg4y6XwOolwiJYY/edit

The brief specifies a Pinterest mobile clone, Flutter, Clean Architecture, Riverpod, GoRouter, Dio, cached_network_image, shimmer, flutter_staggered_grid_view, and clerk_flutter. It permits Unsplash as an alternative to Pexels. Evaluation weights: UI accuracy 35%, architecture 25%, code quality 20%, performance 20%. Expected assignment duration: five days.

| Requirement | Implementation/evidence |
| --- | --- |
| Flutter Android/iOS app | Native platform projects, `lib/main.dart` |
| All seven specified packages | `pubspec.yaml`, package mapping in README |
| Clean Architecture | `core`, `domain`, `data`, `presentation`; domain has no Flutter imports |
| Riverpod providers, notifiers, controllers | `presentation/providers` |
| Network/cache/file services | `core/services` |
| Image API | Real Unsplash free demo application; Pexels data source also implemented |
| Masonry scrolling and image efficiency | Lazy sliver masonry, bounded decodes, cached network images |
| Pin navigation/animation | GoRouter routes, Hero transition, press animation |
| Search behavior | Debounce, topics, recent search storage, pagination, errors, empty states |
| Loading states | Shimmer grid/images, pagination indicator, inline/error retries |
| Tab scroll retention | Stateful shell, keep-alive category pages, PageStorage keys |
| Micro-interactions | Haptics, animated likes/chips, sheets, pull-to-refresh |
| Android release APK | `flutter build apk --release --dart-define-from-file=config/local.json` |
| iOS 5–10 minute walkthrough | Simulator recording and demonstration guide in `docs/WALKTHROUGH.md` |
| Public GitHub repository | Source is prepared for publishing; local keys/signing files are ignored |

## Honest scope

This is a device-local visual discovery and collection app with real asset APIs and identity. It does not implement cloud board sync, real messaging, social graphs, push notifications, or comments. The Updates screen displays actual local actions, not fabricated notifications. Unsplash supplies photos; Pexels videos are available when an existing Pexels key is configured. The free API quota and beta Clerk SDK are documented.

Validation evidence and practical limits are recorded in [VALIDATION.md](VALIDATION.md).
