import 'package:flutter/material.dart';
import 'package:mina/model/transaction_model.dart';
import 'package:mina/provider/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Transaction? _transaction;
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    try {
      final transaction = await context
          .read<TransactionProvider>()
          .getTransaction(widget.transactionId);
      if (mounted) {
        setState(() {
          _transaction = transaction;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _transaction?.type == 'income';
    final mainColor = isIncome ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.black87),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_transaction != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.red),
                ),
                onPressed: () => _showDeleteConfirmation(context),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ))
          : _error != null
              ? _buildErrorState()
              : _transaction == null
                  ? _buildNotFoundState()
                  : _buildTransactionDetails(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTransaction,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Transaction not found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    final isIncome = _transaction!.type == 'income';
    final mainColor = isIncome ? Colors.green : Colors.red;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('EEEE, MMMM d, y');

    return Stack(
      children: [
        // Background gradient
        Container(
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                mainColor.shade100.withOpacity(0.5),
                Colors.grey.shade50,
              ],
            ),
          ),
        ),

        SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                // Header with amount
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: mainColor.shade100.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _transaction!.icon ?? (isIncome ? '💰' : '🛒'),
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currencyFormat.format(_transaction!.amount),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: mainColor.shade700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: mainColor.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: mainColor.shade200),
                        ),
                        child: Text(
                          isIncome ? 'Income' : 'Expense',
                          style: TextStyle(
                            color: mainColor.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Transaction details card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDetailItem(
                        'Category',
                        _transaction!.category ?? 'Other',
                        icon: Icons.category_outlined,
                        iconBgColor: Colors.blue.shade50,
                        iconColor: Colors.blue.shade400,
                      ),
                      _buildDetailItem(
                        'Date & Time',
                        dateFormat.format(_transaction!.date),
                        icon: Icons.event_outlined,
                        iconBgColor: Colors.purple.shade50,
                        iconColor: Colors.purple.shade400,
                      ),
                      if (_transaction!.notes?.isNotEmpty == true)
                        _buildDetailItem(
                          'Notes',
                          _transaction!.notes!,
                          icon: Icons.notes_outlined,
                          iconBgColor: Colors.orange.shade50,
                          iconColor: Colors.orange.shade400,
                          isLast: true,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value,
      {IconData? icon,
      Color? iconColor,
      Color? iconBgColor,
      bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: Colors.grey.shade100,
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor ?? Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon ?? Icons.info_outline,
              size: 22,
              color: iconColor ?? Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction() async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await context
          .read<TransactionProvider>()
          .deleteTransaction(_transaction!.id!);

      if (!mounted) return;

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green.shade100),
              const SizedBox(width: 12),
              const Text('Transaction deleted successfully'),
            ],
          ),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade100),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error deleting transaction: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !_isDeleting,
      builder: (context) => WillPopScope(
        onWillPop: () async => !_isDeleting,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Transaction',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this transaction? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isDeleting
                        ? null
                        : () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: _isDeleting
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isDeleting
                        ? null
                        : () {
                            Navigator.pop(context, true);
                            _deleteTransaction();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isDeleting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color.fromARGB(255, 231, 167, 173)),
                            ),
                          )
                        : const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.all(24),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      _deleteTransaction();
    }
  }
}
