import 'package:desktop_window/desktop_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mentor/themes/theme.provider.dart';
import 'package:universal_platform/universal_platform.dart';

import 'navigation/router.dart';
import 'shared/models/theme_settings.dart';

import 'package:mentor/provider/user_data_provider.dart';
import 'package:provider/provider.dart';

Future setDesktopWindow() async {
  await DesktopWindow.setMinWindowSize(const Size(400, 400));
  await DesktopWindow.setWindowSize(const Size(1300, 900));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = "pk_test_51QU01mAUXckYZtWngp7oTkZpbpxEk5a6WNSyp60iKm8px3ISnP5GGvSd1TMnYUHc55N3upyLRMKzFhV5YSPwC8Rj00MJbYHu0k";

  // Stripe.publishableKey = "pk_live_51QkEZTKi6Bct4tzg4yUJMmI6dBoGASYkgdl2Dig32OYU3PWtQfEAabmZukilBG1Ag17OHDtfHRKkUM8Tt9Q5a6bn005qnft1xa";
  
  if (UniversalPlatform.isDesktop) {
    setDesktopWindow();
  }

  // Load the user data as soon as the app starts
  final userDataProvider = await UserDataProvider().loadAsync();

  runApp(
    ChangeNotifierProvider(
      create: (_) => userDataProvider,
      child: const MainApp(),
    ),
    );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  final settings = ValueNotifier(ThemeSettings(
    themeMode: ThemeMode.system,
  ));

  @override
  void initState() {
    super.initState();
    // Ensure the user data and last visited route are loaded
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // userDataProvider.loadLastVisitedRoute();
  }
  
  @override
  Widget build(BuildContext context) {
    // Access the UserDataProvider to check if the user is logged in
    final userDataProvider = Provider.of<UserDataProvider>(context);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => ThemeProvider(
        lightDynamic: lightDynamic,
        darkDynamic: darkDynamic,
        settings: settings,
        child: NotificationListener<ThemeSettingChange>(
          onNotification: (notification) {
            settings.value = notification.settings;
            return true;
          },
          child: ValueListenableBuilder<ThemeSettings>(
              valueListenable: settings,
              builder: (context, value, _) {
                final theme = ThemeProvider.of(context);
                // Check if user is logged in
              if (userDataProvider.isUserLoggedIn()) {
                // If logged in, navigate to home screen
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Find your best mentor',
                  theme: theme.light(),
                  darkTheme: theme.dark(),
                  themeMode: theme.themeMode(),
                  routerConfig: appRouter, 
                );
              } else {
                // If not logged in, navigate to login screen
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Find your best mentor',
                  theme: theme.light(),
                  darkTheme: theme.dark(),
                  themeMode: theme.themeMode(),
                  routerConfig: appRouter, 
                );
              }
              }),
        ),
      ),
    );
  }
}