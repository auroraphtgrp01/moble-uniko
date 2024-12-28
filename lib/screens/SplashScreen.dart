import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.config.dart';
import 'Home.dart';
import 'Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Thêm try-catch để xử lý lỗi khởi tạo
    try {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _controller.forward();
      
      // Wrap trong Future.delayed để đảm bảo widget đã mount
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 2200), () {
            if (mounted) {
              _checkLoginStatus();
            }
          });
        }
      });
    } catch (e) {
      print('SplashScreen initialization error: $e');
      // Fallback navigation nếu có lỗi
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _checkLoginStatus();
        }
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        // Nếu có token, load thêm thông tin user
        final userName = prefs.getString('userName') ?? '';
        final userEmail = prefs.getString('userEmail') ?? '';
        
        // Có thể lưu thông tin user vào một service hoặc state management solution
        // Ví dụ: UserService.setCurrentUser(userName, userEmail);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => token != null ? const HomePage() : const LoginPage(),
        ),
      );
    } catch (e) {
      print('Login status check error: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
    } catch (e) {
      print('Controller dispose error: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Stack(
        children: [
          // Grid pattern background
          CustomPaint(
            size: Size(size.width, size.height),
            painter: GridPainter(
              color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.03),
              spacing: 25, // Khoảng cách giữa các đường grid
              strokeWidth: 0.5, // Độ mỏng của đường
            ),
          ),

          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const Spacer(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo lớn hơn
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween<double>(begin: 0.85, end: 1.0),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Hero(
                              tag: 'app_logo',
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: size.width * 0.5, // Tăng từ 0.4 lên 0.5
                                height: size.width * 0.5,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16), // Giảm từ 24 xuống 16
                      Text(
                        'Quản lý tài chính thông minh',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8), // Giảm từ 12 xuống 8
                      Text(
                        'Định hình tương lai tài chính của bạn',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 0.3,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6), // Giảm từ 8 xuống 6
                      Text(
                        'Mỗi khoản chi tiêu - Một quyết định thông minh',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Center(child: _buildElegantLoadingIndicator(isDarkMode)),
                const SizedBox(height: 16),
                Text(
                  'Developed by Auroraphtgrp ✨',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.5,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantLoadingIndicator(bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            strokeWidth: 2.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Khởi tạo...',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// Grid Painter
class GridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double strokeWidth;

  GridPainter({
    required this.color,
    this.spacing = 25,
    this.strokeWidth = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    // Vẽ đường dọc
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Vẽ đường ngang
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
