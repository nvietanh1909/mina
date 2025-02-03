import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.9:5000';

  // Lấy danh sách budgets từ API
  Future<List<dynamic>> getBudgets() async {
    final response = await http.get(Uri.parse('$baseUrl/budgets'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load budgets');
    }
  }

  // Thêm một budget mới
  Future<void> addBudget(Map<String, dynamic> budget) async {
    final response = await http.post(
      Uri.parse('$baseUrl/budgets'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(budget),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add budget');
    }
  }

  // Lấy thông tin ngân sách của người dùng
  Future<List<dynamic>> getUserBudget(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/users/$userId/budgets/active'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user budget');
    }
  }

  // Đăng ký người dùng mới (Signup)
  Future<Map<String, dynamic>> signup(
      String userID, String email, String password, bool verification) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userID': userID,
        'email': email,
        'password': password,
        'verification': verification,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to sign up');
    }
  }

  // Đăng nhập (Login)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  // Lấy thông tin session của người dùng
  Future<Map<String, dynamic>> getSession() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/session'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load session');
    }
  }
}
