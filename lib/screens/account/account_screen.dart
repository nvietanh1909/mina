import 'package:flutter/material.dart';
import 'package:mina/model/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:mina/provider/transaction_provider.dart';
import 'saving_screen.dart';
import 'package:mina/utils/number_formatter.dart';
import 'package:intl/intl.dart';
import 'package:mina/screens/home/transaction/transaction_screen.dart';
import 'package:mina/provider/wallet_provider.dart';
import 'transaction_detail_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with WidgetsBindingObserver {
  Transaction? _recentTransaction;
  bool _isInitialized = false;
  DateTime? _lastRefreshTime;
  static const _refreshInterval = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTransactions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTransactions();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    try {
      await context.read<TransactionProvider>().fetchTransactions(
            refresh: true,
            limit: 100,
          );
      if (mounted) {
        setState(() {
          _lastRefreshTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải giao dịch: $e')),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Account",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 43, 43, 43),
          elevation: 0,
          centerTitle: true,
          actions: [
            /** IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _showDateRangePicker(context),
            ), */
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                // Handle notification action
              },
            ),
          ],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: "ACCOUNT"),
              Tab(text: "SAVING"),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
        ),
        body: TabBarView(
          children: [
            AccountTab(
              onTransactionAdded: (transaction) {
                setState(() {
                  _recentTransaction = transaction;
                });
              },
              recentTransaction: _recentTransaction,
            ),
            const SavingScreen(),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Date Range',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Flexible(child: child!),
              ],
            ),
          ),
        );
      },
    );

    if (pickedDateRange != null) {
      print(
          'Selected date range: ${pickedDateRange.start} to ${pickedDateRange.end}');
    }
  }
}

class AccountTab extends StatefulWidget {
  final Function(Transaction) onTransactionAdded;
  final Transaction? recentTransaction;

  const AccountTab({
    super.key,
    required this.onTransactionAdded,
    this.recentTransaction,
  });

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  DateTime? _lastRefreshTime;
  static const _refreshInterval = Duration(minutes: 5);
  bool _needsRefresh = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTransactions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_needsRefresh) {
      _loadTransactions();
    }
  }

  @override
  void didUpdateWidget(AccountTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_needsRefresh && mounted) {
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;

    setState(() {
      _needsRefresh = false;
    });

    try {
      await context.read<TransactionProvider>().fetchTransactions(
            refresh: true,
            limit: 100,
          );
      if (mounted) {
        setState(() {
          _lastRefreshTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _needsRefresh = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải giao dịch: $e')),
        );
      }
    }
  }

  @override
  void activate() {
    super.activate();
    _needsRefresh = true;
    if (mounted) {
      _loadTransactions();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<TransactionProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.fetchTransactions();
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  Map<String, List<Transaction>> _groupTransactionsByDate(
      List<Transaction> transactions) {
    final groupedTransactions = <String, List<Transaction>>{};

    // First, sort all transactions by date and time, newest first
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (var transaction in sortedTransactions) {
      final date = DateFormat('dd/MM/yyyy').format(transaction.date);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Sort dates in descending order (newest first)
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy')
          .parse(b)
          .compareTo(DateFormat('dd/MM/yyyy').parse(a)));

    // Sort transactions within each date group by time, newest first
    for (var date in groupedTransactions.keys) {
      groupedTransactions[date]!.sort((a, b) => b.date.compareTo(a.date));
    }

    return Map.fromEntries(
      sortedDates.map((date) => MapEntry(date, groupedTransactions[date]!)),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        date,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await _loadTransactions();
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (transactionProvider.isLoading &&
                          transactionProvider.transactions.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (transactionProvider.transactions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        ..._groupTransactionsByDate(
                                transactionProvider.transactions)
                            .entries
                            .expand((entry) => [
                                  _buildDateHeader(entry.key),
                                  ...entry.value.map(_buildTransactionCard),
                                ])
                            .toList(),
                        if (transactionProvider.isLoading)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              // Show loading indicator at the top when refreshing
              if (transactionProvider.isLoading &&
                  transactionProvider.transactions.isNotEmpty)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final isIncome = transaction.type == 'income';

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(
              transactionId: transaction.id!,
            ),
          ),
        );

        // If transaction was deleted, refresh the list
        if (result == true && mounted) {
          await context.read<TransactionProvider>().fetchTransactions(
                refresh: true,
                limit: 100,
              );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isIncome
                      ? const Color.fromARGB(255, 215, 242, 219)
                          .withOpacity(0.8)
                      : const Color.fromARGB(255, 241, 209, 214)
                          .withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    transaction.icon ?? (isIncome ? '💰' : '🛒'),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.notes?.isNotEmpty == true
                          ? transaction.notes!
                          : transaction.category ?? 'Other',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd/MM/yyyy').format(transaction.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isIncome
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isIncome
                          ? Colors.green.shade50.withOpacity(0.5)
                          : Colors.red.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isIncome ? 'Income' : 'Expense',
                      style: TextStyle(
                        color: isIncome
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
