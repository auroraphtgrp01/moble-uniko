import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // Kiểm tra xem có bật xác thực vân tay không
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  // Xác thực bằng vân tay
  static Future<bool> authenticateWithBiometrics() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return false;

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Xác thực vân tay để đăng nhập',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // TODO: Thêm API login thực tế
      await Future.delayed(const Duration(seconds: 1)); // Mock API call
      return {
        'success': true,
        'message': 'Đăng nhập thành công'
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString()
      };
    }
  }
}
