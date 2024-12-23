import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import '../providers/theme_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  Future<void> _toggleBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (!_isBiometricEnabled) {
        // Kiểm tra thiết bị có hỗ trợ vân tay
        final List<BiometricType> availableBiometrics = 
            await _localAuth.getAvailableBiometrics();

        if (availableBiometrics.isEmpty) {
          if (!mounted) return;
          _showError('Thiết bị không hỗ trợ đăng nhập vân tay');
          return;
        }

        // Xác thực vân tay
        final didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Xác thực vân tay để bật tính năng',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (didAuthenticate) {
          await prefs.setBool('biometric_enabled', true);
          if (!mounted) return;
          setState(() => _isBiometricEnabled = true);
        }
      } else {
        await prefs.setBool('biometric_enabled', false);
        setState(() => _isBiometricEnabled = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Không thể xác thực vân tay: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.only(top: 48),
              ),
            SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileHeader(),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          _buildQuickAction(
                            icon: Icons.workspace_premium_outlined,
                            title: 'Premium',
                            onTap: () {},
                          ),
                          _buildQuickAction(
                            icon: Icons.card_giftcard_outlined,
                            title: 'Ưu đãi',
                            onTap: () {},
                          ),
                          _buildQuickAction(
                            icon: Icons.star_outline,
                            title: 'Đánh giá',
                            onTap: () {},
                          ),
                          _buildQuickAction(
                            icon: Icons.share_outlined,
                            title: 'Chia sẻ',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Settings Sections
                    _buildSection(
                      title: 'Cài đặt tài khoản',
                      items: [
                        _buildMenuItem(
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF5856D6),
                          title: 'Thông tin cá nhân',
                          subtitle: 'Cập nhật thông tin của bạn',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.security_outlined,
                          iconColor: const Color(0xFF34C759),
                          title: 'Bảo mật',
                          subtitle: 'Mật khẩu và xác thực',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          iconColor: const Color(0xFFFF9500),
                          title: 'Thông báo',
                          subtitle: 'Tùy chỉnh thông báo',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.dark_mode_outlined,
                          title: 'Chế độ tối',
                          subtitle: themeProvider.isDarkMode
                              ? 'Đang bật'
                              : 'Đang tắt',
                          showArrow: false,
                          onTap: () => themeProvider.toggleTheme(),
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (_) => themeProvider.toggleTheme(),
                            activeColor: AppTheme.primary,
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.fingerprint,
                          iconColor: const Color(0xFF34C759),
                          title: 'Đăng nhập vân tay',
                          subtitle: _isBiometricEnabled ? 'Đang bật' : 'Đang tắt',
                          showArrow: false,
                          onTap: _toggleBiometric,
                          trailing: Switch(
                            value: _isBiometricEnabled,
                            onChanged: (_) => _toggleBiometric(),
                            activeColor: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildSection(
                      title: 'Khác',
                      items: [
                        _buildMenuItem(
                          icon: Icons.help_outline_rounded,
                          iconColor: const Color(0xFF007AFF),
                          title: 'Trợ giúp & Hỗ trợ',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.description_outlined,
                          iconColor: const Color(0xFF5856D6),
                          title: 'Điều khoản & Chính sách',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.logout_rounded,
                          iconColor: AppTheme.error,
                          title: 'Đăng xuất',
                          showArrow: false,
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Phiên bản 1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: bottomPadding + 65),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppTheme.primary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showArrow = true,
    Widget? trailing,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.divider,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary.withOpacity(0.6),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              // Xử lý đăng xuất
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://avatars.githubusercontent.com/u/118455507?v=4',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minh Tuan Le',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'minhtuanledng@gmail.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
