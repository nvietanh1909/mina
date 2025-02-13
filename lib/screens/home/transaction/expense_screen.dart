import 'package:flutter/material.dart';
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
  String date = DateFormat('d MMM yyyy').format(DateTime.now());
  String selectedWalletId = '';
  String selectedWalletName = 'Choose Wallet';
  bool _isLoading = false;

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

      print('Creating expense transaction with data:');
      print('Amount: $amount');
      print('Category: $categoryId');
      print('Wallet: $selectedWalletId');
      print('Date: $date');

      final transaction = Transaction(
        amount: amount,
        type: 'expense',
        category: category,
        date: DateFormat('d MMM yyyy').parse(date),
        notes: notesController.text,
      );

      await context.read<TransactionProvider>().createTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm chi tiêu thành công')),
        );
        Navigator.pop(context, true);
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
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAmountField(),
                  const SizedBox(height: 20),
                  buildSelectableField('Category', category, () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CategoryScreen()),
                    );
                    if (result != null) {
                      setState(() {
                        category = result['name'];
                        categoryId = result['id'];
                      });
                    }
                  }),
                  buildSelectableField('Date', date, () async {
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
                  }),
                  buildSelectableField(
                    'Wallet',
                    selectedWalletName,
                    _showWalletPicker,
                  ),
                  buildNotesField('Notes', notesController),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveExpense,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 32,
                          ),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
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
            height: 1.5, // Tăng khoảng cách dòng ở đây
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
                Text(label,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.5)), // Tăng khoảng cách dòng ở đây
                Row(
                  children: [
                    Text(value,
                        style: const TextStyle(
                            color: Colors.grey,
                            height: 1.5)), // Tăng khoảng cách dòng ở đây
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
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5)), // Tăng khoảng cách dòng ở đây
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            hintText: 'Enter notes...',
          ),
          style: const TextStyle(height: 1.5), // Tăng khoảng cách dòng ở đây
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
