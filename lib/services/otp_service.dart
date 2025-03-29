import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:mina/constans/constants.dart';

class OTPService {
  final String baseUrl = AppConfig.baseUrl;

  // Gửi yêu cầu OTP
  Future<Map<String, dynamic>> requestOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Xác thực OTP
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      print('Frontend - Sending OTP: $otp (${otp.runtimeType})');

      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      print('Frontend - Response status: ${response.statusCode}');
      print('Frontend - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      print('Frontend - Error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
