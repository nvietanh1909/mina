import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CategoryService {
  static Database? _database;
  static const String tableName = 'categories';
  static const String dbName = 'mina.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            image TEXT,
            icon TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  Future<Map<String, dynamic>> createCategory(
      Map<String, dynamic> categoryData) async {
    try {
      final db = await database;

      // Handle image file if present
      if (categoryData.containsKey('image')) {
        String imagePath = categoryData['image'];
        if (imagePath.startsWith('file://')) {
          imagePath = imagePath.substring(7);
        }

        // Copy image to app's local storage
        File imageFile = File(imagePath);
        String fileName = path.basename(imagePath);
        String newPath = await _copyImageToLocalStorage(imageFile, fileName);
        categoryData['image'] = newPath;
      }

      final id = await db.insert(tableName, categoryData);

      return {
        'success': true,
        'id': id,
        'message': 'Category created successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating category: ${e.toString()}'
      };
    }
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final db = await database;
      return await db.query(tableName, orderBy: 'name ASC');
    } catch (e) {
      print('Error getting categories: ${e.toString()}');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print('Error getting category: ${e.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>> updateCategory(
      int id, Map<String, dynamic> categoryData) async {
    try {
      final db = await database;

      // Handle image file if present
      if (categoryData.containsKey('image')) {
        String imagePath = categoryData['image'];
        if (imagePath.startsWith('file://')) {
          imagePath = imagePath.substring(7);
        }

        // Copy image to app's local storage
        File imageFile = File(imagePath);
        String fileName = path.basename(imagePath);
        String newPath = await _copyImageToLocalStorage(imageFile, fileName);
        categoryData['image'] = newPath;
      }

      await db.update(
        tableName,
        categoryData,
        where: 'id = ?',
        whereArgs: [id],
      );

      return {'success': true, 'message': 'Category updated successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating category: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> deleteCategory(int id) async {
    try {
      final db = await database;

      // Get category to delete image if exists
      final category = await getCategoryById(id);
      if (category != null && category['image'] != null) {
        try {
          await File(category['image']).delete();
        } catch (e) {
          print('Error deleting image file: ${e.toString()}');
        }
      }

      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return {'success': true, 'message': 'Category deleted successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting category: ${e.toString()}'
      };
    }
  }

  Future<String> _copyImageToLocalStorage(
      File imageFile, String fileName) async {
    try {
      final dbPath = await getDatabasesPath();
      final dbDir = Directory(dbPath);
      final imagesDir = Directory('${dbDir.path}/images');

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final newPath = '${imagesDir.path}/$fileName';
      await imageFile.copy(newPath);
      return newPath;
    } catch (e) {
      print('Error copying image: ${e.toString()}');
      rethrow;
    }
  }
}
