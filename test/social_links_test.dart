import 'package:diali/domain/models/social_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SocialLinks.normalize', () {
    test('accepts http and https URLs with a host', () {
      expect(SocialLinks.normalize(SocialPlatform.instagram,
          'https://instagram.com/diali'), 'https://instagram.com/diali');
      expect(SocialLinks.normalize(SocialPlatform.facebook, 'http://fb.me/x'),
          'http://fb.me/x');
    });

    test('rejects other schemes, missing hosts and over-long values', () {
      expect(SocialLinks.normalize(SocialPlatform.instagram, 'javascript:alert(1)'),
          isNull);
      expect(SocialLinks.normalize(SocialPlatform.instagram, 'ftp://x/y'), isNull);
      expect(SocialLinks.normalize(SocialPlatform.instagram, 'instagram.com/x'),
          isNull);
      expect(SocialLinks.normalize(SocialPlatform.instagram, '   '), isNull);
      expect(
        SocialLinks.normalize(
          SocialPlatform.instagram,
          'https://x.com/${'a' * 400}',
        ),
        isNull,
      );
    });

    test('WhatsApp accepts a bare phone number and builds a wa.me link', () {
      expect(SocialLinks.normalize(SocialPlatform.whatsapp, '+212 600-000-000'),
          'https://wa.me/212600000000');
      expect(SocialLinks.normalize(SocialPlatform.whatsapp, '12345'), isNull);
    });
  });

  group('SocialLinks serialisation', () {
    test('toJson emits the validated jsonb shape', () {
      final links = SocialLinks.empty
          .withLink(SocialPlatform.instagram, 'https://instagram.com/diali')
          .withLink(SocialPlatform.whatsapp, '212600000000');

      expect(links.toJson(), {
        'instagram': {'url': 'https://instagram.com/diali'},
        'whatsapp': {'url': 'https://wa.me/212600000000'},
      });
    });

    test('fromJson tolerates the canonical shape, bare strings and junk', () {
      final links = SocialLinks.fromJson({
        'instagram': {'url': 'https://instagram.com/diali'},
        'facebook': 'https://facebook.com/diali',
        'youtube': {'enabled': true},
        'myspace': {'url': 'https://myspace.com/x'},
      });

      expect(links.url(SocialPlatform.instagram), 'https://instagram.com/diali');
      expect(links.url(SocialPlatform.facebook), 'https://facebook.com/diali');
      expect(links.url(SocialPlatform.youtube), isNull);
      expect(links.all, hasLength(2));
    });

    test('withLink removes an entry when the value is invalid', () {
      final links = SocialLinks.empty
          .withLink(SocialPlatform.instagram, 'https://instagram.com/diali')
          .withLink(SocialPlatform.instagram, 'not a url');

      expect(links.isEmpty, isTrue);
    });

    test('fromJson of a non-map returns empty', () {
      expect(SocialLinks.fromJson(null).isEmpty, isTrue);
      expect(SocialLinks.fromJson('nope').isEmpty, isTrue);
    });
  });

  group('SocialLinks.whatsappChatUrl', () {
    test('appends a prefilled message and preserves the number', () {
      final url = SocialLinks.whatsappChatUrl(
        'https://wa.me/212600000000',
        text: 'Hello Diali',
      );
      expect(url, 'https://wa.me/212600000000?text=Hello+Diali');
    });

    test('returns null without a configured link', () {
      expect(SocialLinks.whatsappChatUrl(null), isNull);
      expect(SocialLinks.whatsappChatUrl(''), isNull);
    });
  });
}
