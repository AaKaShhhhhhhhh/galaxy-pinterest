/// Compile-time configuration. Never ship Clerk secret keys in a mobile client.
abstract final class AppConfig {
  static const unsplashAccessKey = String.fromEnvironment(
    'UNSPLASH_ACCESS_KEY',
  );
  static const hasUnsplash = unsplashAccessKey != '';
  static const hasLiveImages = hasUnsplash || hasPexels;
  static const pexelsApiKey = String.fromEnvironment('PEXELS_API_KEY');
  static const clerkPublishableKey = String.fromEnvironment(
    'CLERK_PUBLISHABLE_KEY',
  );
  static const hasPexels = pexelsApiKey != '';
  static const hasClerk = clerkPublishableKey != '';
}
