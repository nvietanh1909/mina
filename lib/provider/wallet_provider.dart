import 'package:flutter/material.dart';
import 'package:mina/model/wallet_model.dart';
import 'package:mina/services/api_service.dart';
import 'package:mina/services/wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService = WalletService();
  List<Wallet> _wallets = [];
  bool _isLoading = false;
  String? _error;

  List<Wallet> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWallets() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _walletService.getAllWallets();
      _wallets = response;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createWallet(
      String name, String? description, String currency) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _walletService.createWallet(name, description, currency);
      await loadWallets();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateWallet(String id, String name, String? description,
      {bool? isDefault, double? monthlyLimit}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _walletService.updateWallet(
        id,
        name,
        description,
        isDefault: isDefault,
        monthlyLimit: monthlyLimit,
      );
      await loadWallets();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateMonthlyLimit(String id, double monthlyLimit) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _walletService.updateMonthlyLimit(id, monthlyLimit);
      await loadWallets();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteWallet(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _walletService.deleteWallet(id);
      await loadWallets();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
}
