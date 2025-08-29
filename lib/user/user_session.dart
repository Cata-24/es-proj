import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  String? userId;

  bool isLoggedIn(){
    return userId != null && userId!.trim().isNotEmpty;
  }

  void clear() async {
    userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<void> saveUserId() async {
    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId!);
    }
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
  }
}
