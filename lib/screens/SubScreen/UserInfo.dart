import 'package:flutter/material.dart';
import '../../config/theme.config.dart';
import '../../services/core/storage_service.dart';
import 'package:flutter/cupertino.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final data = await StorageService.getUserInfo();
    if (data != null) {
      setState(() {
        userInfo = data;
      });
    }
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color:
            AppTheme.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : AppTheme.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDarkMode
                ? Colors.black.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Thông tin cá nhân',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primary,
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image:
                            AssetImage('assets/images/avatar_placeholder.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userInfo?['fullName'] ?? 'Chưa cập nhật',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userInfo?['email'] ?? 'Chưa cập nhật',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Info items with spacing between them
            Column(
              children: [
                _buildInfoItem(
                    'Số điện thoại',
                    userInfo?['phone_number'] ?? 'Chưa cập nhật',
                    Icons.phone_outlined),
                const SizedBox(height: 16),
                _buildInfoItem(
                    'Địa chỉ',
                    userInfo?['address'] ?? 'Chưa cập nhật',
                    Icons.location_on_outlined),
                const SizedBox(height: 16),
                _buildInfoItem(
                    'Ngày sinh',
                    userInfo?['dateOfBirth'] ?? 'Chưa cập nhật',
                    Icons.calendar_today_outlined),
                const SizedBox(height: 16),
                _buildInfoItem(
                    'Giới tính',
                    userInfo?['gender'] == 'MALE'
                        ? 'Nam'
                        : userInfo?['gender'] == 'FEMALE'
                            ? 'Nữ'
                            : 'Khác',
                    Icons.person_outline),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
