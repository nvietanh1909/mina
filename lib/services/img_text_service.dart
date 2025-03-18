import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mina/services/bill_scanner_service.dart';
import 'package:mina/services/vision_api.dart';

class ImageTextDetectionService {
  final BillScannerService _billScannerService;
  final ImagePicker _imagePicker = ImagePicker();
  
  ImageTextDetectionService(this._billScannerService);

  // Phương thức để chọn ảnh từ thư viện
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Phương thức để chụp ảnh bằng camera
  Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  // Phương thức để nhận diện văn bản từ ảnh và phân tích kết quả
  Future<BillScanResult?> detectAndAnalyzeText(File imageFile) async {
    try {
      // Sử dụng Google Vision API để phát hiện văn bản
      final textContent = await _billScannerService.scanBill(imageFile);
      
      if (textContent.isNotEmpty) {
        // Phân tích văn bản để lấy thông tin hóa đơn
        final billResult = await _billScannerService.analyzeBillText(textContent);
        return billResult;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error detecting and analyzing text: $e');
      return null;
    }
  }
}
