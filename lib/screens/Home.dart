import 'package:flutter/material.dart';
import '../widgets/Dock.dart';
import 'profile.dart';
import '../providers/theme_provider.dart';
import '../config/theme.config.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Tổng quan')),
    const Center(child: Text('Sổ giao dịch')),
    const Center(child: Text('Ghi chép giao dịch')),
    const Center(child: Text('Trợ lý ảo')),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          extendBody: true,
          body: _screens[_currentIndex],
          bottomNavigationBar: CustomBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
