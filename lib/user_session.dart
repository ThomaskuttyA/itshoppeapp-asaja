import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  int? userId;
  String? username;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    username = prefs.getString('username');
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setInt('userId', userId!);
    }
    if (username != null) {
      await prefs.setString('username', username!);
    }
  }

  Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    userId = null;
    username = null;
  }
}
