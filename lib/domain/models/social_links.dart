/// Public social-media / contact links shown on the storefront.
///
/// These are business presentation links (not customer data), stored in the
/// single public `site_settings.social_links` jsonb column. The database only
/// accepts the six platforms below and requires each value to be an object
/// with a string `url` of at most 300 characters (see
/// `20261015120000_checkout_integrity_social_and_location.sql`), so this model
/// mirrors exactly that shape.
///
/// Only http(s) URLs (or, for WhatsApp, a bare phone number) are accepted;
/// validation here keeps the client from writing something the DB would
/// reject or a user could not follow.
library;

enum SocialPlatform { instagram, facebook, tiktok, whatsapp, youtube, linkedin }

/// A single platform → URL pairing.
class SocialLink {
  const SocialLink({required this.platform, required this.url});

  final SocialPlatform platform;
  final String url;
}

class SocialLinks {
  const SocialLinks([this._byPlatform = const {}]);

  static const SocialLinks empty = SocialLinks();

  /// Platform name → validated URL. Keys are [SocialPlatform.name] so they
  /// line up with the jsonb object keys the database validates.
  final Map<SocialPlatform, String> _byPlatform;

  bool get isEmpty => all.isEmpty;
  bool get isNotEmpty => all.isNotEmpty;

  /// Platforms with a link, in a stable display order.
  List<SocialLink> get all => [
        for (final platform in SocialPlatform.values)
          if ((_byPlatform[platform] ?? '').isNotEmpty)
            SocialLink(platform: platform, url: _byPlatform[platform]!),
      ];

  String? url(SocialPlatform platform) {
    final value = _byPlatform[platform];
    return (value == null || value.isEmpty) ? null : value;
  }

  String? get whatsappUrl => url(SocialPlatform.whatsapp);

  /// Returns a new set with [platform] set (or removed when [raw] is blank).
  /// Invalid values are ignored so a typo never becomes a broken link.
  SocialLinks withLink(SocialPlatform platform, String raw) {
    final next = Map<SocialPlatform, String>.from(_byPlatform);
    final normalized = normalize(platform, raw);
    if (normalized == null) {
      next.remove(platform);
    } else {
      next[platform] = normalized;
    }
    return SocialLinks(next);
  }

  /// The jsonb shape the database expects: `{ "instagram": { "url": "..." } }`.
  /// Only valid entries are emitted.
  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{};
    for (final platform in SocialPlatform.values) {
      final value = _byPlatform[platform];
      if (value == null || value.isEmpty) continue;
      out[platform.name] = {'url': value};
    }
    return out;
  }

  /// Reads the jsonb shape emitted by [toJson]. Malformed or unknown entries
  /// are skipped rather than throwing, so one bad row never breaks the
  /// storefront.
  factory SocialLinks.fromJson(Object? json) {
    if (json is! Map) return SocialLinks.empty;
    final map = <SocialPlatform, String>{};
    for (final platform in SocialPlatform.values) {
      final entry = json[platform.name];
      if (entry is Map) {
        final url = entry['url'];
        if (url is String && url.trim().isNotEmpty) {
          map[platform] = url.trim();
        }
      } else if (entry is String && entry.trim().isNotEmpty) {
        // Tolerate a bare string, in case a row is hand-edited.
        map[platform] = entry.trim();
      }
    }
    return map.isEmpty ? SocialLinks.empty : SocialLinks(map);
  }

  /// Validates and normalises one link.
  ///
  /// * WhatsApp also accepts a bare phone number, which is converted to a
  ///   `https://wa.me/<digits>` deep link (this is the common way a business
  ///   shares a chat contact).
  /// * Every other platform requires an `http`/`https` URL with a host.
  /// * Anything longer than the DB's 300-character limit is rejected.
  ///
  /// Returns `null` when [raw] is blank or invalid.
  static String? normalize(SocialPlatform platform, String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    if (platform == SocialPlatform.whatsapp && !_hasScheme(value)) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 7 && digits.length <= 15) {
        return 'https://wa.me/$digits';
      }
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return null;
    if (!(uri.isScheme('http') || uri.isScheme('https'))) return null;
    if (value.length > maxUrlLength) return null;
    return value;
  }

  static const int maxUrlLength = 300;

  static bool _hasScheme(String value) =>
      value.contains('://') || value.startsWith('//');

  /// Builds a WhatsApp chat URL, optionally prefilling the message body.
  /// Returns `null` when there is no (valid) WhatsApp link configured.
  static String? whatsappChatUrl(String? url, {String? text}) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url;
    if (text == null || text.trim().isEmpty) return url;
    return uri
        .replace(queryParameters: {...uri.queryParameters, 'text': text})
        .toString();
  }
}
