import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../widgets/Dock.dart';
import 'Overview.dart';
import 'Transactions.dart';
import 'Profile.dart';
import 'AddTransaction.dart';
import 'Chatbot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const OverviewPage(),
    const TransactionsPage(),
    const AddTransactionPage(),
    const ChatbotScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 400),
        reverse: _currentIndex < _currentIndex,
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.transparent,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: _currentIndex == 3
          ? null 
          : CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
            ),
    );
  }
}
