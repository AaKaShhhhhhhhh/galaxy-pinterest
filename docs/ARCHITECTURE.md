# Architecture decisions

## Boundaries and dependencies

Presentation depends on domain entities and use cases. The repository interface is defined in `domain/repositories`; `data/repositories` implements it using dedicated remote/demo sources. A separate domain `LibraryRepository` contract isolates collection persistence, and the `SavePin` use case owns idempotent board-membership rules. `core/services` supplies network, persistence, and media infrastructure. Domain files do not depend on Flutter, Riverpod, Dio, or platform APIs.

The app is intentionally a client application: Pexels/Unsplash provide assets, Clerk handles identity, and SharedPreferences stores the device collection. There is no fabricated backend or implicit cloud synchronization.

## State ownership

- `cacheProvider`: injected once after asynchronous bootstrap; tests replace it with in-memory preferences.
- `repositoryProvider`: selects configured image providers, normalizes media, and provides cached metadata fallback.
- `feedProvider(query, videos)`: owns independent request state. Requests have a generation number, so refreshes supersede earlier work. Overlapping pagination requests are blocked, repeated IDs are deduplicated, and failures preserve successful pages.
- `libraryProvider`: changes with `sessionProvider`. A guest and each Clerk user ID have distinct storage keys. Mutations run through a serialized queue and update state only after successful persistence.
- Screen-local controllers: text editing, selected tabs, and transient pressed/busy flags. Domain records never depend on widget state.

## Performance

Lazy `SliverMasonryGrid` creates visible tiles instead of nesting a full masonry grid in a list. Aspect ratios are known before images decode; a clamped range prevents extremely tall source photos from consuming the feed. Network image decodes target 800px, shimmer fills the reserved frame, and disk image caching is provided by the required package. Category pages keep their scroll state; the bottom navigation uses `StatefulShellRoute.indexedStack`.

Photos have no autoplay video or network work on every build. Video controllers are allocated only in Pin details, initialized muted, paused when the app backgrounds, and disposed on route removal. Search waits 650 ms after typing stops. API metadata is cached for 15 minutes, bounded to 16 first-page query entries. Cached metadata is used after ordinary network failures; explicit refresh reports an error instead of pretending the refresh succeeded.

## Persistence and media

The library is a single versioned JSON snapshot per user. Saved Pin metadata allows boards to survive a restart without re-fetching their photos. Created images are resized/compressed through the native picker, capped at 8 MB, and stored as encoded bytes with their Pin; this avoids invalid temporary paths after a restart, including web preview reloads. For a larger app, migrate user media to SQLite/files or a cloud object store rather than growing preferences indefinitely.

A board's secret flag is an organizational label in this single-device app. It is not presented as server-enforced sharing protection. Sharing and file export use native destination pickers, with iPad share-origin geometry supplied explicitly.

## Authentication and configuration

Only Clerk publishable keys belong in clients. The Flutter SDK supplies actual sign-up/sign-in and session persistence. Sign-out returns to the isolated guest library. Photo-provider keys are kept in ignored local build configuration. Client keys remain extractable from binaries, so a production public app should proxy photo APIs and enforce quotas server-side. No server secrets are included in Flutter source.

Clerk's required Flutter package is a beta native SDK. Browser preview deliberately offers guest functionality; Android and iOS are the submission targets. SDK telemetry is disabled. The service smoke-check script verifies only the configured API/environment endpoints and never prints credentials.

## Validation strategy

Unit tests focus on meaningful failure modes: out-of-order responses, pagination duplication, persistence recovery, account separation, and concurrent writes. Widget tests exercise a user saving a Pin and finding it in a board, plus empty search behavior. Native simulator verification covers rendering, sheets, forms, platform pickers, dark appearance, and Clerk controls. Release APK signing and an iOS simulator recording are separate submission checks.
