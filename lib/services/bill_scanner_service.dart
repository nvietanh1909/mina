import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mina/services/api_service.dart';
import 'dart:convert';
import 'package:mina/services/vision_api.dart';

class BillScanResult {
  final double amount;
  final String date;
  final String category;
  final String notes;
  final String icon;
  final String type;
  final bool needNewCategory;
  final List<Map<String, dynamic>>? suggestedCategories;

  BillScanResult({
    required this.amount,
    required this.date,
    required this.category,
    required this.notes,
    required this.icon,
    required this.type,
    this.needNewCategory = false,
    this.suggestedCategories,
  });

  factory BillScanResult.fromJson(Map<String, dynamic> json) {
    print('Processing BillScanResult JSON: $json');

    try {
      // Check if we need to create a new category
      if (json['needNewCategory'] == true) {
        return BillScanResult(
          amount: json['transactionData']['amount'].toDouble(),
          date: json['transactionData']['date'],
          category: json['transactionData']['category'],
          notes: json['transactionData']['notes'],
          icon: '', // Icon will be set later
          type: json['transactionData']['type'],
          needNewCategory: true,
          suggestedCategories: json['suggestedCategories'],
        );
      }

      // Validate required fields
      if (json['amount'] == null) {
        throw Exception('Amount is required in response');
      }
      if (json['date'] == null) {
        throw Exception('Date is required in response');
      }

      // Convert amount to double safely
      double amount;
      if (json['amount'] is int) {
        amount = json['amount'].toDouble();
      } else if (json['amount'] is double) {
        amount = json['amount'];
      } else {
        throw Exception('Invalid amount format in response');
      }

      // Validate amount is positive
      if (amount <= 0) {
        throw Exception('Amount must be positive');
      }

      // Validate category
      if (json['category'] == null || json['category'].toString().isEmpty) {
        throw Exception('Category is required in response');
      }

      return BillScanResult(
        amount: amount,
        date: json['date'],
        category: json['category'],
        notes: json['notes'] ?? '',
        icon: json['icon'] ?? '',
        type: json['type'] ?? 'expense',
      );
    } catch (e) {
      print('Error in BillScanResult.fromJson: $e');
      throw Exception('Failed to parse bill scan result: $e');
    }
  }

  // Helper method to format date for display
  String getFormattedDate() {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      print('Error formatting date: $e');
      return date; // Return original string if parsing fails
    }
  }
}

class BillScannerService {
  final AuthService _authService;
  static const int maxTextLength = 10000; // Maximum length for text input

  BillScannerService(this._authService);

  Future<String> scanBill(File imageFile) async {
    try {
      print('Starting bill scan for image: ${imageFile.path}');

      // Sử dụng Google Vision API để phân tích ảnh
      final result = await GoogleVisionApi.analyzeImage(imageFile);
      print('Vision API response received');

      // Trích xuất văn bản từ kết quả
      final responses = result['responses'];
      if (responses != null && responses.isNotEmpty) {
        final textAnnotations = responses[0]['textAnnotations'];
        if (textAnnotations != null && textAnnotations.isNotEmpty) {
          final text = textAnnotations[0]['description'];
          print('Extracted text length: ${text.length}');
          print('Extracted text: $text'); // Log the extracted text
          return text;
        }
      }

      print('No text found in image');
      return '';
    } catch (e) {
      print('Error in scanBill: $e');
      throw Exception('Error scanning bill with Vision API: $e');
    }
  }

  Future<BillScanResult> analyzeBillText(String text) async {
    try {
      // Validate input text
      if (text.isEmpty) {
        throw Exception('Input text cannot be empty');
      }

      if (text.length > maxTextLength) {
        throw Exception(
            'Input text exceeds maximum length of $maxTextLength characters');
      }

      // Clean and normalize text
      final cleanedText = _cleanText(text);
      print('Cleaned text length: ${cleanedText.length}');
      print('Cleaned text: $cleanedText'); // Log the cleaned text

      // Retry mechanism for API calls
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          final response = await _authService.getAuthenticatedData(
            '/api/bills/analyze',
            method: 'POST',
            body: {'text': cleanedText},
          );

          print('API Response received: ${response['success']}');
          print(
              'API Response data: ${response['data']}'); // Log the full response data

          if (response['success'] == true && response['data'] != null) {
            final result = BillScanResult.fromJson(response['data']);
            print(
                'Parsed result: category=${result.category}, amount=${result.amount}, date=${result.date}');
            return result;
          } else {
            throw Exception(response['message'] ?? 'Failed to analyze bill');
          }
        } catch (e) {
          retryCount++;
          if (retryCount == maxRetries) {
            throw e;
          }
          print('Retry attempt $retryCount after error: $e');
          await Future.delayed(
              Duration(seconds: retryCount)); // Exponential backoff
        }
      }

      throw Exception('Failed to analyze bill after $maxRetries attempts');
    } catch (e) {
      print('Error in analyzeBillText: $e');
      throw Exception('Error analyzing bill: $e');
    }
  }

  String _cleanText(String text) {
    // Remove extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove special characters that might cause issues
    text = text.replaceAll(RegExp(r'[^\w\s.,!?-]'), '');

    // Normalize line endings
    text = text.replaceAll(RegExp(r'\r\n|\r|\n'), '\n');

    return text;
  }
}
