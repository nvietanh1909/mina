import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:mina/services/api_service.dart';
import 'dart:convert';

class BillScanResult {
  final double amount;
  final String category;
  final String notes;

  BillScanResult({
    required this.amount,
    required this.category,
    required this.notes,
  });

  factory BillScanResult.fromJson(Map<String, dynamic> json) {
    return BillScanResult(
      amount: json['amount'].toDouble(),
      category: json['category'],
      notes: json['notes'],
    );
  }
}

class BillScannerService {
  final AuthService _authService;

  BillScannerService(this._authService);

  Future<String> scanBill(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } finally {
      textRecognizer.close();
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
