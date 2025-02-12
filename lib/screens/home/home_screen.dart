import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/testing.dart';
import 'package:mina/model/transaction_model.dart';
import 'package:mina/screens/account/account_screen.dart';
import 'package:mina/screens/camera/camera_screen.dart';
import 'package:mina/screens/home/transaction/transaction_screen.dart';
import 'package:mina/screens/profile/profile_screen.dart';
import 'package:mina/screens/report/report_screen.dart';
import 'package:mina/theme/color.dart';
import 'package:provider/provider.dart';
import 'package:mina/provider/wallet_provider.dart';
import 'package:mina/provider/transaction_provider.dart';
import 'package:intl/intl.dart';
import 'package:mina/screens/chatbot/chatbot_screen.dart';

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
    _loadInitialData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);
      await _loadData();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadData() async {
    try {
      print('HomeScreen: Loading data...');
      // Đảm bảo providers được khởi tạo
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);

      final defaultWallet = walletProvider.wallets.firstWhere(
          (wallet) => wallet.isDefault,
          orElse: () => walletProvider.wallets.first);
      final monthlyLimit = defaultWallet.monthlyLimit;

      await Future.wait([
        walletProvider.loadWallets(),
        transactionProvider.fetchTransactions()
      ]);

      // Log kết quả
      print('Wallets loaded: ${walletProvider.wallets.length}');
      print('Transactions loaded: ${transactionProvider.transactions.length}');
      print('Monthly limit: ${monthlyLimit}');
    } catch (e) {
      print('Error loading data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
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
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Your total balance",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "\$ ${totalBalance.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceItem(
                  "Income", income, Colors.green, Icons.arrow_upward),
              _buildBalanceItem(
                  "Spend", expense, Colors.red, Icons.arrow_downward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(
      String title, double amount, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        Text(
          "\$ ${amount.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLimitCard(double expense) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final defaultWallet = walletProvider.wallets.firstWhere(
        (wallet) => wallet.isDefault,
        orElse: () => walletProvider.wallets.first);

    // Sử dụng monthlyLimit từ ví
    final monthlyLimit = defaultWallet.monthlyLimit;

    final limitProgress = (expense / monthlyLimit).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text(
            "Limit for this month",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "\$ ${expense.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: limitProgress,
            backgroundColor: Colors.grey,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            "${expense.toStringAsFixed(2)} / ${monthlyLimit.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white),
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
                        icon: Icons.payments,
                        title: transaction.category ?? 'Income',
                        date:
                            DateFormat('dd MMM yyyy').format(transaction.date),
                        amount: "+ ${transaction.amount.toStringAsFixed(2)} \$",
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
                        icon: Icons.shopping_cart,
                        title: transaction.category ?? 'Expense',
                        date:
                            DateFormat('dd MMM yyyy').format(transaction.date),
                        amount: "- ${transaction.amount.toStringAsFixed(2)} \$",
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: amount.startsWith("+") ? Colors.green : Colors.red,
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
    CameraScreen(),
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
      _buildCameraItem(),
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

  BottomNavigationBarItem _buildCameraItem() {
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
            child: SvgPicture.asset(
              'assets/icons/li_camera.svg',
              width: 24,
              height: 24,
              color: Colors.white,
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
          Icons.message_outlined,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
