import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static Future<void> setCurrentUser(String name, String email) async {
    _currentUser = User(name: name, email: email);

    // Lưu thông tin user vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
  }

  static Future<User?> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    final email = prefs.getString('userEmail');

    if (name != null && email != null) {
      _currentUser = User(name: name, email: email);
      return _currentUser;
    }
    return null;
  }

  static Future<void> clearUser() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('token');
  }
}
