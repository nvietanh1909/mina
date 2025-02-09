import 'package:flutter/material.dart';
import 'package:mina/services/api_service.dart';
class WalletProvider extends ChangeNotifier {
  final AuthService _walletApiService = AuthService();

  List<dynamic> wallets = [];
  bool isLoading = false;
  String errorMessage = "";

  Future<void> fetchWallets(String userId) async {
    try {
      isLoading = true;
      notifyListeners();

      wallets = await _walletApiService.getWalletsByUserId(userId);
      errorMessage = "";
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
