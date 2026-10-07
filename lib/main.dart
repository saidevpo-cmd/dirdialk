import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/settings/settings_controller.dart';
import 'core/storage/hive_settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = await HiveSettingsStore.open();
  final settings = SettingsController(store);
  await settings.load(
    deviceLocale: WidgetsBinding.instance.platformDispatcher.locale,
  );

  runApp(DialiApp(settings: settings));
}
