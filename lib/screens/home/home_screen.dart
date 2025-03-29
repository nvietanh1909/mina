import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/testing.dart';
import 'package:mina/model/transaction_model.dart';
import 'package:mina/screens/account/account_screen.dart';
import 'package:mina/screens/camera/scan_bill_screen.dart';
import 'package:mina/screens/home/transaction/transaction_screen.dart';
import 'package:mina/screens/profile/profile_screen.dart';
import 'package:mina/screens/report/report_screen.dart';
import 'package:mina/theme/color.dart';
import 'package:provider/provider.dart';
import 'package:mina/provider/wallet_provider.dart';
import 'package:mina/provider/transaction_provider.dart';
import 'package:intl/intl.dart';
import 'package:mina/screens/chatbot/chatbot_screen.dart';
import 'package:mina/utils/number_formatter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInitialData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      // Load both wallets and transactions
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);

      await Future.wait([
        walletProvider.loadWallets(),
        transactionProvider.fetchTransactions(),
      ]);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer2<WalletProvider, TransactionProvider>(
                builder: (context, walletProvider, transactionProvider, child) {
                  // Tính toán các số liệu thống kê
                  final totalBalance = walletProvider.wallets.fold<double>(
                    0,
                    (sum, wallet) => sum + wallet.balance,
                  );

                  final incomeTransactions = transactionProvider.transactions
                      .where((t) => t.type == 'income')
                      .toList();

                  final expenseTransactions = transactionProvider.transactions
                      .where((t) => t.type == 'expense')
                      .toList();

                  final income = incomeTransactions.fold<double>(
                    0,
                    (sum, t) => sum + t.amount,
                  );

                  final expense = expenseTransactions.fold<double>(
                    0,
                    (sum, t) => sum + t.amount,
                  );

                  print('Total balance: $totalBalance');
                  print('Total income: $income');
                  print('Total expense: $expense');

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBalanceCard(totalBalance, income, expense),
                          const SizedBox(height: 20),
                          _buildLimitCard(expense),
                          const SizedBox(height: 20),
                          _buildTransactionsList(
                            incomeTransactions,
                            expenseTransactions,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildBalanceCard(double totalBalance, double income, double expense) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 32, 32, 56),
            const Color.fromARGB(255, 55, 50, 111),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141727).withOpacity(0.2),
            spreadRadius: 4,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Your total balance",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormatter.formatCurrency(totalBalance),
            style: const TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalanceItem(
                  "Income", income, const Color(0xFF48DC95), Icons.trending_up),
              Container(height: 40, width: 1, color: Colors.white12),
              _buildBalanceItem("Spend", expense, const Color(0xFFEF436B),
                  Icons.trending_down),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(
      String title, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          NumberFormatter.formatCurrency(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLimitCard(double expense) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final defaultWallet = walletProvider.wallets.firstWhere(
        (wallet) => wallet.isDefault,
        orElse: () => walletProvider.wallets.first);

    final monthlyLimit = defaultWallet.monthlyLimit;
    final limitProgress = (expense / monthlyLimit).clamp(0.0, 1.0);
    final isNearLimit = limitProgress > 0.8;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isNearLimit
              ? [const Color(0xFF66023c), const Color(0xFFcd1c18)]
              : [
                  const Color.fromARGB(255, 72, 133, 232),
                  const Color.fromARGB(255, 15, 64, 127)
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isNearLimit
                    ? const Color(0xFF00c6ff)
                    : const Color(0xFF0072ff))
                .withOpacity(0.2),
            spreadRadius: 4,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Monthly Limit",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormatter.formatCurrency(expense),
            style: const TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: limitProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isNearLimit ? Colors.red.shade100 : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(limitProgress * 100).toInt()}% used",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Limit: ${NumberFormatter.formatCurrency(monthlyLimit)}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    List<Transaction> incomeTransactions,
    List<Transaction> expenseTransactions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Income",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        incomeTransactions.isEmpty
            ? const Text("You don't have any income yet",
                style: TextStyle(color: Colors.grey))
            : Column(
                children: incomeTransactions
                    .map(
                      (transaction) => _buildTransactionItem(
                        transaction: transaction,
                      ),
                    )
                    .toList(),
              ),
        const SizedBox(height: 16),
        const Text(
          "Expense",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        expenseTransactions.isEmpty
            ? const Text("You don't have any expense yet",
                style: TextStyle(color: Colors.grey))
            : Column(
                children: expenseTransactions
                    .map(
                      (transaction) => _buildTransactionItem(
                        transaction: transaction,
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required Transaction transaction,
  }) {
    final bool isIncome = transaction.type == 'income';
    final String amount =
        "${isIncome ? "+" : "-"} ${NumberFormatter.formatCurrency(transaction.amount)}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: transaction.icon != null
                  ? Text(
                      transaction.icon!,
                      style: const TextStyle(fontSize: 20),
                    )
                  : Icon(
                      isIncome ? Icons.payment : Icons.shopping_cart,
                      color: isIncome ? Colors.green : Colors.red,
                      size: 20,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.notes?.isNotEmpty == true
                      ? transaction.notes!
                      : transaction.category ??
                          (isIncome ? 'Income' : 'Expense'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(transaction.date),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AccountScreen(),
    TransactionScreen(),
    ReportScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          height: 70,
          backgroundColor: AppColors.white,
          activeColor: AppColors.bottomNavIconHover,
          inactiveColor: AppColors.bottomNavIconColor,
          border: const Border(top: BorderSide.none),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: _buildTabBarItems(),
        ),
        tabBuilder: (BuildContext context, int index) {
          return Stack(
            children: [
              _screens[index],
              if (_currentIndex != 2) // Hide FAB on camera screen
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: _buildAddTransactionButton(context),
                ),
            ],
          );
        },
      ),
    );
  }

  List<BottomNavigationBarItem> _buildTabBarItems() {
    return [
      _buildTabBarItem('Home', 'assets/icons/li_home.svg', 0),
      _buildTabBarItem('Account', 'assets/icons/li_account.svg', 1),
      _buildTransactionItem(),
      _buildTabBarItem('Report', 'assets/icons/li_report.svg', 3),
      _buildTabBarItem('Profile', 'assets/icons/li_profile.svg', 4),
    ];
  }

  BottomNavigationBarItem _buildTabBarItem(
    String label,
    String iconPath,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            color: _currentIndex == index
                ? AppColors.bottomNavIconHover
                : AppColors.bottomNavIconColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _currentIndex == index
                  ? AppColors.bottomNavIconHover
                  : AppColors.bottomNavIconColor,
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildTransactionItem() {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTransactionButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatbotScreen(),
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: const Icon(
          Icons.message,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
