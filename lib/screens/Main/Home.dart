import 'package:flutter/material.dart';
import 'package:uniko/screens/Main/Wallet.dart';
import 'package:uniko/screens/Main/Center.dart';
import '../../widgets/Dock.dart';
import 'Overview.dart';
import 'Transactions.dart';
import 'Profile.dart';
import 'AddTransaction.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    OverviewPage(),
    TransactionsPage(),
    AddTransactionPage(),
    CenterPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      // floatingActionButton: const ChatBotButton(),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}
