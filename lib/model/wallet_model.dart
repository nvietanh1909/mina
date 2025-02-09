import 'dart:ffi';

class Wallet {
  final String id;
  final String userId;
  final Double balance;
  final String active;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.active,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['userId'],
      balance: json['email'],
      active: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'active': active,
    };
  }
}
