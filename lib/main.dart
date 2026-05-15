import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/profile/presentation/pages/welcome_page.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: RunityApp(),
    ),
  );
}

class RunityApp extends ConsumerWidget {
  const RunityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(profileProvider);

    return MaterialApp(
      title: 'Runity',
      debugShowCheckedModeBanner: false,
      theme: (settings.darkMode == true) ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: profile.isSetup ? DashboardPage() : WelcomePage(),
    );
  }
}
