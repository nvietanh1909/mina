import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.1.9:5005';

  // Gửi request GET
  static Future<void> fetchMessage() async {
    final response = await http.get(Uri.parse('$baseUrl/api/data'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Server trả về: ${data['message']}");
    } else {
      throw Exception('Không thể kết nối tới server');
    }
  }

  // Gửi request POST
  static Future<void> sendData(String name, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/send'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Phản hồi từ server: ${data['message']}");
    } else {
      throw Exception('Gửi dữ liệu thất bại');
    }
  }
}
