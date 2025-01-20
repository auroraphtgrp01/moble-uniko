import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fund_provider.dart';
import 'FundSelector.dart';
import 'package:flutter/rendering.dart';

class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showFundSelector;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingIconPressed;

  const CommonHeader({
    Key? key,
    required this.title,
    this.actions,
    this.showFundSelector = true,
    this.leadingIcon,
    this.onLeadingIconPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode 
                ? [
                    Theme.of(context).primaryColor.withOpacity(0.25),
                    Theme.of(context).primaryColor.withOpacity(0.15),
                  ]
                : [
                    Theme.of(context).primaryColor.withOpacity(0.35),
                    Theme.of(context).primaryColor.withOpacity(0.25),
                  ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(isDarkMode ? 0.02 : 0.01),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Leading Icon
                  if (leadingIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        icon: Icon(
                          leadingIcon,
                          size: 28,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: onLeadingIconPressed,
                      ),
                    ),

                  // Title với animation subtle
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween(begin: 0.8, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: isDarkMode
                                  ? [
                                      Colors.white,
                                      Colors.white.withOpacity(0.85)
                                    ]
                                  : [
                                      Color(0xFF2D3142),
                                      Color(0xFF4A4E69).withOpacity(0.85)
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: -0.7,
                                height: 1.2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Fund Selector với hiệu ứng hover
                  if (showFundSelector)
                    Container(
                      constraints: BoxConstraints(
                        minWidth: 120,
                        maxWidth: 250,
                      ),
                      height: 42,
                      child: Consumer<FundProvider>(
                        builder: (context, fundProvider, _) {
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: const FundSelector(),
                            ),
                          );
                        },
                      ),
                    ),

                  // Actions
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
