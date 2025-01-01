import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:local_auth/local_auth.dart';

import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isBiometricEnabled() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Xác thực để đăng nhập',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      print('Login Response: ${response.body}');

      if (response.statusCode == 201) {
        final token = data['data']['accessToken'];

        await StorageService.saveAccessToken(token);
        print('Saved token: $token');

        final userInfo = await getMe();
        if (userInfo['success']) {
          await StorageService.saveAuthData(data['data']);
          return {
            'success': true,
            'message': 'Đăng nhập thành công',
            'data': data['data']
          };
        } else {
          return userInfo;
        }
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối, vui lòng thử lại sau'};
    }
  }

// Get Me user info
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await ApiService.call('/users/me');
      final data = json.decode(response.body);
      LoggerService.api('GET /users/me', data);

      if (response.statusCode == 200) {
        await StorageService.saveUserInfo(data);
        LoggerService.info('User info saved successfully');
        
        final savedData = await StorageService.getUserInfo();
        LoggerService.debug('Saved user data: $savedData');
        
        return {'success': true, 'data': data['data']};
      } else {
        LoggerService.warning('Failed to get user info: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể lấy thông tin người dùng'
        };
      }
    } catch (e) {
      LoggerService.error('GetMe Error', e);
      return {'success': false, 'message': 'Lỗi kết nối, vui lòng thử lại sau'};
    }
  }
}
