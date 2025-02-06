import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mina/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.9:5000';

  // Đăng nhập
  Future<Map<String, dynamic>> login(BuildContext context, String email,
      String password, bool rememberMe) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];

        if (token != null && rememberMe){
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          authProvider.saveToken(token);

          // Nếu rememberMe = true, lưu token vào SharedPreferences
          if (rememberMe) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', token);
          }
        }
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'An error occurred');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
