import 'package:flutter/material.dart';
import 'accumulate_screen.dart';
import 'income_screen.dart';
import 'expense_screen.dart';

class TransactionScreen extends StatefulWidget {
  final Widget currentScreen; // Add the currentScreen parameter

  const TransactionScreen({super.key, required this.currentScreen});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "New Transaction",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold), // Đặt màu chữ tiêu đề là trắng
          ),
          backgroundColor: const Color.fromARGB(255, 43, 43, 43),
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: "EXPENSE"),
              Tab(text: "INCOME"),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
        ),
        body: const TabBarView(
          children: [
            ExpenseScreen(),
            IncomeScreen(),
          ],
        ),
      ),
    );
  }
}
