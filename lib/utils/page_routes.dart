import 'package:flutter/material.dart';

class SlideUpRoute extends PageRouteBuilder {
  final Widget page;
  
  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.3);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);
            var fadeAnimation = animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: curve),
              ),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  
  FadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                Tween(begin: 0.0, end: 1.0).chain(
                  CurveTween(curve: Curves.easeOut),
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
        );
} 