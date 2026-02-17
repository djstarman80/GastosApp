import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'presentation/router/app_router.dart';
import 'presentation/providers/settings_provider.dart';
import 'data/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  initializeDatabaseFactory();
  
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;
  
  final initialLocation = onboardingCompleted ? '/home' : '/onboarding';
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: GastosApp(initialLocation: initialLocation),
    ),
  );
}

class GastosApp extends ConsumerWidget {
  final String initialLocation;
  
  const GastosApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    final router = GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      initialLocation: initialLocation,
      routes: appRoutes,
    );
    
    return MaterialApp.router(
      title: 'GastosApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('es', 'UY'),
      ],
      locale: const Locale('es', 'ES'),
    );
  }
}
