import 'dart:io';
import 'package:flutter/material.dart';
import '../config/theme.config.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 32) / 5;

    return Container(
      height: Platform.isIOS ? 95 : 80,
      padding: Platform.isIOS
          ? const EdgeInsets.fromLTRB(16, 4, 16, 32)
          : const EdgeInsets.fromLTRB(16, 4, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.darkBottomNav,
        border: Border.all(
          color: Colors.transparent,
          width: 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: IgnorePointer(
        ignoring: isKeyboardVisible,
        child: Opacity(
          opacity: isKeyboardVisible ? 0.5 : 1.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet_rounded,
                label: 'Tổng quan',
                width: itemWidth,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.sync_alt_outlined,
                activeIcon: Icons.sync_alt_rounded,
                label: 'Giao dịch',
                width: itemWidth,
              ),
              _buildAddButton(width: itemWidth),
              _buildNavItem(
                index: 3,
                icon: Icons.insert_chart_outlined,
                activeIcon: Icons.insert_chart_rounded,
                label: 'Ví & Quỹ',
                width: itemWidth,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline,
                activeIcon: Icons.person_rounded,
                label: 'Cá nhân',
                width: itemWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required double width,
  }) {
    final isSelected = currentIndex == index;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Border line indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: 0,
              left:
                  isSelected ? width * 0.15 : width * 0.5, // Thu hẹp từ giữa ra
              right: isSelected ? width * 0.15 : width * 0.5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(isSelected ? 0.8 : 0),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0.0,
                      end: isSelected ? 1.0 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 1 - value,
                            child: Icon(
                              icon,
                              color: AppTheme.textSecondary,
                              size: 24,
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(
                                0, 2 * (1 - value)), // Giảm độ dịch chuyển
                            child: Transform.scale(
                              scale: 0.9 + (0.1 * value), // Giảm độ scale
                              child: Opacity(
                                opacity: value,
                                child: Icon(
                                  activeIcon,
                                  color: AppTheme.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isSelected ? 1.0 : 0.8,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton({required double width}) {
    final isSelected = currentIndex == 2;

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => onTap(2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main button with improved gradient
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isSelected ? AppTheme.primary : const Color(0xFF27272A),
                    isSelected
                        ? AppTheme.primary.withOpacity(0.9)
                        : const Color(0xFF27272A).withOpacity(0.9),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.25),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  // Animated background circles
                  if (isSelected) ...{
                    for (var i = 0; i < 4; i++)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 500 + (i * 100)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.5 + (value * 0.5),
                            child: Opacity(
                              opacity: (1 - value) * 0.4,
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primary,
                                    width: 2 * (1 - value),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  },

                  // Center icon with animations
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 0.125 * 3.14,
                          child: Icon(
                            Icons.add_rounded,
                            color: Color.lerp(Colors.white.withOpacity(0.9),
                                Colors.white, value),
                            size: 24 + (value * 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
