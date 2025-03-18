import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GoogleVisionApi {
  static String get apiKey => dotenv.env['GOOGLE_VISION_API_KEY'] ?? '';
  static String get apiUrl =>
      'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

  static Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    // Chuyển đổi ảnh thành base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Tạo request body
    final body = jsonEncode({
      'requests': [
        {
          'image': {
            'content': base64Image,
          },
          'features': [
            {
              'type': 'LABEL_DETECTION',
              'maxResults': 10,
            },
            {
              'type': 'TEXT_DETECTION',
              'maxResults': 10,
            },
            // Thêm các tính năng khác nếu cần
          ],
        },
      ],
    });

    // Gửi request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to analyze image: ${response.statusCode}');
    }
  }
}
