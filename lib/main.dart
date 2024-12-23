import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniko/screens/login.dart';
import 'package:uniko/config/theme.config.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
          theme: ThemeData(
            brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: AppTheme.background,
            // other theme configurations
          ),
          home: const LoginPage(),
        );
      },
    );
  }
}
