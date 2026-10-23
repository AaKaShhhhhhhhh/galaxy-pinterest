# Validation record

Validated on 24 October 2026 (Asia/Kolkata).

- Flutter 3.41.6 / Dart 3.11.4: `flutter analyze --no-pub` reports no issues.
- `flutter test --no-pub`: **13 tests passed**. Includes full save-to-board navigation, native-photo-selection fixture to Create Pin to durable restored image bytes, search empty state, serialized concurrent mutations, account separation, corrupt-cache recovery, stale response protection, deduplicated pagination, and retry behavior.
- Android release build: successful; API 24 minimum, compiled with the installed Android SDK 36 toolchain. Signed using a generated assignment certificate; the private keystore is ignored by Git.
- iOS native app: built and launched on iPhone 17 Pro simulator / iOS 26.5 with Xcode 27.1. Live Unsplash photos, search, likes, board creation/saving, profile edits, dark appearance, restart persistence, and Clerk authentication were exercised.
- Clerk: one explicitly approved reserved development test user was created. SDK sign-up, test-email verification, email-code sign-in, and sign-out passed. The actual iOS UI also completed email-code sign-in, showed a separate account collection, and signed out back to the retained guest data. The test user remains in the development instance; its generated password was not persisted. No real verification email was sent.
- Unsplash: configured free development application authenticated successfully and returned photos and attribution metadata. Native live discovery, topic search, and download registration on saving were exercised.
- Media: the OS photo picker opened on iOS. Its selection gesture was not automated; Create Pin and durable image storage were verified in a widget test with a selected-photo fixture.
- Walkthrough: real simulator recording, 5:26 duration; idle pauses trimmed, no narration. Original 8:46 recording retained locally. Sampled frames were reviewed; no provider keys or user passwords appear in the video.
- Publication: configured API values, signing files, APKs, and recordings are excluded from the source repository. A staged-source scan checks actual configured key values before publishing.

## Practical limits

Collections are local to each device/account. Cloud board sync and social messaging are outside this implementation. Unsplash's demo quota is 50 API requests per hour; video discovery requires an existing Pexels key. The required Clerk Flutter SDK is a native beta package. iOS App Store signing/distribution is not configured; the assignment requests an iOS walkthrough rather than a distributed iOS build. A physical Android device was not attached, so Android verification is release compilation and signature verification, while runtime UI validation was performed on iOS.
