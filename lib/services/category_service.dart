import 'package:mina/services/api_service.dart';
import 'package:mina/constans/constants.dart';

class CategoryService {
  final AuthService _authService = AuthService();
  final String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> createCategory(
      Map<String, dynamic> categoryData) async {
    try {
      final response = await _authService.getAuthenticatedData(
        '/api/categories',
        method: 'POST',
        body: categoryData,
      );

      if (response != null &&
          response['data'] != null &&
          response['data']['category'] != null) {
        return {
          'success': true,
          'id': response['data']['category']['id'],
          'message': 'Category created successfully'
        };
      } else {
        return {
          'success': false,
          'message': response?['message'] ?? 'Error creating category'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final response =
          await _authService.getAuthenticatedData('/api/categories');

      if (response != null &&
          response['data'] != null &&
          response['data']['categories'] != null) {
        final categories = response['data']['categories'] as List;
        return categories
            .map((category) => category as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting categories: ${e.toString()}');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCategoryById(String id) async {
    try {
      if (id.isEmpty) {
        return null;
      }

      final response =
          await _authService.getAuthenticatedData('/api/categories/$id');

      if (response != null &&
          response['data'] != null &&
          response['data']['category'] != null) {
        return response['data']['category'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting category: ${e.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>> updateCategory(
      String id, Map<String, dynamic> categoryData) async {
    try {
      if (id.isEmpty) {
        return {'success': false, 'message': 'Invalid category ID'};
      }

      final response = await _authService.getAuthenticatedData(
        '/api/categories/$id',
        method: 'PATCH',
        body: categoryData,
      );

      if (response != null && response['success'] == true) {
        return {'success': true, 'message': 'Category updated successfully'};
      } else {
        return {
          'success': false,
          'message': response?['message'] ?? 'Error updating category'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteCategory(String id) async {
    try {
      if (id.isEmpty) {
        return {'success': false, 'message': 'Invalid category ID'};
      }

      final response = await _authService.getAuthenticatedData(
        '/api/categories/$id',
        method: 'DELETE',
      );

      if (response != null && response['success'] == true) {
        return {'success': true, 'message': 'Category deleted successfully'};
      } else {
        return {
          'success': false,
          'message': response?['message'] ?? 'Error deleting category'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
