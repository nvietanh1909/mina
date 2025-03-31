import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mina/provider/transaction_provider.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with WidgetsBindingObserver {
  String selectedYear = DateTime.now().year.toString();
  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  Map<String, List<PieChartSectionData>> _pieChartData = {
    'income': [],
    'expense': [],
    'ratio': [],
  };
  Map<String, Map<String, double>> _categoryData = {
    'income': {},
    'expense': {},
  };
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(_onFocusChange);
    _loadStats();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _loadStats();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStats();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
  }

  @override
  void didUpdateWidget(ReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);

      final startDate = DateTime(int.parse(selectedYear), 1, 1);
      final endDate = DateTime(int.parse(selectedYear), 12, 31);

      await provider.fetchTransactions(
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );

      final transactions = provider.transactions;

      double totalIncome = 0;
      double totalExpense = 0;
      Map<String, double> incomeByCategory = {};
      Map<String, double> expenseByCategory = {};

      for (var transaction in transactions) {
        if (transaction.date.year == int.parse(selectedYear)) {
          if (transaction.type == 'income') {
            totalIncome += transaction.amount;
            incomeByCategory[transaction.category ?? 'Other'] =
                (incomeByCategory[transaction.category ?? 'Other'] ?? 0) +
                    transaction.amount;
          } else {
            totalExpense += transaction.amount;
            expenseByCategory[transaction.category ?? 'Other'] =
                (expenseByCategory[transaction.category ?? 'Other'] ?? 0) +
                    transaction.amount;
          }
        }
      }

      final stats = {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': totalIncome - totalExpense,
      };

      _pieChartData = _calculatePieChartData(
        incomeByCategory,
        expenseByCategory,
        totalIncome,
        totalExpense,
      );

      setState(() {
        _stats = stats;
        _categoryData = {
          'income': incomeByCategory,
          'expense': expenseByCategory,
        };
      });
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, List<PieChartSectionData>> _calculatePieChartData(
    Map<String, double> incomeByCategory,
    Map<String, double> expenseByCategory,
    double totalIncome,
    double totalExpense,
  ) {
    final List<Color> colors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFFA726), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFFF7043), // Deep Orange
      const Color(0xFF607D8B), // Blue Grey
    ];

    final incomeSections = <PieChartSectionData>[];
    int colorIndex = 0;

    // Sort categories by amount for better visualization
    final sortedIncomeCategories = incomeByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedIncomeCategories) {
      if (totalIncome > 0) {
        final percentage = (entry.value / totalIncome) * 100;
        incomeSections.add(
          PieChartSectionData(
            value: entry.value,
            title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                ),
              ],
            ),
            color: colors[colorIndex % colors.length],
            showTitle: percentage >= 5,
          ),
        );
        colorIndex++;
      }
    }

    final expenseSections = <PieChartSectionData>[];
    colorIndex = 0;

    // Sort categories by amount for better visualization
    final sortedExpenseCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedExpenseCategories) {
      if (totalExpense > 0) {
        final percentage = (entry.value / totalExpense) * 100;
        expenseSections.add(
          PieChartSectionData(
            value: entry.value,
            title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                ),
              ],
            ),
            color: colors[colorIndex % colors.length],
            showTitle: percentage >= 5,
          ),
        );
        colorIndex++;
      }
    }

    final ratioSections = <PieChartSectionData>[];
    final total = totalIncome + totalExpense;

    if (total > 0) {
      final incomePercentage = (totalIncome / total) * 100;
      final expensePercentage = (totalExpense / total) * 100;

      ratioSections.addAll([
        PieChartSectionData(
          value: totalIncome,
          title: incomePercentage >= 5
              ? '${incomePercentage.toStringAsFixed(1)}%'
              : '',
          radius: 50,
          color: const Color(0xFF4CAF50),
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 2,
              ),
            ],
          ),
          showTitle: incomePercentage >= 5,
        ),
        PieChartSectionData(
          value: totalExpense,
          title: expensePercentage >= 5
              ? '${expensePercentage.toStringAsFixed(1)}%'
              : '',
          radius: 50,
          color: const Color(0xFFE53935),
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 2,
              ),
            ],
          ),
          showTitle: expensePercentage >= 5,
        ),
      ]);
    }

    return {
      'income': incomeSections,
      'expense': expenseSections,
      'ratio': ratioSections,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          /** actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.black),
                  onPressed: () {},
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Transform.rotate(
                    angle: 0.785398,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: Colors.red,
                      child: const Text('Active',
                          style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ),
              ],
            ),
          ], */
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Year selector
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _generateYearButtons(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _stats != null
                          ? _buildDataContent()
                          : _buildNoDataMessage(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: const Text(
        'No data',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDataContent() {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 48) /
        3; // 48 = padding left 16 + padding right 16 + spacing between items 16

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Income, Expense, Balance Cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                _buildInfoItem(
                  'Income',
                  currencyFormat.format(_stats!['totalIncome'] ?? 0),
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildInfoItem(
                  'Expense',
                  currencyFormat.format(_stats!['totalExpense'] ?? 0),
                  Colors.red,
                ),
                const SizedBox(width: 12),
                _buildInfoItem(
                  'Balance',
                  currencyFormat.format(_stats!['balance'] ?? 0),
                  _stats!['balance'] >= 0 ? Colors.blue : Colors.blue,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Charts Section
        Container(
          height: MediaQuery.of(context).size.width * 0.8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: PageView(
                    children: [
                      _buildChartSection(
                        'Ratio of income and expense',
                        'ratio',
                        _stats!['balance'] >= 0 ? Colors.black : Colors.black,
                        _stats!['balance'] ?? 0,
                      ),
                      _buildChartSection(
                        'Income by category',
                        'income',
                        Colors.black,
                        _stats!['totalIncome'] ?? 0,
                      ),
                      _buildChartSection(
                        'Expense by category',
                        'expense',
                        Colors.black,
                        _stats!['totalExpense'] ?? 0,
                      ),
                    ],
                  ),
                ),
              ),
              // Indicators
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Category Details
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Details by category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildCategoryTable(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTable() {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final totalIncome = _stats!['totalIncome'] as double;
    final totalExpense = _stats!['totalExpense'] as double;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Thu nhập
          _buildCategoryTableHeader('Income', Colors.green),
          ..._buildCategoryRows(
              _categoryData['income']!, totalIncome, Colors.green),

          // Chi tiêu
          _buildCategoryTableHeader('Expense', Colors.red),
          ..._buildCategoryRows(
              _categoryData['expense']!, totalExpense, Colors.red),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryRows(
      Map<String, double> categories, double total, Color color) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCategories.map((entry) {
      final percentage =
          total > 0 ? ((entry.value / total) * 100).toStringAsFixed(1) : '0.0';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                currencyFormat.format(entry.value),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              child: Text(
                '$percentage%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCategoryTableHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Amount',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              'Ratio',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
      String title, String type, Color valueColor, double value) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (_pieChartData[type]!.isNotEmpty)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: _pieChartData[type]!,
                    sectionsSpace: 2,
                    centerSpaceRadius: 45,
                    borderData: FlBorderData(show: false),
                  ),
                ),
                Text(
                  currencyFormat.format(value),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          const Expanded(
            child: Center(
              child: Text(
                'Không có dữ liệu',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem(String title, String amount, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateYearButtons() {
    final currentYear = DateTime.now().year;
    final years =
        List.generate(5, (index) => (currentYear - 2 + index).toString());

    return years.map((year) {
      final isSelected = year == selectedYear;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              selectedYear = year;
            });
            _loadStats();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(year),
        ),
      );
    }).toList();
  }
}
