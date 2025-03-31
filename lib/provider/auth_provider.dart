import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mina/model/user_model.dart';
import 'package:mina/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? get token => _token;
  User? _user;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isAuthenticated => _token != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check for existing token
      _token = await _authService.getToken();
      if (_token != null) {
        // If token exists, try to get user profile
        _user = await _authService.getProfile();
      } else {
        print("Không tìm thấy token");
      }
    } catch (e) {
      print("Lỗi khi khởi tạo: $e");
      // If there's an error (e.g., token expired), clear everything
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rememberedEmail', email);
    await prefs.setString('rememberedPassword', password);
    await prefs.setBool('rememberMe', true);
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final isRememberMe = prefs.getBool('rememberMe') ?? false;

    if (isRememberMe) {
      final email = prefs.getString('rememberedEmail');
      final password = prefs.getString('rememberedPassword');

      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
    }

    return null;
  }

  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberedEmail');
    await prefs.remove('rememberedPassword');
    await prefs.setBool('rememberMe', false);
  }

  Future<void> login(String email, String password,
      {bool rememberMe = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.login(email, password);
      _token = response['data']['token'];
      _user = User.fromJson(response['data']['user']);

      if (rememberMe) {
        await saveCredentials(email, password);
      } else {
        await clearSavedCredentials();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tryAutoLogin() async {
    final savedCredentials = await getSavedCredentials();
    if (savedCredentials != null) {
      try {
        await login(savedCredentials['email']!, savedCredentials['password']!);
      } catch (e) {
        print("Lỗi khi tự động đăng nhập: $e");
        // Clear saved credentials if auto login fails
        await clearSavedCredentials();
      }
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();
      await clearSavedCredentials();
      _user = null;
      _token = null;
      print("Đã đăng xuất và xóa token");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.register(name, email, password);
      _user = User.fromJson(response['data']['user']);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String name,
      {String? currentPassword, String? newPassword}) async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _authService.updateProfile(name,
          currentPassword: currentPassword, newPassword: newPassword);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
