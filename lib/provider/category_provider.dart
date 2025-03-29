import 'package:flutter/material.dart';
import 'package:mina/model/category_model.dart';
import 'package:mina/services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final _authService = AuthService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response =
          await _authService.getAuthenticatedData('/api/categories');
      if (response['success'] == true) {
        _categories = (response['data'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
      } else {
        _error = 'Failed to load categories';
      }
    } catch (e) {
      _error = 'Error loading categories: $e';
      print('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCategory(String name, String description, String icon,
      String color, List<CategoryIcon> icons) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authService.getAuthenticatedData(
        '/api/categories',
        method: 'POST',
        body: {
          'name': name,
          'description': description,
          'icon': icon,
          'color': color,
          'isDefault': false,
          'icons': icons.map((icon) => icon.toJson()).toList(),
        },
      );

      if (response['success'] == true) {
        final newCategory = Category.fromJson(response['data']);
        _categories.add(newCategory);
      } else {
        _error = 'Failed to create category';
      }
    } catch (e) {
      _error = 'Error creating category: $e';
      print('Error creating category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(String id, String name, String description,
      String icon, String color, List<CategoryIcon> icons) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authService.getAuthenticatedData(
        '/api/categories/$id',
        method: 'PUT',
        body: {
          'name': name,
          'description': description,
          'icon': icon,
          'color': color,
          'icons': icons.map((icon) => icon.toJson()).toList(),
        },
      );

      if (response['success'] == true) {
        final updatedCategory = Category.fromJson(response['data']);
        final index = _categories.indexWhere((cat) => cat.id == id);
        if (index != -1) {
          _categories[index] = updatedCategory;
        }
      } else {
        _error = 'Failed to update category';
      }
    } catch (e) {
      _error = 'Error updating category: $e';
      print('Error updating category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authService.getAuthenticatedData(
        '/api/categories/$id',
        method: 'DELETE',
      );

      if (response['success'] == true) {
        _categories.removeWhere((cat) => cat.id == id);
      } else {
        _error = 'Failed to delete category';
      }
    } catch (e) {
      _error = 'Error deleting category: $e';
      print('Error deleting category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
