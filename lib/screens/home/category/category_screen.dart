import 'package:flutter/material.dart';
import 'package:mina/screens/home/transaction/transaction_screen.dart';
import 'new_category_screen.dart';

class Category {
  final String id; 
  final String name;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<Category> categories = [
    Category(id: '1', name: 'Fruits', imageUrl: 'assets/images/fruits.png'),
    Category(id: '2', name: 'Veggie', imageUrl: 'assets/images/veggie.png'),
    Category(id: '3', name: 'Fish', imageUrl: 'assets/images/fish.png'),
    Category(id: '4', name: 'Meat', imageUrl: 'assets/images/meat.png'),
    Category(id: '5', name: 'Dairy', imageUrl: 'assets/images/dairy.png'),
    Category(id: '6', name: 'Grains', imageUrl: 'assets/images/grains.png'),
    Category(
        id: '7', name: 'Beverages', imageUrl: 'assets/images/beverages.png'),
    Category(id: '8', name: 'Snacks', imageUrl: 'assets/images/snacks.png'),
    Category(
        id: '9', name: 'Condiments', imageUrl: 'assets/images/condiments.png'),
    Category(
        id: '10', name: 'Frozen Foods', imageUrl: 'assets/images/frozen.png'),
    Category(id: '11', name: 'Bakery', imageUrl: 'assets/images/bakery.png'),
    Category(id: '12', name: 'Spices', imageUrl: 'assets/images/spices.png'),
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách category theo search query
    final filteredCategories = categories
        .where((category) =>
            category.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'CATEGORY',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(
                context); // Thay đổi thành pop để quay lại màn hình trước
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                // Thay đổi thành push thông thường
                context,
                MaterialPageRoute(
                    builder: (context) => const NewCategoryScreen()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: const Color(0xFFE2E2E2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(thickness: 1.4, color: Color(0xFFE1E1E1)),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
              ),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final category = filteredCategories[index];
                return GestureDetector(
                  onTap: () {
                    // Khi chọn category, trả về map chứa id và name
                    Navigator.pop(context, {
                      'id': category.id,
                      'name': category.name,
                    });
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(category.imageUrl),
                        radius: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
