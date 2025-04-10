import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import 'package:mina/constans/constants.dart';
import 'package:mina/model/wallet_model.dart';

class AuthService {
  static const String baseUrl = AppConfig.baseUrl;
  static const String tokenKey = AppConfig.tokenKey;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    print("Token đã lưu: $token");
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['data']['token']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await saveToken(data['data']['token']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<User> getProfile() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['data']['user']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<User> updateProfile(String name,
      {String? currentPassword, String? newPassword}) async {
    final headers = await getHeaders();
    final body = {
      'name': name,
      if (currentPassword != null) 'currentPassword': currentPassword,
      if (newPassword != null) 'newPassword': newPassword,
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/api/users/profile'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['data']['user']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> logout() async {
    await removeToken();
  }

  Future<dynamic> getAuthenticatedData(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        ...?additionalHeaders,
      };

      http.Response response;
      final uri = Uri.parse('$baseUrl$endpoint');

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Phương thức HTTP không được hỗ trợ');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return null;
      } else if (response.statusCode == 401) {
        // Token hết hạn hoặc không hợp lệ
        await removeToken(); // Xóa token
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đã có lỗi xảy ra');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> getWalletsByUserId(String userId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/wallets/$userId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      throw Exception("Lỗi kết nối đến server: $e");
    }
  }

  Future<User> uploadAvatar(String filePath) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No token found');

      final url = Uri.parse('$baseUrl/api/users/avatar');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Add the file
      final file = await http.MultipartFile.fromPath('avatar', filePath);
      request.files.add(file);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        if (jsonData['status'] == 'success' && jsonData['data'] != null) {
          return User.fromJson(jsonData['data']['user']);
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to upload avatar');
        }
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to upload avatar');
      }
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<Wallet> createWallet({
    required double monthlyLimit,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.post(
        Uri.parse('$baseUrl/api/wallets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'monthlyLimit': monthlyLimit,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        return Wallet.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create wallet');
      }
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
