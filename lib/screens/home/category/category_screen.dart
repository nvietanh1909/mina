import 'package:flutter/material.dart';
import 'package:mina/screens/home/transaction/transaction_screen.dart';
import 'new_category_screen.dart';

class Category {
  final String name;
  final String imageUrl;

  Category({required this.name, required this.imageUrl});
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<Category> categories = [
    Category(name: 'Fruits', imageUrl: 'assets/images/fruits.png'),
    Category(name: 'Veggie', imageUrl: 'assets/images/veggie.png'),
    Category(name: 'Fish', imageUrl: 'assets/images/fish.png'),
    Category(name: 'Meat', imageUrl: 'assets/images/meat.png'),
    Category(name: 'Dairy', imageUrl: 'assets/images/dairy.png'),
    Category(name: 'Grains', imageUrl: 'assets/images/grains.png'),
    Category(name: 'Beverages', imageUrl: 'assets/images/beverages.png'),
    Category(name: 'Snacks', imageUrl: 'assets/images/snacks.png'),
    Category(name: 'Condiments', imageUrl: 'assets/images/condiments.png'),
    Category(name: 'Frozen Foods', imageUrl: 'assets/images/frozen.png'),
    Category(name: 'Bakery', imageUrl: 'assets/images/bakery.png'),
    Category(name: 'Spices', imageUrl: 'assets/images/spices.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Căn giữa tiêu đề
        title: const Text(
          'CATEGORY',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const TransactionScreen(currentScreen: CategoryScreen())),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
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
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.black
                      .withOpacity(0.5), // Màu chữ Search opacity 50%
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: const Color(0xFFE2E2E2), // Màu nền ô search
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Bo góc 8px
                  borderSide: BorderSide.none, // Xóa border mặc định
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
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    print('Selected category: ${category.name}');
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
                            fontSize: 14, fontWeight: FontWeight.w500),
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
