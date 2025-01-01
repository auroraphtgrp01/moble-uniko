import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/logger_service.dart';

class StorageService {
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserInfo = 'user_info';

  static Future<void> saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAccessToken, data['accessToken'] ?? '');
    await prefs.setString(keyRefreshToken, data['refreshToken'] ?? '');

    // Không lưu user info ở đây nữa
    LoggerService.info('Auth tokens saved successfully');
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
  }

  static Future<void> saveUserInfo(Map<String, dynamic> response) async {
    try {
      final userData = response['data'];
      if (userData != null) {
        LoggerService.debug('Raw user data: $userData');

        final userInfo = {
          'fullName': userData['fullName'],
          'email': userData['email'],
          'phone_number': userData['phone_number'],
          'dateOfBirth': userData['dateOfBirth'],
          'avatarId': userData['avatarId'],
          'status': userData['status'],
          'address': userData['address'],
          'defaultExpenditureFundId': userData['defaultExpenditureFundId'],
          'gender': userData['gender'],
          'isChangeNewPassword': userData['isChangeNewPassword'],
        };

        LoggerService.debug('Saving user info: $userInfo');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(keyUserInfo, json.encode(userInfo));
      }
    } catch (e) {
      LoggerService.error('Error saving user info', e);
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAccessToken);
  }

  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAccessToken, token);
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(keyUserInfo);
      print('Getting user info string: $userStr');

      if (userStr != null && userStr.isNotEmpty) {
        return json.decode(userStr) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }
}
