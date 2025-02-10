import 'package:flutter/material.dart';
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

  Future<void> loadUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getToken();
      if (token != null) {
        _user = await _authService.getProfile();
      }
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.login(email, password);
      _user = User.fromJson(response['data']['user']);
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

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
