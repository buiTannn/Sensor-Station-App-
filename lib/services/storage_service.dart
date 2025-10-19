import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  static Future<void> setLoginStatus(bool isLoggedIn, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('username', username);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');
  }

  static Future<bool> validateLogin(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('username');
    final savedPass = prefs.getString('password');
    return savedUser == username && savedPass == password;
  }

  static Future<void> saveUserData(
    String username,
    String email,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  static Future<bool> validateUserData(String username, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('username');
    final savedEmail = prefs.getString('email');
    return savedUser == username && savedEmail == email;
  }

  static Future<void> updatePassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', newPassword);
  }

  static Future<void> saveDistricts(List<String> districts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('districts', districts);
  }

  static Future<List<String>> getDistricts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('districts') ?? [];
  }
}
