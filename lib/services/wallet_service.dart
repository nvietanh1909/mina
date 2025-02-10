import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mina/model/wallet_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mina/services/api_service.dart';
import 'package:mina/constans/constants.dart';

class WalletService {
  final String baseUrl = AppConfig.baseUrl;
  static const String tokenKey = AppConfig.tokenKey;

  Future<List<Wallet>> getAllWallets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallets'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data']['wallets'] as List)
            .map((wallet) => Wallet.fromJson(wallet))
            .toList();
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách ví: ${e.toString()}');
    }
  }

  Future<Wallet> createWallet(
      String name, String? description, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/wallets'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
          'currency': currency,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Wallet.fromJson(data['data']['wallet']);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Không thể tạo ví: ${e.toString()}');
    }
  }

  Future<Wallet> updateWallet(
      String id, String name, String? description) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/wallets/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Wallet.fromJson(data['data']['wallet']);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Không thể cập nhật ví: ${e.toString()}');
    }
  }

  Future<void> deleteWallet(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/wallets/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Không thể xóa ví: ${e.toString()}');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token =
        await _getToken(); // Implement this method based on your auth setup
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }
}
