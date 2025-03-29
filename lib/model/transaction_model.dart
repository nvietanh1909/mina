class Transaction {
  final String? id;
  final double amount;
  final String type;
  final String? category;
  final DateTime date;
  final String? notes;
  final String? icon;

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    this.category,
    required this.date,
    this.notes,
    this.icon,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      if (notes != null) 'notes': notes,
      'icon': icon,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          amount == other.amount &&
          type == other.type &&
          category == other.category &&
          date == other.date &&
          notes == other.notes &&
          icon == other.icon;

  @override
  int get hashCode =>
      id.hashCode ^
      amount.hashCode ^
      type.hashCode ^
      category.hashCode ^
      date.hashCode ^
      notes.hashCode ^
      icon.hashCode;
}
