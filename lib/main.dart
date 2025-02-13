import 'package:flutter/material.dart';
import 'package:mina/provider/category_provider.dart';
import 'package:mina/screens/chatbot/chatbot_screen.dart';
import 'package:mina/provider/transaction_provider.dart';
import 'package:mina/provider/wallet_provider.dart';
import 'package:mina/screens/auth/login_screen.dart';
import 'package:mina/screens/home/home_screen.dart';
import 'package:mina/widgets/intro_screen.dart';
import 'package:mina/services/api_service.dart';
import 'package:mina/provider/auth_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadUser(),
        ),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mina',
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return authProvider.isAuthenticated ? HomeTab() : LoginScreen();
        },
      ),
    );
  }
}
