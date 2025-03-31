import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mina/services/api_service.dart';
import 'package:mina/services/bill_scanner_service.dart';

class ScanBillScreen extends StatefulWidget {
  const ScanBillScreen({Key? key}) : super(key: key);

  @override
  State<ScanBillScreen> createState() => _ScanBillScreenState();
}

class _ScanBillScreenState extends State<ScanBillScreen> {
  File? _image;
  bool _isScanning = false;
  final ImagePicker _picker = ImagePicker();
  final billScannerService = BillScannerService(AuthService());

  @override
  void initState() {
    super.initState();
    _takePicture();
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _image = File(photo.path);
          _isScanning = true;
        });

        // Process the image
        await _processImage();
      } else {
        // User cancelled taking picture
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chụp ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;

    try {
      // Extract text from image
      final extractedText = await billScannerService.scanBill(_image!);
      print('Extracted text: $extractedText');

      // Analyze text with AI
      final result = await billScannerService.analyzeBillText(extractedText);
      print('Analysis result: $result');

      // Return result to previous screen
      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      print('Error processing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý hóa đơn: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Return to previous screen after error
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_image != null)
              Positioned.fill(
                child: Image.file(
                  _image!,
                  fit: BoxFit.contain,
                ),
              ),

            // Back button
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Loading indicator
            if (_isScanning)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang xử lý hóa đơn...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Retake button
            if (!_isScanning && _image != null)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: TextButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      'Chụp lại',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
