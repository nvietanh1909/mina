class Category {
  final String id;
  final String name;
  final String icon; // Sẽ lưu emoji làm icon

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var icons = json['icons'] as List;
    return Category(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      icon: icons.isNotEmpty
          ? icons[0]['iconPath']
          : '🏷️', // Lấy icon đầu tiên, mặc định là '🏷️'
    );
  }
}
