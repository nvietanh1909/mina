class Wallet {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final double balance;
  final double monthlyLimit;
  final String currency;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.monthlyLimit = 0,
    required this.balance,
    required this.currency,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['_id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      balance: json['balance'].toDouble(),
      currency: json['currency'],
      isDefault: json['isDefault'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      monthlyLimit: json['monthlyLimit'] != null
          ? (json['monthlyLimit'] as num).toDouble()
          : 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'balance': balance,
      'currency': currency,
      'monthlyLimit': monthlyLimit,
    };
  }
}
