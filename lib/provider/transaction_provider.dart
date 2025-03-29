import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mina/model/transaction_model.dart';
import 'dart:convert';
import 'package:mina/services/api_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 1;
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;

  List<Transaction> get transactions => [..._transactions];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Reset state
  void _resetState() {
    _transactions = [];
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  // Lấy danh sách giao dịch
  Future<void> fetchTransactions({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool refresh = false,
    int limit = 20,
  }) async {
    try {
      // Reset state if refreshing or date range changed
      if (refresh ||
          startDate != _currentStartDate ||
          endDate != _currentEndDate) {
        _resetState();
        _currentStartDate = startDate;
        _currentEndDate = endDate;
      }

      // Don't fetch if we're already loading or there's no more data
      if (_isLoading || !_hasMore) return;

      _isLoading = true;
      _error = null;
      notifyListeners();

      // Xây dựng query parameters
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'limit': limit.toString(),
      };

      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Không có token xác thực');
      }

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

        // Update pagination state
        _hasMore = fetchedTransactions.length >= limit;
        _currentPage++;

        // Add new transactions to list
        _transactions.addAll(fetchedTransactions);

        // Remove duplicates based on transaction ID
        _transactions = _transactions.toSet().toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        _error = null;
      } else {
        _error = responseData['message'] ?? 'Lỗi không xác định';
        throw Exception(_error);
      }
    } catch (error) {
      _error = error.toString();
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm giao dịch mới
  Future<Transaction?> createTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Không có token xác thực');
      }

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

        // Refresh the entire list to ensure consistency
        await fetchTransactions(refresh: true);

        return newTransaction;
      } else {
        _error = responseData['message'] ?? 'Lỗi không xác định';
        throw Exception(_error);
      }
    } catch (error) {
      _error = error.toString();
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật giao dịch
  Future<Transaction?> updateTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Không có token xác thực');
      }

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

        // Refresh the entire list to ensure consistency
        await fetchTransactions(refresh: true);

        return updatedTransaction;
      } else {
        _error = responseData['message'] ?? 'Lỗi không xác định';
        throw Exception(_error);
      }
    } catch (error) {
      _error = error.toString();
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa giao dịch
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Không có token xác thực');
      }

      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl}/api/transactions/$transactionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Refresh the entire list to ensure consistency
        await fetchTransactions(refresh: true);
        return true;
      } else {
        _error = responseData['message'] ?? 'Lỗi không xác định';
        throw Exception(_error);
      }
    } catch (error) {
      _error = error.toString();
      throw error;
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

  void clearTransactions() {
    _resetState();
  }
}
