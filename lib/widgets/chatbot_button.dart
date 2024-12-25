import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import '../screens/ChatBot.dart';

class ChatBotButton extends StatelessWidget {
  const ChatBotButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const ChatbotScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeOutCubic;

                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(
          Icons.chat_bubble_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
} 