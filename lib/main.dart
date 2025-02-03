import 'package:flutter/material.dart';
import 'package:mina/widgets/intro_screen.dart';
import 'package:mina/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
