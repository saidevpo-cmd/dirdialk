import 'dart:io';

import 'package:diali/core/design_system/app_style.dart';
import 'package:diali/core/settings/settings_controller.dart';
import 'package:diali/core/storage/hive_settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  test('settings survive an app restart with local storage', () async {
    final directory = await Directory.systemTemp.createTemp('diali_settings');

    final firstStore = await HiveSettingsStore.openAt(directory.path);
    final first = SettingsController(firstStore);
    await first.load(deviceLocale: const Locale('en'));
    await first.setLocale(const Locale('ar'));
    await first.setThemeMode(ThemeMode.dark);
    await first.setStyle(AppStyle.professional);
    await Hive.close();

    final secondStore = await HiveSettingsStore.openAt(directory.path);
    final second = SettingsController(secondStore);
    await second.load(deviceLocale: const Locale('fr'));

    expect(second.locale, const Locale('ar'));
    expect(second.themeMode, ThemeMode.dark);
    expect(second.style, AppStyle.professional);

    await Hive.close();
    await directory.delete(recursive: true);
  });
}
