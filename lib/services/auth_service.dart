import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;
  String _currentUsername = '';

  bool get isAuthenticated => _isAuthenticated;
  String get currentUsername => _currentUsername;

  static const String _authKey = 'gm_admin_auth_token';
  static const String _userKey = 'gm_admin_username';

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool(_authKey) ?? false;
      _currentUsername = prefs.getString(_userKey) ?? '';
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing AuthService: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    // Check credentials (allows default admin or customized)
    if (username.trim().toLowerCase() == AppConstants.defaultAdminUsername &&
        password.trim() == AppConstants.defaultAdminPassword) {
      _isAuthenticated = true;
      _currentUsername = username.trim();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_authKey, true);
        await prefs.setString(_userKey, _currentUsername);
      } catch (e) {
        debugPrint('Error saving auth: $e');
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUsername = '';
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authKey);
      await prefs.remove(_userKey);
    } catch (e) {
      debugPrint('Error clearing auth: $e');
    }

    notifyListeners();
  }
}
