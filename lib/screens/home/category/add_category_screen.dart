import 'package:flutter/material.dart';
import 'package:mina/theme/color.dart';
import 'package:mina/services/category_service.dart';
import 'package:mina/model/category_model.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryService = CategoryService();
  bool _isLoading = false;
  String? _selectedIcon;
  Color _selectedColor = Colors.blue;
  List<CategoryIcon> _selectedIcons = [];

  final List<Color> _predefinedColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lightBlue,
  ];

  final List<String> _predefinedIcons = [
    // Food & Drinks
    '🍔', '🍕', '🍜', '🍱', '🍣', '🍰', '☕', '🍺', '🍷', '🍸', '🍹', '🍪', '🍫',
    '🍬', '🍭', '🍮', '🍯', '🍼', '🥛', '🥤',
    '🥣', '🥗', '🥘', '🥫', '🍝', '🍞', '🥐', '🥖', '🥨', '🧀', '🥚', '🥩',
    '🥓', '🥪', '🌮', '🌯', '🥙', '🥟', '🥠', '🥡',

    // Transportation
    '🚗', '🚌', '🚲', '✈️', '🚇', '🚕', '🚛', '🚚', '🚜', '🚎', '🚐', '🚑',
    '🚒', '🚓', '🚔', '🚖', '🚘', '🚍', '🚋', '🚊',
    '🚉', '🚞', '🚝', '🚄', '🚅', '🚈', '🚂', '🚃', '🚋', '🚌', '🚎', '🚐',
    '🚑', '🚒', '🚓', '🚔', '🚕', '🚖', '🚗', '🚘',

    // Shopping & Fashion
    '🛍️', '👕', '👖', '👟', '👜', '💼', '🛒', '🎁', '👗', '👠', '👡', '👢',
    '👞', '👟', '🧢', '🧣', '🧤', '🧥', '🧦', '👙',
    '👚', '👛', '👜', '👝', '🎒', '💼', '🕶️', '👓', '💍', '💎', '💄', '💅',
    '💇', '💆', '💃', '🕺', '👯', '👯‍♂️', '👯‍♀️', '👨‍🦯',

    // Buildings & Places
    '🏠', '🏢', '🏥', '🏫', '🏪', '🏨', '🏦', '🏭', '🏰', '🏯', '🏛️', '🏗️',
    '🏘️', '🏙️', '🏚️', '🏛️', '🏜️', '🏝️', '🏞️', '🏟️',
    '🏠', '🏡', '🏢', '🏣', '🏤', '🏥', '🏦', '🏨', '🏩', '🏪', '🏫', '🏬',
    '🏭', '🏯', '🏰', '💒', '🏛️', '⛪', '🕌', '🕍',

    // Education & Work
    '💊', '📚', '✏️', '📝', '🎓', '💸', '💰', '💵', '💳', '💻', '📱', '⌚', '📷',
    '🎮', '🎨', '🎵', '🏃', '⚽', '🌳', '🌺',
    '📖', '📗', '📘', '📙', '📚', '📓', '📒', '📑', '📋', '📎', '✂️', '📏',
    '📌', '📍', '✒️', '✏️', '🖊️', '🖋️', '🖌️', '🖍️',

    // Sports & Activities
    '🏃', '⚽', '🏀', '🏈', '⚾', '🏉', '🎾', '🏐', '🏓', '🏸', '🏒', '🏑', '🏏',
    '🥅', '⛳', '🏹', '🎣', '🥊', '🥋', '🎽',
    '🏅', '🎖️', '🏆', '🏋️', '🤸', '⛹️', '🤾', '🏊', '🏄', '🚣', '🏇', '🚴',
    '🚵', '🎯', '🎲', '🎰', '🎳', '🎪', '🎭', '🎨',

    // Nature & Animals
    '🌳', '🌺', '🐶', '🐱', '💡', '🔦', '💪', '❤️', '🌲', '🌴', '🌵', '🌷',
    '🌸', '🌹', '🌻', '🌼', '🌽', '🌾', '🌿', '🍀',
    '🍁', '🍂', '🍃', '🌍', '🌎', '🌏', '🌕', '🌖', '🌗', '🌘', '🌑', '🌒',
    '🌓', '🌔', '🌙', '⭐', '🌟', '💫', '✨', '☄️',

    // Emojis & Symbols
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔', '❣️', '💕',
    '💞', '💓', '💗', '💖', '💘', '💝', '💟', '☮️',
    '✝️', '☪️', '🕉️', '☸️', '✡️', '🔯', '🕎', '☯️', '☦️', '🛐', '⛎', '♈', '♉',
    '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑',

    // Objects & Tools
    '💡', '🔦', '💪', '❤️', '🔨', '🪛', '🔧', '🪜', '🧰', '🧲', '⚖️', '🔗',
    '⛓️', '🧪', '🧫', '🧬', '🔬', '🔭', '📡', '💉',
    '🩸', '💊', '🩹', '🩺', '🧴', '🧷', '🧹', '🧺', '🧻', '🚽', '🚰', '🚿',
    '🛁', '🧼', '🧽', '🧯', '🛒', '🚬', '⚰️', '⚱️',

    // Time & Weather
    '⌚', '📱', '📲', '💻', '⌨️', '🖥️', '🖨', '🖱️', '🖲️', '🕹️', '🗜️', '💽',
    '💾', '💿', '📀', '📼', '📷', '📸', '📹', '🎥',
    '📽️', '🎞️', '📞', '☎️', '📟', '📠', '📺', '📻', '🎙️', '🎚️', '🎛️', '🧭',
    '⏱️', '⏲️', '⏰', '🕰️', '⌛', '⏳', '📡', '🔋',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIcons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one icon')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> categoryData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'icon': _selectedIcons.first.iconPath,
        'color': '#${_selectedColor.value.toRadixString(16).substring(2)}',
        'icons': _selectedIcons
            .map((icon) => {
                  'iconPath': icon.iconPath,
                  'color':
                      '#${_selectedColor.value.toRadixString(16).substring(2)}'
                })
            .toList(),
      };

      print('Sending category data: $categoryData'); // Debug log

      final result = await _categoryService.createCategory(categoryData);

      if (!mounted) return;

      if (result['success']) {
        // Return true to indicate successful creation
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to create category'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in _handleSubmit: $e'); // Debug log
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleIcon(String icon) {
    setState(() {
      if (_selectedIcons.any((i) => i.iconPath == icon)) {
        _selectedIcons.removeWhere((i) => i.iconPath == icon);
      } else {
        _selectedIcons.add(CategoryIcon(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          iconPath: icon,
          color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ADD CATEGORY',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _handleSubmit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _predefinedColors.length,
                    itemBuilder: (context, index) {
                      final color = _predefinedColors[index];
                      final isSelected = _selectedColor == color;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                            // Update color for all selected icons
                            _selectedIcons = _selectedIcons.map((icon) {
                              return CategoryIcon(
                                id: icon.id,
                                iconPath: icon.iconPath,
                                color:
                                    '#${color.value.toRadixString(16).substring(2)}',
                              );
                            }).toList();
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Icons',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _predefinedIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _predefinedIcons[index];
                      final isSelected =
                          _selectedIcons.any((i) => i.iconPath == icon);
                      return InkWell(
                        onTap: () => _toggleIcon(icon),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? _selectedColor
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
                if (_selectedIcons.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Selected Icons',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _selectedIcons.length,
                      itemBuilder: (context, index) {
                        final icon = _selectedIcons[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _selectedColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    icon.iconPath,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => _toggleIcon(icon.iconPath),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
