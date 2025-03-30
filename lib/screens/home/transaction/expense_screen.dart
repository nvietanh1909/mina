import 'package:flutter/material.dart';
import 'package:mina/screens/camera/scan_bill_screen.dart';
import 'package:mina/services/bill_scanner_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mina/model/transaction_model.dart';
import 'package:mina/provider/transaction_provider.dart';
import 'package:mina/provider/wallet_provider.dart';
import 'package:mina/screens/home/category/category_screen.dart';
import 'package:mina/screens/home/date/date_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  String category = 'CHOOSE';
  String categoryId = '';
  String categoryIcon = '';
  String date = DateFormat('d MMM yyyy').format(DateTime.now());
  String selectedWalletId = '';
  String selectedWalletName = 'Choose Wallet';
  bool _isLoading = false;
  final Color primaryColor = const Color(0xFF6C63FF); // Màu chủ đạo - tím nhẹ
  final Color secondaryColor =
      const Color(0xFFF5F7FF); // Màu nền phụ - xanh nhạt
  final Color accentColor = const Color(0xFFFF6B6B); // Màu nhấn - đỏ san hô
  final Color textColor = const Color(0xFF2D3142); // Màu chữ chính
  final Color subtleColor = const Color(0xFF9BA3AF); // Màu chữ phụ

  @override
  void initState() {
    super.initState();
    amountController.text = "0";
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    try {
      await context.read<WalletProvider>().loadWallets();
      final wallets = context.read<WalletProvider>().wallets;
      if (wallets.isNotEmpty) {
        setState(() {
          selectedWalletId = wallets[0].id;
          selectedWalletName = wallets[0].name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Không thể tải danh sách ví: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _openBillScanner() async {
    try {
      final result = await Navigator.push<BillScanResult>(
        context,
        MaterialPageRoute(builder: (context) => const ScanBillScreen()),
      );

      if (result != null) {
        setState(() {
          amountController.text = result.amount.toString();
          category = result.category;
          notesController.text = result.notes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning bill: $e')),
        );
      }
    }
  }

  Future<void> _saveExpense() async {
    if (category == 'CHOOSE') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }

    if (selectedWalletId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ví')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final amount = double.tryParse(amountController.text.replaceAll(',', ''));
      if (amount == null || amount <= 0) {
        throw Exception('Số tiền không hợp lệ');
      }

      // Check if wallet has enough balance
      final wallet = context
          .read<WalletProvider>()
          .wallets
          .firstWhere((w) => w.id == selectedWalletId);
      if (wallet.balance < amount) {
        throw Exception('Số dư trong ví không đủ');
      }

      final transaction = Transaction(
        amount: amount,
        type: 'expense',
        category: category,
        date: DateFormat('d MMM yyyy').parse(date),
        notes: notesController.text,
        icon: categoryIcon,
      );

      await context.read<TransactionProvider>().createTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm chi tiêu thành công')),
        );

        // Reset các trường thông tin
        setState(() {
          amountController.text = "0";
          notesController.text = "";
          category = 'CHOOSE';
          categoryId = '';
          categoryIcon = '';
          date = DateFormat('d MMM yyyy').format(DateTime.now());
        });
      }
    } catch (e) {
      print('Error in _saveExpense: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showWalletPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<WalletProvider>(
          builder: (context, walletProvider, child) {
            if (walletProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: walletProvider.wallets.length,
              itemBuilder: (context, index) {
                final wallet = walletProvider.wallets[index];
                return ListTile(
                  title: Text(wallet.name),
                  subtitle: Text('${wallet.balance} ${wallet.currency}'),
                  selected: wallet.id == selectedWalletId,
                  onTap: () {
                    setState(() {
                      selectedWalletId = wallet.id;
                      selectedWalletName = wallet.name;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Amount Field
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF766DE8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF766DE8).withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Enter Amount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Category, Date, Wallet Fields
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        buildSelectableFieldImproved(
                          'Scan Bill',
                          'Tap to scan',
                          Icons.camera_alt,
                          _openBillScanner,
                        ),
                        buildDivider(),
                        buildSelectableFieldImproved(
                          'Category',
                          category,
                          Icons.category_outlined,
                          () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CategoryScreen()),
                            );
                            if (result != null) {
                              setState(() {
                                category = result['name'];
                                categoryId = result['id'];
                                categoryIcon = result['icon'];
                              });
                            }
                          },
                        ),
                        buildDivider(),
                        buildSelectableFieldImproved(
                          'Date',
                          date,
                          Icons.calendar_today_outlined,
                          () async {
                            final selectedDate = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DateScreen()),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                date = selectedDate;
                              });
                            }
                          },
                        ),
                        buildDivider(),
                        buildSelectableFieldImproved(
                          'Wallet',
                          selectedWalletName,
                          Icons.account_balance_wallet_outlined,
                          _showWalletPicker,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Notes Field
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note_alt_outlined,
                                color: Colors.grey[600], size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: notesController,
                          decoration: InputDecoration(
                            hintText: 'Enter notes...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Save Button
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget buildSelectableFieldImproved(
    String label,
    String value,
    IconData icon,
    Function() onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 24, color: subtleColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: subtleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (label == 'Category' && categoryIcon.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Text(
                            categoryIcon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: subtleColor,
            ),
          ],
        ),
      ),
    );
  }
}
