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
  String _scanText = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Gọi chức năng chụp ảnh ngay khi màn hình được khởi tạo
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    }
  }

  Future<void> _processImage() async {
    try {
      if (_image == null) return;

      final billScannerService = BillScannerService(AuthService());

      // Extract text from image
      final extractedText = await billScannerService.scanBill(_image!);

      // Analyze text with AI
      final result = await billScannerService.analyzeBillText(extractedText);

      // Return result to previous screen
      Navigator.pop(context, result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_image != null)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                // Hình ảnh chụp
                Positioned.fill(
                  child: Image.file(
                    _image!,
                    fit: BoxFit.contain,
                  ),
                ),
                // Nút back
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Loading indicator khi đang xử lý
                if (_isScanning)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          )
        else
          // Màn hình camera
          GestureDetector(
            onTap: _takePicture,
            child: Container(
              color: Colors.black87,
              child: const Center(
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
