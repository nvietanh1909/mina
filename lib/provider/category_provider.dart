import 'package:flutter/material.dart';
import 'package:mina/model/category_model.dart';
import 'package:mina/services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final _authService = AuthService();
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.getAuthenticatedData('/api/categories');
      _categories = (response['data'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCategory(String name, List<String> icons) async {
    try {
      final response = await _authService.getAuthenticatedData(
        '/api/categories',
        method: 'POST',
        body: {
          'name': name,
          'icons': icons.map((icon) => {
            'iconPath': icon,
            'color': '#000000'
          }).toList(),
        },
      );
      
      final newCategory = Category.fromJson(response['data']);
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      print('Error creating category: $e');
    }
  }

  Future<void> updateCategory(String id, String name, List<String> icons) async {
    try {
      final response = await _authService.getAuthenticatedData(
        '/api/categories/$id',
        method: 'PUT',
        body: {
          'name': name,
          'icons': icons.map((icon) => {
            'iconPath': icon,
            'color': '#000000'
          }).toList(),
        },
      );

      final updatedCategory = Category.fromJson(response['data']);
      final index = _categories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _authService.getAuthenticatedData(
        '/api/categories/$id',
        method: 'DELETE',
      );
      
      _categories.removeWhere((cat) => cat.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting category: $e');
    }
  }
}