import 'package:flutter/material.dart';
import 'package:mina/screens/home/category/category_screen.dart';
import 'package:mina/screens/home/date/date_screen.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  String category = 'CHOOSE';
  String date = DateFormat('d MMM yyyy').format(DateTime.now());
  String account = 'Default';
  String repeating = 'No';

  @override
  void initState() {
    super.initState();
    amountController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildAmountField(),
              const SizedBox(height: 20),
              buildSelectableField('Category', category, () async {
                final selectedCategory = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryScreen()),
                );
                if (selectedCategory != null) {
                  setState(() {
                    category = selectedCategory;
                  });
                }
              }),
              buildSelectableField('Date', date, () async {
                final selectedDate = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DateScreen()),
                );
                if (selectedDate != null) {
                  setState(() {
                    date = selectedDate;
                  });
                }
              }),
              buildSelectableField('Account', account, () {
                // Logic to select account (if needed)
              }),
              buildSelectableField('Repeating', repeating, () {
                // Logic to select repeating
              }),
              buildNotesField('Notes', notesController),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAmountField() {
    return Center(
      child: SizedBox(
        width: 200,
        child: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 36, 
            fontWeight: FontWeight.w500, 
            height: 1.5,  // Tăng khoảng cách dòng ở đây
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget buildSelectableField(String label, String value, Function() onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5)), // Tăng khoảng cách dòng ở đây
                Row(
                  children: [
                    Text(value, style: const TextStyle(color: Colors.grey, height: 1.5)),  // Tăng khoảng cách dòng ở đây
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1.4, 
          color: const Color(0xFFE1E1E1),
        ),
      ],
    );
  }

  Widget buildNotesField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5)),  // Tăng khoảng cách dòng ở đây
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            hintText: 'Enter notes...',
          ),
          style: const TextStyle(height: 1.5),  // Tăng khoảng cách dòng ở đây
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
