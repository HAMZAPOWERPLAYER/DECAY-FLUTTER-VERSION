import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'companion.dart';
import 'screens/archive_screen.dart';
import 'screens/certificate_screen.dart';
import 'screens/home_screen.dart';
import 'screens/info_pages.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'theme.dart';

/// Decay — a quiet, offline companion.
///
/// Routing hub mirroring the original Expo Router structure:
/// `/` → onboarding → home → certificate, plus settings pages and archive.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.voidTop,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  final controller = CompanionController.create();
  runApp(DecayApp(controller: controller));
}

class DecayApp extends StatefulWidget {
  const DecayApp({super.key, required this.controller});

  final CompanionController controller;

  @override
  State<DecayApp> createState() => _DecayAppState();
}

class _DecayAppState extends State<DecayApp> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.voidTop,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          surface: AppColors.voidTop,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        Widget page;
        switch (name) {
          case '/onboarding':
            page = OnboardingScreen(controller: widget.controller);
          case '/certificate':
            page = CertificateScreen(
              controller: widget.controller,
              archiveId: settings.arguments is String
                  ? settings.arguments as String
                  : null,
            );
          case '/archive':
            page = const ArchiveScreen();
          case '/settings':
            page = SettingsScreen(controller: widget.controller);
          case '/settings/how-it-works':
            page = const HowItWorksScreen();
          case '/settings/developer-support':
            page = const DeveloperSupportScreen();
          case '/settings/terms':
            page = const TermsScreen();
          case '/settings/privacy':
            page = const PrivacyScreen();
          case '/settings/about':
            page = const AboutScreen();
          default:
            page = HomeRouter(controller: widget.controller);
        }
        return PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (_, _, _) => page,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
