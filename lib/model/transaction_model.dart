class Transaction {
  final String? id;
  final double amount;
  final String category;
  final DateTime date;
  final String type;
  final String? notes;

  Transaction({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.notes,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          amount == other.amount &&
          category == other.category &&
          date == other.date &&
          type == other.type &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      date.hashCode ^
      type.hashCode ^
      notes.hashCode;
}
