class Category {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final String? userId;
  final bool isDefault;
  final List<CategoryIcon> icons;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.userId,
    required this.isDefault,
    required this.icons,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      userId: json['userId'],
      isDefault: json['isDefault'],
      icons: (json['icons'] as List)
          .map((iconJson) => CategoryIcon.fromJson(iconJson))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'icons': icons.map((icon) => icon.toJson()).toList(),
    };
  }
}

class CategoryIcon {
  final String iconPath;
  final String color;
  final String id;

  CategoryIcon({
    required this.iconPath,
    required this.color,
    required this.id,
  });

  factory CategoryIcon.fromJson(Map<String, dynamic> json) {
    return CategoryIcon(
      iconPath: json['iconPath'],
      color: json['color'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iconPath': iconPath,
      'color': color,
    };
  }
}
