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

      final result = await _categoryService.createCategory(categoryData);

      if (!mounted) return;

      if (result['success']) {
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New Category',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: Colors.black87),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _isLoading ? null : _handleSubmit,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                        ),
                      )
                    : Icon(Icons.check, size: 20, color: Colors.blue[700]),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue[400]!),
                        ),
                        prefixIcon: Icon(Icons.category_outlined,
                            color: Colors.grey[600]),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
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
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue[400]!),
                        ),
                        prefixIcon: Icon(Icons.description_outlined,
                            color: Colors.grey[600]),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: _predefinedColors.length,
                      itemBuilder: (context, index) {
                        final color = _predefinedColors[index];
                        final isSelected = _selectedColor == color;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
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
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
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
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category Icons',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (_selectedIcons.isNotEmpty)
                        Text(
                          '${_selectedIcons.length} selected',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: _predefinedIcons.length,
                      itemBuilder: (context, index) {
                        final icon = _predefinedIcons[index];
                        final isSelected =
                            _selectedIcons.any((i) => i.iconPath == icon);
                        return InkWell(
                          onTap: () => _toggleIcon(icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _selectedColor.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? _selectedColor
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: _selectedColor.withOpacity(0.2),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                              ],
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
                ],
              ),
            ),
            if (_selectedIcons.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Icons',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _selectedIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _selectedIcons[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
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
                                Text(
                                  icon.iconPath,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => _toggleIcon(icon.iconPath),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: _selectedColor,
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
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
