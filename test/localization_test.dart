import 'dart:convert';
import 'dart:io';

import 'package:diali/app/app.dart';
import 'package:diali/core/settings/settings_controller.dart';
import 'package:diali/core/storage/settings_store.dart';
import 'package:diali/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, String> readArb(String locale) {
  final file = File('lib/l10n/app_$locale.arb');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final entry in json.entries)
      if (!entry.key.startsWith('@')) entry.key: entry.value as String,
  };
}

void main() {
  group('ARB catalogue', () {
    late Map<String, String> en;
    late Map<String, String> ar;
    late Map<String, String> fr;

    setUpAll(() {
      en = readArb('en');
      ar = readArb('ar');
      fr = readArb('fr');
    });

    test('every locale exposes exactly the same message keys', () {
      expect(ar.keys.toSet(), en.keys.toSet(), reason: 'ar keys differ from en');
      expect(fr.keys.toSet(), en.keys.toSet(), reason: 'fr keys differ from en');
    });

    test('no translated message is blank', () {
      for (final locale in {'en': en, 'ar': ar, 'fr': fr}.entries) {
        for (final message in locale.value.entries) {
          expect(
            message.value.trim(),
            isNotEmpty,
            reason: '${locale.key} ${message.key} is empty',
          );
        }
      }
    });

    test('placeholders are preserved in every locale', () {
      final placeholder = RegExp(r'\{(\w+)\}');
      List<String> names(String value) =>
          placeholder.allMatches(value).map((m) => m.group(1)!).toList()..sort();

      for (final key in en.keys) {
        final expected = names(en[key]!);
        expect(names(ar[key] ?? ''), expected, reason: 'ar $key placeholders');
        expect(names(fr[key] ?? ''), expected, reason: 'fr $key placeholders');
      }
    });
  });

  testWidgets('app renders translated navigation for each locale',
      (tester) async {
    for (final locale in const [Locale('en'), Locale('ar'), Locale('fr')]) {
      final controller = SettingsController(InMemorySettingsStore());
      await controller.load(deviceLocale: locale);

      await tester.pumpWidget(DialiApp(settings: controller));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(locale);
      expect(
        find.text(l10n.navOrders),
        findsWidgets,
        reason: '${locale.languageCode} navigation is not localized',
      );
    }
  });
}
