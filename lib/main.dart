import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/auth/auth_controller.dart';
import 'core/config/app_config.dart';
import 'core/images/app_images.dart';
import 'core/images/hive_image_store.dart';
import 'core/settings/settings_controller.dart';
import 'core/storage/hive_catalog_store.dart';
import 'core/storage/hive_settings_store.dart';
import 'core/supabase/supabase_client.dart';
import 'data/app_repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to Supabase when credentials are provided via --dart-define.
  // Otherwise the app runs locally on mock/Hive repositories.
  await AppSupabase.init();

  final store = await HiveSettingsStore.open();
  final settings = SettingsController(store);
  await settings.load(
    deviceLocale: WidgetsBinding.instance.platformDispatcher.locale,
  );

  // Reads the existing session and listens for sign-in/sign-out changes.
  final auth = AuthController();
  await auth.initialize();

  // Local-only persistence: settings, catalog records and image binaries.
  AppImages.configure(await HiveImageStore.open());
  AppRepositories.configure(
    store: await HiveCatalogStore.open(),
    useRemote: AppConfig.isSupabaseConfigured,
  );

  runApp(DialiApp(settings: settings, auth: auth));
}
