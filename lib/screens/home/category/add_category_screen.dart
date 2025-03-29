import 'package:flutter/material.dart';
import 'package:mina/theme/color.dart';
import 'package:mina/services/category_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryService = CategoryService();
  bool _isLoading = false;
  File? _selectedImage;
  String? _selectedIcon;

  final List<String> _predefinedIcons = [
    '🍔',
    '🍕',
    '🍜',
    '🍱',
    '🍣',
    '🍰',
    '☕',
    '🍺',
    '🚗',
    '🚌',
    '🚲',
    '✈️',
    '🚇',
    '🚕',
    '🚶',
    '🚶‍♂️',
    '🛍️',
    '👕',
    '👖',
    '👟',
    '👜',
    '💼',
    '🛒',
    '🎁',
    '🏠',
    '🏢',
    '🏥',
    '🏫',
    '🏪',
    '🏨',
    '🏦',
    '🏰',
    '💊',
    '🏥',
    '👨‍⚕️',
    '💉',
    '🩺',
    '🧬',
    '🧪',
    '🔬',
    '📚',
    '✏️',
    '📝',
    '📖',
    '🎓',
    '📋',
    '📎',
    '✂️',
    '🎮',
    '🎲',
    '🎯',
    '🎨',
    '🎭',
    '🎪',
    '🎟️',
    '🎠',
    '💸',
    '💰',
    '💵',
    '💳',
    '💴',
    '💶',
    '💷',
    '💹',
    '📱',
    '💻',
    '🖥️',
    '📱',
    '⌚',
    '📷',
    '📹',
    '🎥',
    '🏃',
    '⚽',
    '🏀',
    '🏈',
    '⚾',
    '🏸',
    '🏓',
    '🏒',
    '🌳',
    '🌲',
    '🌵',
    '🌴',
    '🌺',
    '🌸',
    '🌼',
    '🌻',
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🌞',
    '🌝',
    '⭐',
    '🌟',
    '💫',
    '✨',
    '🌙',
    '☀️',
    '🎵',
    '🎶',
    '🎸',
    '🎹',
    '🎺',
    '🎻',
    '🥁',
    '🎼',
    '🍳',
    '🍴',
    '🍽️',
    '🥄',
    '🥢',
    '🥣',
    '🥤',
    '🍼',
    '🚽',
    '🚰',
    '🚿',
    '🛁',
    '🧼',
    '🧽',
    '🧴',
    '🧹',
    '💡',
    '🔦',
    '🕯️',
    '💪',
    '🧠',
    '❤️',
    '🧡',
    '💛',
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _selectedIcon = null; // Clear selected icon when picking image
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null && _selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image or an icon')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create request data without null values
      final Map<String, dynamic> categoryData = {
        'name': _nameController.text,
      };

      // Only add image or icon if they are not null
      if (_selectedImage != null) {
        categoryData['image'] = _selectedImage!.path;
      }
      if (_selectedIcon != null) {
        categoryData['icon'] = _selectedIcon;
      }

      final result = await _categoryService.createCategory(categoryData);

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Failed to add category')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Category',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Icon or Upload Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          )
                        : _selectedIcon != null
                            ? Center(
                                child: Text(
                                  _selectedIcon!,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              )
                            : const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Icon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _predefinedIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _predefinedIcons[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                          _selectedImage =
                              null; // Clear selected image when choosing icon
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedIcon == icon
                                ? Colors.blue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
