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
  Color _selectedColor = AppColors.skyBlue;
  String _selectedIcon = 'assets/icons/li_home.svg';
  final TextEditingController _nameController =
      TextEditingController(text: 'New Category');
  final FocusNode _nameFocusNode = FocusNode();

  final List<Color> _colors = [
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
  ];

  final List<String> _icons =
      List.generate(12, (index) => 'assets/icons/icon_${index + 1}.svg');

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        title: const Text(
          'New Category',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement save logic
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon Preview
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedColor.withOpacity(0.1),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      _selectedIcon,
                      width: 40,
                      height: 40,
                      color: _selectedColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category Name Input
              TextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Category Name',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Colors Section
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color,
                              width: 2,
                            ),
                          ),
                          child: _selectedColor == color
                              ? Icon(Icons.check, color: color, size: 24)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Icons Section
              const Text(
                'Icon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final iconPath = _icons[index];
                  final isSelected = _selectedIcon == iconPath;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = iconPath),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: _selectedColor, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          iconPath,
                          width: 24,
                          height: 24,
                          color: isSelected ? _selectedColor : Colors.grey[600],
                        ),
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
