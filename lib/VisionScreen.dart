import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mina/services/vision_api.dart';

class VisionScreen extends StatefulWidget {
  @override
  _VisionScreenState createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  File? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _results;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _results = null;
      });
    }
  }
  
  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await GoogleVisionApi.analyzeImage(_image!);
      setState(() {
        _results = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_image != null) ...[
              Image.file(_image!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _analyzeImage,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Phân tích ảnh'),
              ),
            ],
            
            if (_results != null) ...[
              SizedBox(height: 20),
              Text('Kết quả phân tích:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildResults(),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceDialog(),
        tooltip: 'Chọn ảnh',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildResults() {
    final responses = _results?['responses'] as List?;
    if (responses == null || responses.isEmpty) {
      return Text('Không có kết quả');
    }

    final response = responses.first;
    
    // Hiển thị nhãn
    final labels = response['labelAnnotations'] as List?;
    final textResults = response['textAnnotations'] as List?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labels != null && labels.isNotEmpty) ...[
          Text('Các đối tượng được nhận diện:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...labels.map((label) {
            final description = label['description'];
            final score = (label['score'] * 100).toStringAsFixed(1);
            return Text('• $description ($score%)');
          }).toList(),
          SizedBox(height: 20),
        ],
        
        if (textResults != null && textResults.isNotEmpty) ...[
          Text('Văn bản được nhận diện:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(textResults.first['description'] ?? 'Không có văn bản'),
        ],
      ],
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chọn nguồn ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Thư viện ảnh'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}