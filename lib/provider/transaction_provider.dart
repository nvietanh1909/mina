import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mina/model/transaction_model.dart';
import 'dart:convert';
import 'package:mina/services/api_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => [..._transactions];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Lấy danh sách giao dịch
  Future<void> fetchTransactions({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Xây dựng query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/transactions')
            .replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<Transaction> fetchedTransactions =
            (responseData['data']['transactions'] as List)
                .map((json) => Transaction.fromJson(json))
                .toList();

        if (page == 1) {
          _transactions = fetchedTransactions;
        } else {
          _transactions.addAll(fetchedTransactions);
        }
      } else {
        _error = responseData['message'] ?? 'Lỗi không xác định';
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm giao dịch mới
  Future<Transaction?> createTransaction(Transaction transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/api/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(transaction.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        final newTransaction =
            Transaction.fromJson(responseData['data']['transaction']);
        _transactions.insert(0, newTransaction);
        notifyListeners();
        return newTransaction;
      } else {
        _error = responseData['message'] ?? 'Lỗi không xác định';
        return null;
      }
    } catch (error) {
      _error = error.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật giao dịch
  Future<Transaction?> updateTransaction(Transaction transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await AuthService().getToken();
      final response = await http.patch(
        Uri.parse('${AuthService.baseUrl}/api/transactions/${transaction.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(transaction.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final updatedTransaction =
            Transaction.fromJson(responseData['data']['transaction']);

        // Tìm và cập nhật giao dịch trong danh sách
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          _transactions[index] = updatedTransaction;
        }

        notifyListeners();
        return updatedTransaction;
      } else {
        _error = responseData['message'] ?? 'Lỗi không xác định';
        return null;
      }
    } catch (error) {
      _error = error.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa giao dịch
  Future<bool> deleteTransaction(String transactionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl}/api/transactions/$transactionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _transactions.removeWhere((t) => t.id == transactionId);
        notifyListeners();
        return true;
      } else {
        _error = responseData['message'] ?? 'Lỗi không xác định';
        return false;
      }
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy thống kê giao dịch
  Future<Map<String, dynamic>?> getTransactionStats({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Xây dựng query parameters
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/transactions/stats')
            .replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['data'];
      } else {
        _error = responseData['message'] ?? 'Lỗi không xác định';
        return null;
      }
    } catch (error) {
      _error = error.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
