import 'package:flutter/material.dart';
import 'package:mina/widgets/intro_screen.dart';
import 'package:mina/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await ApiService.fetchMessage(); 
    print('API đã được gọi thành công!');
  } catch (e) {
    print('Lỗi khi kết nối API: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mina',
      debugShowCheckedModeBanner: false,
      home: IntroScreen(),
    );
  }
}
