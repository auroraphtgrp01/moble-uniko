import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniko/providers/fund_provider.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/core/storage_service.dart';
import 'package:uniko/services/core/toast_service.dart';
import 'package:uniko/widgets/Avatar.dart';
import '../../config/theme.config.dart';
import '../Main/Home.dart';
import 'ForgotPassword.dart';
import '../../services/auth_service.dart';
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniko/providers/category_provider.dart';
import 'package:uniko/providers/account_source_provider.dart';
import 'package:uniko/providers/statistics_provider.dart';
import '../../config/app_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(text: 'minhtuandng001@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: '123');
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _authService = AuthService();
  bool _showPasswordLogin = false;
  String? _savedUserName;
  String? _savedUserEmail;
  String? _savedAvatarId;

  // Validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    // Regex cho email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    return null;
  }

  // Handle login
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Login
        final response = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        if (!response['success']) {
          setState(() {
            _isLoading = false;
          });

          ToastService.showError(response['message'] ?? 'Đăng nhập thất bại');
          return;
        }

        // 2. Lưu thông tin đăng nhập
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', 'mock_token');
        await prefs.setString('userName', 'Lê Minh Tuấn 1');
        await prefs.setString('userEmail', 'minhtuanledng@gmail.com');

        if (!mounted) return;

        // 3. Initialize tất cả providers cần thiết
        try {
          final fundProvider =
              Provider.of<FundProvider>(context, listen: false);
          final categoryProvider =
              Provider.of<CategoryProvider>(context, listen: false);
          final accountSourceProvider =
              Provider.of<AccountSourceProvider>(context, listen: false);
          final statisticsProvider =
              Provider.of<StatisticsProvider>(context, listen: false);

          // Gọi tất cả API cần thiết
          await Future.wait([
            fundProvider.initializeFunds(),
            // Sau khi có selectedFundId từ fundProvider
            Future.delayed(Duration(milliseconds: 100)).then((_) async {
              final selectedFundId = fundProvider.selectedFundId;
              if (selectedFundId != null) {
                await Future.wait([
                  categoryProvider.fetchCategories(selectedFundId),
                  accountSourceProvider.fetchAccountSources(selectedFundId),
                  statisticsProvider.fetchStatistics(
                    selectedFundId,
                    DateTime.now().subtract(const Duration(days: 30)),
                    DateTime.now(),
                  ),
                ]);
              }
            }),
          ]);

          // 4. Chuyển đến trang Home khi tất cả hoàn tất
          if (!mounted) return;

          ToastService.showSuccess(
              'Đăng nhập thành công - Chào mừng bạn đến với Uniko');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
            (route) => false,
          );
        } catch (e) {
          ToastService.showError('Có lỗi xảy ra khi tải dữ liệu');
        }
      } catch (e) {
        if (!mounted) return;
        ToastService.showError(
            'Có lỗi xảy ra khi đăng nhập, vui lòng thử lại sau ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedUserInfo();
    _loadLastRegisteredEmail();
  }

  Future<void> _loadSavedUserInfo() async {
    final userInfo = await StorageService.getUserInfo();

    if (userInfo != null) {
      setState(() {
        _savedUserName = userInfo['fullName'];
        _savedUserEmail = userInfo['email'];
        _savedAvatarId = userInfo['avatarId'];

        if (_savedUserEmail != null) {
          _emailController.text = _savedUserEmail!;
        }
      });
    }
  }

  Future<void> _loadLastRegisteredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEmail = prefs.getString('lastRegisteredEmail');
    if (lastEmail != null && _emailController.text.isEmpty) {
      setState(() {
        _emailController.text = lastEmail;
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    final isAuthenticated = await AuthService.authenticateWithBiometrics();
    if (isAuthenticated && mounted) {
      setState(() => _isLoading = true);

      try {
        // 1. Call login API first
        final response = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (!response['success']) {
          ToastService.showError(response['message'] ?? 'Đăng nhập thất bại');
          return;
        }

        // 2. Lưu thông tin đăng nhập
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', 'mock_token');
        await prefs.setString('userName', 'Lê Minh Tuấn 1');
        await prefs.setString('userEmail', 'minhtuanledng@gmail.com');

        if (!mounted) return;

        // 3. Initialize providers và call APIs
        final fundProvider = Provider.of<FundProvider>(context, listen: false);
        final categoryProvider =
            Provider.of<CategoryProvider>(context, listen: false);
        final accountSourceProvider =
            Provider.of<AccountSourceProvider>(context, listen: false);
        final statisticsProvider =
            Provider.of<StatisticsProvider>(context, listen: false);

        await Future.wait([
          fundProvider.initializeFunds(),
          Future.delayed(Duration(milliseconds: 100)).then((_) async {
            final selectedFundId = fundProvider.selectedFundId;
            if (selectedFundId != null) {
              await Future.wait([
                categoryProvider.fetchCategories(selectedFundId),
                accountSourceProvider.fetchAccountSources(selectedFundId),
                statisticsProvider.fetchStatistics(
                  selectedFundId,
                  DateTime.now().subtract(const Duration(days: 30)),
                  DateTime.now(),
                ),
              ]);
            }
          }),
        ]);

        if (!mounted) return;

        ToastService.showSuccess(
            'Đăng nhập thành công - Chào mừng bạn đến với Uniko');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } catch (e) {
        if (mounted) {
          ToastService.showError('Có lỗi xảy ra khi tải dữ liệu');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildLoginForm() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final inputFillColor = isDarkMode ? Colors.grey[800] : Colors.grey[50];

    if (_savedUserName != null && !_showPasswordLogin) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar với hiệu ứng gradient
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(),
              child: Avatar(
                avatarId: _savedAvatarId,
                size: 90,
              ),
            ),
            const SizedBox(height: 24),

            // Tên người dùng với animation
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    'Xin chào,',
                    style: TextStyle(
                      fontSize: 16,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _savedUserName!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _savedUserEmail!,
                    style: TextStyle(
                      fontSize: 14,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Nút đăng nhập bằng mật khẩu
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showPasswordLogin = true;
                });
              },
              icon: Icon(
                Icons.lock_outline,
                color: AppTheme.primary,
                size: 20,
              ),
              label: Text(
                'Đăng nhập bằng mật khẩu',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Trả về form đăng nhập gốc nếu _showPasswordLogin = true
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            validator: _validateEmail,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(
                color: subtextColor,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppTheme.primary.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: inputFillColor,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppTheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              errorStyle: TextStyle(
                color: Colors.red[400],
              ),
            ),
            cursorColor: AppTheme.primary,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            validator: _validatePassword,
            obscureText: _obscurePassword,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              labelStyle: TextStyle(
                color: subtextColor,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppTheme.primary.withOpacity(0.7),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: subtextColor,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: inputFillColor,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppTheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              errorStyle: TextStyle(
                color: Colors.red[400],
              ),
            ),
            cursorColor: AppTheme.primary,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage()),
                );
              },
              child: Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Thêm biến state để theo dõi mode
  bool get _isDevMode => AppConfig.isDevMode;

  // Thêm method để toggle mode
  void _toggleDevMode() {
    setState(() {
      AppConfig.toggleDevMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final cardColor = isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final inputFillColor = isDarkMode ? Colors.grey[800] : Colors.grey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background design
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(isDarkMode ? 0.05 : 0.1),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      // Logo section
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 180,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Quản lý tài chính thông minh',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontSize: 18,
                                    color: subtextColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Login form
                      _buildLoginForm(),

                      const SizedBox(height: 24),
                      // Login and Fingerprint buttons row
                      Row(
                        children: [
                          if (_savedUserName != null && !_showPasswordLogin)
                            // Chỉ hiển thị button vân tay khi có thông tin user đã lưu
                            FutureBuilder<bool>(
                              future: AuthService.isBiometricEnabled(),
                              builder: (context, snapshot) {
                                if (snapshot.data == true) {
                                  return Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _handleBiometricLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        minimumSize:
                                            const Size(double.infinity, 56),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        elevation: isDarkMode ? 4 : 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.fingerprint_rounded,
                                                    size: 28,
                                                    color: Colors.white),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Đăng nhập bằng vân tay',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            )
                          else
                            // Hiển thị button đăng nhập bình thường cho lần đầu
                            Expanded(
                              flex: 5,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: isDarkMode ? 4 : 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Đăng nhập',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                        ],
                      ),

                      // Điều kiện hiển thị UI khác nhau dựa vào trạng thái đăng nhập
                      if (_savedUserName != null && !_showPasswordLogin) ...[
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _savedUserName = null;
                                _savedUserEmail = null;
                                _emailController.clear();
                                _passwordController.clear();
                              });
                            },
                            child: Text(
                              'Hoặc đăng nhập với tài khoản khác',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Hiển thị UI gốc với Google login và đăng ký
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            'Hoặc đăng nhập với',
                            style: TextStyle(color: subtextColor),
                          ),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Implement Google login
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: BorderSide(
                                color: isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                            backgroundColor:
                                isDarkMode ? Colors.grey[850] : Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                ),
                                child: Icon(
                                  Icons.g_mobiledata_rounded,
                                  size: 24,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Đăng nhập với Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Chưa có tài khoản? ',
                              style: TextStyle(color: subtextColor),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Register(),
                                  ),
                                );

                                if (result != null && result is String) {
                                  setState(() {
                                    _emailController.text = result;
                                  });
                                }
                              },
                              child: Text(
                                'Đăng ký ngay',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Thêm button Dev/Prod mode ở góc trên bên phải
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: _isDevMode ? Colors.orange : Colors.green,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleDevMode,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isDevMode ? Icons.bug_report : Icons.verified_user,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isDevMode ? 'Dev Mode' : 'Prod Mode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
