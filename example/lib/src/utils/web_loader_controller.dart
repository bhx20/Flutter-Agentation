library;

/// Centralized web loader controller across all platforms.
/// The web splash loader only activates on initial cold boot and is permanently
/// dismissed once Flutter renders its frame.

/// Shows the HTML splash loader (no-op during in-app navigation).
void showWebLoader() {}

/// Dismisses the HTML splash loader when Flutter renders its frame.
void dismissWebLoader() {}
