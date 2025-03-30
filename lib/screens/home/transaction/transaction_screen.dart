import 'package:flutter/material.dart';
import 'accumulate_screen.dart';
import 'income_screen.dart';
import 'expense_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "New Transaction",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
