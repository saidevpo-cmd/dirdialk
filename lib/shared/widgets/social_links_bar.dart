import 'package:flutter/material.dart';

import '../../domain/models/social_links.dart';
import '../../l10n/generated/app_localizations.dart';
import '../utils/external_links.dart';

/// Icon + localized label for a social platform.
IconData socialPlatformIcon(SocialPlatform platform) {
  switch (platform) {
    case SocialPlatform.instagram:
      return Icons.camera_alt_outlined;
    case SocialPlatform.facebook:
      return Icons.facebook;
    case SocialPlatform.tiktok:
      return Icons.music_note_outlined;
    case SocialPlatform.whatsapp:
      return Icons.chat_outlined;
    case SocialPlatform.youtube:
      return Icons.play_circle_outline;
    case SocialPlatform.linkedin:
      return Icons.work_outline;
  }
}

String socialPlatformLabel(AppLocalizations l10n, SocialPlatform platform) {
  switch (platform) {
    case SocialPlatform.instagram:
      return l10n.socialInstagram;
    case SocialPlatform.facebook:
      return l10n.socialFacebook;
    case SocialPlatform.tiktok:
      return l10n.socialTiktok;
    case SocialPlatform.whatsapp:
      return l10n.socialWhatsapp;
    case SocialPlatform.youtube:
      return l10n.socialYoutube;
    case SocialPlatform.linkedin:
      return l10n.socialLinkedin;
  }
}

/// A wrap of tappable icons for the business's public social profiles.
class SocialLinksBar extends StatelessWidget {
  const SocialLinksBar({super.key, required this.links});

  final SocialLinks links;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = links.all;
    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      children: [
        for (final link in items)
          IconButton(
            tooltip: socialPlatformLabel(l10n, link.platform),
            icon: Icon(socialPlatformIcon(link.platform)),
            onPressed: () => ExternalLinks.open(link.url),
          ),
      ],
    );
  }
}
