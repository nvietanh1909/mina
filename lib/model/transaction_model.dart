class Transaction {
  final String? id;
  final String? userId;
  final String? walletId;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String? notes;
  final String? walletName;
  final String? categoryName;
  final String? categoryIcon;

  Transaction({
    this.id,
    this.userId,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes = "",
    this.walletName,
    this.categoryName,
    this.categoryIcon,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing transaction JSON: $json'); // Debug log

      return Transaction(
        id: json['_id'].toString(),
        userId: json['userId'].toString(),
        walletId: json['walletId'] is Map
            ? json['walletId']['_id'].toString()
            : json['walletId'].toString(),
        amount: (json['amount'] is int)
            ? json['amount'].toDouble()
            : (json['amount'] ?? 0).toDouble(),
        notes: json['notes'] ?? '',
        category: json['category'] is Map
            ? json['category']['_id'].toString()
            : json['category'].toString(),
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
        type: json['type'] ?? '',
        walletName: json['walletId'] is Map ? json['walletId']['name'] : null,
        categoryName: json['category'] is Map ? json['category']['name'] : null,
        categoryIcon: json['category'] is Map ? json['category']['icon'] : null,
      );
    } catch (e) {
      print('Error parsing transaction: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'amount': amount,
      'notes': notes,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
    };
  }
}
