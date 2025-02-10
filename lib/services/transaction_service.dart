import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mina/model/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mina/constans/constants.dart';

class TransactionService {
  final String baseUrl = AppConfig.baseUrl;
  static const String tokenKey = AppConfig.tokenKey;

  Future<List<Transaction>> getTransactions({
    String? walletId,
    String? type,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (walletId != null) queryParams['walletId'] = walletId;
      if (type != null) queryParams['type'] = type;
      print('Request params: $queryParams'); // Debug log

      final uri = Uri.parse('$baseUrl/api/transactions')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data']['transactions'] as List)
            .map((t) => Transaction.fromJson(t))
            .toList();
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      print('Error getting transactions: $e');
      rethrow;
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/transactions'),
        headers: await _getHeaders(),
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Transaction.fromJson(data['data']['transaction']);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      print('Error creating transaction: $e');
      rethrow;
    }
  }

  Future<Transaction> updateTransaction(
      String id, Transaction transaction) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/transactions/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Transaction.fromJson(data['data']['transaction']);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Không thể cập nhật giao dịch: ${e.toString()}');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/transactions/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Không thể xóa giao dịch: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getTransactionStats({
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (walletId != null) queryParams['walletId'] = walletId;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl/api/transactions/stats')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Không thể lấy thống kê: ${e.toString()}');
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
