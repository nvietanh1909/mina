import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mina/provider/transaction_provider.dart';
import 'package:intl/intl.dart';
import 'package:mina/utils/number_formatter.dart';

// Colors for income chart - Modern financial app color scheme
const List<Color> incomeColors = [
  Color(0xFF00C853), // Material Green
  Color(0xFF69F0AE), // Light Green
  Color(0xFF00E676), // Bright Green
  Color(0xFF76FF03), // Lime
  Color(0xFF64DD17), // Light Lime
  Color(0xFF7CB342), // Olive Green
];

// Colors for expense chart - Modern financial app color scheme
const List<Color> expenseColors = [
  Color(0xFFFF5252), // Material Red
  Color(0xFFFF1744), // Bright Red
  Color(0xFFFF4081), // Pink
  Color(0xFFFF80AB), // Light Pink
  Color(0xFFF50057), // Deep Pink
  Color(0xFFFF4081), // Rose
];

// Gradient colors for income - Blue theme
final List<Color> incomeGradientColors = [
  const Color(0xFF4158D0),
  const Color(0xFF3B4FD8),
  const Color(0xFF2C69D1),
];

// Gradient colors for expense - Purple theme
final List<Color> expenseGradientColors = [
  const Color(0xFF8E2DE2),
  const Color(0xFF7A1FA2),
  const Color(0xFF6B1B9A),
];

// Gradient colors for balance - Blue-Purple gradient
final List<Color> balanceGradientColors = [
  const Color(0xFF4158D0),
  const Color(0xFF6B1B9A),
];

// Gradient colors for savings - Light Blue to Purple
final List<Color> savingsGradientColors = [
  const Color(0xFF00C6FB),
  const Color(0xFF005BEA),
];

// Chart colors
final List<Color> incomeChartColors = [
  const Color(0xFF4158D0),
  const Color(0xFF2C69D1),
  const Color(0xFF1E88E5),
  const Color(0xFF039BE5),
  const Color(0xFF00ACC1),
];

final List<Color> expenseChartColors = [
  const Color(0xFF8E2DE2),
  const Color(0xFF7A1FA2),
  const Color(0xFF6A1B9A),
  const Color(0xFF9C27B0),
  const Color(0xFFAB47BC),
];

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
  String _selectedTimeRange = 'year'; // 'month', 'year', 'all'

  // New modern gradient colors
  final List<List<Color>> cardGradients = [
    [
      const Color(0xFF4CAF50),
      const Color(0xFF2E7D32)
    ], // Income - Green gradient
    [
      const Color(0xFFF44336),
      const Color(0xFFC62828)
    ], // Expense - Red gradient
    [
      const Color(0xFF2196F3),
      const Color(0xFF1565C0)
    ], // Balance - Blue gradient
    [
      const Color(0xFF9C27B0),
      const Color(0xFF6A1B9A)
    ], // Savings - Purple gradient
  ];

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
      DateTime startDate;
      DateTime endDate = DateTime.now();

      switch (_selectedTimeRange) {
        case 'month':
          startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
          break;
        case 'year':
          startDate = DateTime(int.parse(selectedYear), 1, 1);
          break;
        default:
          startDate = DateTime(2000); // All time
      }

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
        if (transaction.date.isAfter(startDate) &&
            transaction.date.isBefore(endDate)) {
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
        'savingsRate': totalIncome > 0
            ? ((totalIncome - totalExpense) / totalIncome) * 100
            : 0,
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
    final incomeSections = <PieChartSectionData>[];
    int colorIndex = 0;

    final sortedIncomeCategories = incomeByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedIncomeCategories) {
      if (totalIncome > 0) {
        final percentage = (entry.value / totalIncome) * 100;
        if (percentage >= 1) {
          incomeSections.add(
            PieChartSectionData(
              value: entry.value,
              title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
              radius: 45,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                  ),
                ],
              ),
              color: incomeColors[colorIndex % incomeColors.length],
              showTitle: percentage >= 5,
            ),
          );
          colorIndex++;
        }
      }
    }

    final expenseSections = <PieChartSectionData>[];
    colorIndex = 0;

    final sortedExpenseCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedExpenseCategories) {
      if (totalExpense > 0) {
        final percentage = (entry.value / totalExpense) * 100;
        if (percentage >= 1) {
          expenseSections.add(
            PieChartSectionData(
              value: entry.value,
              title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
              radius: 45,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                  ),
                ],
              ),
              color: expenseColors[colorIndex % expenseColors.length],
              showTitle: percentage >= 5,
            ),
          );
          colorIndex++;
        }
      }
    }

    return {
      'income': incomeSections,
      'expense': expenseSections,
      'ratio': [],
    };
  }

  Widget _buildStatCard(
      String title, double amount, List<Color> gradientColors, IconData icon,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormatter.formatCurrency(amount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Color(0xFF6B8CFF);
                    }
                    return Colors.transparent;
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return Colors.grey;
                  },
                ),
                textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                  (Set<MaterialState> states) {
                    return const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    );
                  },
                ),
              ),
              segments: const [
                ButtonSegment(
                  value: 'month',
                  label: Text('Month'),
                  icon: Icon(Icons.calendar_month, size: 16),
                ),
                ButtonSegment(
                  value: 'year',
                  label: Text('Year'),
                  icon: Icon(Icons.calendar_today, size: 16),
                ),
                ButtonSegment(
                  value: 'all',
                  label: Text('All'),
                  icon: Icon(Icons.all_inclusive, size: 16),
                ),
              ],
              selected: {_selectedTimeRange},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedTimeRange = newSelection.first;
                  _loadStats();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String type) {
    final gradientColors =
        type == 'income' ? incomeGradientColors : expenseGradientColors;
    final categories = _categoryData[type] ?? {};

    final total = type == 'income'
        ? (_stats?['totalIncome'] as num?)?.toDouble() ?? 0.0
        : (_stats?['totalExpense'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: gradientColors[0].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                  color: gradientColors[0],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  type == 'income' ? 'Income Categories' : 'Expense Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: gradientColors[0],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (categories.isNotEmpty)
            ...categories.entries.map((entry) {
              final percentage = total > 0 ? (entry.value / total) : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: gradientColors[0].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(percentage * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: gradientColors[0],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          NumberFormatter.formatCurrency(entry.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: gradientColors[0].withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          gradientColors[0],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No ${type} data available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Financial Report',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2D3142),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.refresh, color: Color(0xFF6B8CFF), size: 20),
              onPressed: _loadStats,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2196F3), // Updated color
              ),
            )
          : stats == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No data available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildTimeRangeSelector(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Income',
                                    (stats['totalIncome'] as num?)
                                            ?.toDouble() ??
                                        0.0,
                                    incomeGradientColors,
                                    Icons.arrow_upward,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    'Expense',
                                    (stats['totalExpense'] as num?)
                                            ?.toDouble() ??
                                        0.0,
                                    expenseGradientColors,
                                    Icons.arrow_downward,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Balance',
                                    (stats['balance'] as num?)?.toDouble() ??
                                        0.0,
                                    balanceGradientColors,
                                    Icons.account_balance_wallet,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    'Savings Rate',
                                    (stats['savingsRate'] as num?)
                                            ?.toDouble() ??
                                        0.0,
                                    savingsGradientColors,
                                    Icons.savings,
                                    subtitle: 'of income',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (_pieChartData['income']!.isNotEmpty ||
                                _pieChartData['expense']!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: cardGradients[2],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.pie_chart,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Spending Distribution',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 200,
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const Text(
                                                  'Income',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: Color(0xFF4CAF50),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: Stack(
                                                    children: [
                                                      PieChart(
                                                        PieChartData(
                                                          sections:
                                                              _pieChartData[
                                                                  'income']!,
                                                          sectionsSpace: 2,
                                                          centerSpaceRadius: 25,
                                                          borderData:
                                                              FlBorderData(
                                                                  show: false),
                                                          startDegreeOffset:
                                                              270,
                                                        ),
                                                      ),
                                                      if (_pieChartData[
                                                              'income']!
                                                          .isEmpty)
                                                        Center(
                                                          child: Text(
                                                            'No data',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[400],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 32),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const Text(
                                                  'Expense',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: Color(0xFFF44336),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: Stack(
                                                    children: [
                                                      PieChart(
                                                        PieChartData(
                                                          sections:
                                                              _pieChartData[
                                                                  'expense']!,
                                                          sectionsSpace: 2,
                                                          centerSpaceRadius: 25,
                                                          borderData:
                                                              FlBorderData(
                                                                  show: false),
                                                          startDegreeOffset:
                                                              270,
                                                        ),
                                                      ),
                                                      if (_pieChartData[
                                                              'expense']!
                                                          .isEmpty)
                                                        Center(
                                                          child: Text(
                                                            'No data',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[400],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                height: 220,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.pie_chart_outline,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No data to display chart',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            _buildCategoryList('income'),
                            const SizedBox(height: 24),
                            _buildCategoryList('expense'),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
