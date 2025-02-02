import 'package:flutter/material.dart';
import 'package:mina/screens/home/category/category_screen.dart';
import 'package:mina/screens/home/date/date_screen.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  final Widget currentScreen;

  const TransactionScreen({super.key, required this.currentScreen});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool isExpense = true;
  bool isIncome = false;
  bool isTransfer = false;

  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    amountController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ngày hiện tại và định dạng
    String formattedDate = DateFormat('d MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
        title: const Center(
          child: Text(
            'NEW TRANSACTION',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle save button press
            },
            child: const Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceEvenly, // Tạo khoảng cách giữa các nút
                children: [
                  buildTransactionTypeButton('EXPENSE', isExpense),
                  buildTransactionTypeButton('INCOME', isIncome),
                  buildTransactionTypeButton('TRANSFER', isTransfer),
                ],
              ),
              const SizedBox(height: 20),

              // Ô nhập tiền
              Center(
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixStyle:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Các dòng chọn
              buildSelectableField('Category', 'CHOOSE'),
              buildSelectableField('Date', formattedDate), // Sử dụng ngày hiện tại
              buildSelectableField('Account', 'Default'),
              buildSelectableField('Repeating', 'No'),
              buildNotesField('Notes'),
            ],
          ),
        ),
      ),
    );
  }

  // Button loại giao dịch
  Widget buildTransactionTypeButton(String label, bool isActive) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isExpense = label == 'EXPENSE';
          isIncome = label == 'INCOME';
          isTransfer = label == 'TRANSFER';
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFFE8885C) : Colors.white,
        foregroundColor: isActive ? Colors.white : Colors.black,
        side:
            BorderSide(color: isActive ? const Color(0xFFE8885C) : Colors.grey),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(label),
    );
  }

  // Dòng chọn (có border bottom)
  Widget buildSelectableField(String label, String value) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (label == "Category") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CategoryScreen()),
              );
            } else if (label == "Date") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DateScreen()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400)),
                Row(
                  children: [
                    Text(value, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1.4, // Border dày 1.4px
          color: const Color(0xFFE1E1E1), // Màu xám nhạt
        ),
      ],
    );
  }

  // Ô nhập notes
  Widget buildNotesField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            hintText: 'Enter notes...',
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
