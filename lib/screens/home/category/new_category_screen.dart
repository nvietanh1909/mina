import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'category_screen.dart';
import 'package:mina/theme/color.dart';

class NewCategoryScreen extends StatefulWidget {
  const NewCategoryScreen({Key? key}) : super(key: key);

  @override
  State<NewCategoryScreen> createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  Color _selectedColor = AppColors.skyBlue; // Initial selected color
  String _selectedIcon = 'assets/icons/li_home.svg'; // Initial selected icon

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CategoryScreen()),
            );
          },
        ),
        centerTitle: true, // Căn giữa tiêu đề
        title: const Text(
          'NEW CATEGORY',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle save action
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Wrap in SingleChildScrollView for long content
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.2), // Màu shadow
                      spreadRadius: 2, // Độ lan tỏa của shadow
                      blurRadius: 4, // Độ mờ của shadow
                      offset: const Offset(0, 2), // Độ lệch của shadow
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 79.5, // Bán kính là 159 / 2
                  backgroundColor: Colors.white,
                  child: SvgPicture.asset(
                    _selectedIcon,
                    width: 80, // Chiều rộng của hình ảnh
                    height: 80, // Chiều cao của hình ảnh
                    color: _selectedColor,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Fruits',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Color Selection
              Align(
                alignment: Alignment.centerLeft, // Căn trái
                child: const Text(
                  'COLORS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Thay Wrap bằng ListView để kéo ngang
              SizedBox(
                height: 60, // Độ cao của ListView
                child: ListView(
                  scrollDirection: Axis.horizontal, // Kéo ngang
                  children: [
                    for (var color in [
                      AppColors.lightBlue,
                      AppColors.skyBlue,
                      AppColors.turquoise,
                      AppColors.pastelPink,
                      AppColors.coral,
                      AppColors.peach,
                      AppColors.limeGreen,
                      AppColors.lightYellow,
                      AppColors.lavender,
                      AppColors.mintGreen,
                      AppColors.softPurple,
                      AppColors.pastelOrange,
                      AppColors.lightRed,
                      AppColors.watermelon,
                      AppColors.cherryRed,
                      AppColors.electricBlue,
                      AppColors.cobaltBlue,
                      AppColors.azure,
                      AppColors.mint,
                      AppColors.emeraldGreen,
                      AppColors.neonGreen,
                      AppColors.lemonYellow,
                      AppColors.goldenYellow,
                      AppColors.canaryYellow,
                      AppColors.primaryColor,
                      AppColors.secondaryColor,
                      AppColors.accentColor,
                      AppColors.backgroundColor,
                      AppColors.errorColor,
                      AppColors.gradientStart,
                      AppColors.gradientEnd,
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2.0), // Thêm khoảng cách giữa các màu
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: color,
                            child: _selectedColor == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Icon Selection
              Align(
                alignment: Alignment.centerLeft, // Căn trái
                child: const Text(
                  'ICON',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap:
                    true, // Important to prevent GridView from taking all available space
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling in GridView
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: 36, // Number of icons
                itemBuilder: (context, index) {
                  // Replace with your actual icon assets
                  final iconPath = 'assets/icons/icon_${index + 1}.svg';
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconPath;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: AppColors.grey,
                      child: SvgPicture.asset(
                        iconPath,
                        width: 24,
                        height: 24,
                        color: _selectedIcon == iconPath
                            ? AppColors.primaryColor
                            : AppColors.grey,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
