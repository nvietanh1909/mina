import 'package:flutter/material.dart';
import 'package:mina/model/transaction_model.dart';
import 'package:mina/services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransactions({
    String? walletId,
    String? type,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('TransactionProvider: Loading transactions...');
      _transactions = await _transactionService.getTransactions(
        walletId: walletId,
        type: type,
      );

      print('TransactionProvider: Loaded ${_transactions.length} transactions');
      _transactions.forEach((t) {
        print('Transaction: ${t.type} - ${t.amount} - ${t.date}');
      });

      _error = null;
    } catch (e) {
      print('TransactionProvider error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _transactionService.createTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      print('Error creating transaction: $e');
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateTransaction(String id, Transaction transaction) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _transactionService.updateTransaction(id, transaction);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _transactionService.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<Map<String, dynamic>> getStats({
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _transactionService.getTransactionStats(
        walletId: walletId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw e;
    }
  }
}
