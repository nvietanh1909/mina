import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mina/services/api_service.dart';
import 'dart:convert';
import 'package:mina/services/vision_api.dart'; 

class BillScanResult {
  final double amount;
  final DateFormat date;
  final String category;
  final String notes;

  BillScanResult({
    required this.amount,
    required this.date,
    required this.category,
    required this.notes,
  });

  factory BillScanResult.fromJson(Map<String, dynamic> json) {
    return BillScanResult(
      amount: json['amount'].toDouble(),
      date: json['date'],
      category: json['category'],
      notes: json['notes'],
    );
  }
}

class BillScannerService {
  final AuthService _authService;

  BillScannerService(this._authService);

  Future<String> scanBill(File imageFile) async {
    try {
      // Sử dụng Google Vision API để phân tích ảnh
      final result = await GoogleVisionApi.analyzeImage(imageFile);

      // Trích xuất văn bản từ kết quả
      final responses = result['responses'];
      if (responses != null && responses.isNotEmpty) {
        final textAnnotations = responses[0]['textAnnotations'];

        if (textAnnotations != null && textAnnotations.isNotEmpty) {
          // Lấy toàn bộ văn bản từ kết quả đầu tiên
          return textAnnotations[0]['description'];
        }
      }

      return '';
    } catch (e) {
      throw Exception('Error scanning bill with Vision API: $e');
    }
  }

  Future<BillScanResult> analyzeBillText(String text) async {
    try {
      final response = await _authService.getAuthenticatedData(
        '/api/bills/analyze',
        method: 'POST',
        body: {'text': text},
      );

      return BillScanResult.fromJson(response['data']);
    } catch (e) {
      throw Exception('Error analyzing bill: $e');
    }
  }
}
