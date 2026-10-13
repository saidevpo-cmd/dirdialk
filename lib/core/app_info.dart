/// Static application metadata.
///
/// Kept as plain constants so the app works offline on Android and Web without
/// adding a platform plugin dependency.
class AppInfo {
  const AppInfo._();

  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const String contactEmail = 'support@diali.app';

  /// Version of the privacy policy and terms bundled with the app.
  static const String policyVersion = '1.0.0';

  /// ISO date shown as "last updated" in the policy pages.
  static const String policyUpdatedOn = '2026-10-08';
}
