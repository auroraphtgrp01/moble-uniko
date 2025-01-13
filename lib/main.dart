import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniko/config/theme.config.dart';
import 'providers/theme_provider.dart';
import 'providers/fund_provider.dart';
import 'providers/account_source_provider.dart';
import 'providers/category_provider.dart';
import 'providers/statistics_provider.dart';
import 'screens/Auth/SplashScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FundProvider()),
        ChangeNotifierProvider(create: (_) => AccountSourceProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData(
            brightness:
                themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: AppTheme.background,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            // other theme configurations
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
