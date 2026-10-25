import 'package:url_launcher/url_launcher.dart';

/// Opens external links (social profiles, WhatsApp chats) from the storefront.
///
/// Only `http`/`https` URLs are launched — the same scheme rule the
/// `site_settings.social_links` data is validated with — so a malformed or
/// unexpected value can never trigger another URI scheme.
abstract final class ExternalLinks {
  static Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (!(uri.isScheme('http') || uri.isScheme('https'))) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // No handler (desktop preview, tests) — fail quietly, the caller shows
      // a snackbar if it needs to.
      return false;
    }
  }
}
