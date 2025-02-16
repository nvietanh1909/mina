class Report {
  final String id;
  final String userId;
  final String type;
  final DateTime date;
  final double totalAmount;
  final Map<String, double>? categoryBreakdown;

  Report({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.totalAmount,
    this.categoryBreakdown,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'],
      userId: json['userId'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      totalAmount: json['totalAmount'].toDouble(),
      categoryBreakdown: json['categoryBreakdown'] != null
          ? Map<String, double>.from(json['categoryBreakdown'])
          : null,
    );
  }
}