import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mina/provider/transaction_provider.dart';
import 'package:mina/model/transaction_model.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedYear = DateTime.now().year.toString();
  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  List<FlSpot> _incomeSpots = [];
  List<FlSpot> _expenseSpots = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);

      // Lấy thời gian bắt đầu và kết thúc của năm được chọn
      final startDate = DateTime(int.parse(selectedYear), 1, 1);
      final endDate = DateTime(int.parse(selectedYear), 12, 31);

      print('Loading stats for year: $selectedYear');
      print('Start date: $startDate');
      print('End date: $endDate');

      // Lấy danh sách giao dịch trước
      await provider.fetchTransactions(
        startDate: startDate,
        endDate: endDate,
        limit: 1000, // Tăng limit để lấy tất cả giao dịch
      );

      final transactions = provider.transactions;
      print('Transactions loaded: ${transactions.length}');

      // In chi tiết từng giao dịch để debug
      for (var transaction in transactions) {
        print(
            'Transaction: ${transaction.type} - ${transaction.amount} - ${transaction.date} - ${transaction.category}');
      }

      // Tính toán thống kê từ transactions
      double totalIncome = 0;
      double totalExpense = 0;

      for (var transaction in transactions) {
        if (transaction.date.year == int.parse(selectedYear)) {
          if (transaction.type == 'income') {
            totalIncome += transaction.amount;
          } else {
            totalExpense += transaction.amount;
          }
        }
      }

      final stats = {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': totalIncome - totalExpense,
      };

      print('Calculated stats: $stats');

      // Tạo dữ liệu cho biểu đồ
      final monthlyData = _calculateMonthlyData(transactions);

      setState(() {
        _stats = stats;
        _incomeSpots = monthlyData['income']!;
        _expenseSpots = monthlyData['expense']!;
      });
    } catch (e) {
      print('Error loading stats: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, List<FlSpot>> _calculateMonthlyData(
      List<Transaction> transactions) {
    final selectedYearInt = int.parse(selectedYear);

    // Khởi tạo mảng để lưu tổng thu nhập và chi tiêu theo tháng
    final monthlyIncome = List<double>.filled(12, 0);
    final monthlyExpense = List<double>.filled(12, 0);

    // Tính tổng theo tháng
    for (var transaction in transactions) {
      // Chỉ tính cho năm được chọn
      if (transaction.date.year == selectedYearInt) {
        final month = transaction.date.month - 1; // 0-based index
        if (transaction.type == 'income') {
          monthlyIncome[month] += transaction.amount;
        } else {
          monthlyExpense[month] += transaction.amount;
        }
      }
    }

    print('Monthly income data: $monthlyIncome');
    print('Monthly expense data: $monthlyExpense');

    // Chuyển đổi thành FlSpot
    return {
      'income':
          List.generate(12, (i) => FlSpot(i.toDouble(), monthlyIncome[i])),
      'expense':
          List.generate(12, (i) => FlSpot(i.toDouble(), monthlyExpense[i])),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Report'),
        actions: [
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                    const SizedBox(height: 20),

                    // Check if data exists
                    _stats != null
                        ? _buildDataContent()
                        : _buildNoDataMessage(),
                  ],
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
        'Chưa có số liệu',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line chart
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 11,
              minY: 0,
              maxY: _calculateMaxY(),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _incomeSpots,
                  isCurved: true,
                  color: const Color(0xFF48DC95),
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF48DC95).withOpacity(0.3),
                  ),
                ),
                LineChartBarData(
                  spots: _expenseSpots,
                  isCurved: true,
                  color: Colors.redAccent,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.redAccent.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Income, Outcome, Balance
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoItem(
              'Income',
              currencyFormat.format(_stats!['totalIncome'] ?? 0),
              const Color(0xFF48DC95),
            ),
            _buildInfoItem(
              'Outcome',
              currencyFormat.format(_stats!['totalExpense'] ?? 0),
              Colors.redAccent,
            ),
            _buildInfoItem(
              'Balance',
              currencyFormat.format(_stats!['balance'] ?? 0),
              Colors.blueAccent,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Monthly Analysis
        const Text(
          'Monthly Analysis',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildMonthlyAnalysisTable(),
        const SizedBox(height: 20),

        // Top Categories
        const Text(
          'Top Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildTopCategories(),
      ],
    );
  }

  double _calculateMaxY() {
    double maxIncome = 0;
    double maxExpense = 0;

    for (var spot in _incomeSpots) {
      if (spot.y > maxIncome) maxIncome = spot.y;
    }

    for (var spot in _expenseSpots) {
      if (spot.y > maxExpense) maxExpense = spot.y;
    }

    return (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;
  }

  Widget _buildTopCategories() {
    final categories = _calculateTopCategories();
    return Column(
      children: categories.map((category) {
        final currencyFormat =
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category['type'] == 'income'
                      ? const Color(0xFF48DC95).withOpacity(0.2)
                      : Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.category,
                  color: category['type'] == 'income'
                      ? const Color(0xFF48DC95)
                      : Colors.redAccent,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                category['name'],
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Text(
                currencyFormat.format(category['amount']),
                style: TextStyle(
                  fontSize: 16,
                  color: category['type'] == 'income'
                      ? const Color(0xFF48DC95)
                      : Colors.redAccent,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _calculateTopCategories() {
    final transactions =
        Provider.of<TransactionProvider>(context, listen: false).transactions;

    // Tạo map để lưu tổng theo category
    final categoryTotals = <String, Map<String, dynamic>>{};

    for (var transaction in transactions) {
      final key = '${transaction.type}_${transaction.category}';
      if (!categoryTotals.containsKey(key)) {
        categoryTotals[key] = {
          'name': transaction.category,
          'type': transaction.type,
          'amount': 0.0,
        };
      }
      categoryTotals[key]!['amount'] =
          categoryTotals[key]!['amount'] + transaction.amount;
    }

    // Chuyển thành list và sắp xếp
    final sortedCategories = categoryTotals.values.toList()
      ..sort(
          (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    // Trả về top 5 categories
    return sortedCategories.take(5).toList();
  }

  Widget _buildYearButton(String year) {
    bool isSelected = selectedYear == year;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedYear = year;
          });
          _loadStats();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? Colors.blue : Colors.blue.withOpacity(0.2),
          foregroundColor: isSelected ? Colors.white : Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(year,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }

  List<Widget> _generateYearButtons() {
    int currentYear = DateTime.now().year;
    int numberOfYears = 5; // Showing 5 years

    List<String> years = [];
    for (int i = 0; i < numberOfYears; i++) {
      years.add((currentYear + i).toString());
    }

    return years.map((year) => _buildYearButton(year)).toList();
  }

  Widget _buildMonthlyAnalysisTable() {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final monthlyData = _calculateMonthlyStats();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('Month')),
            DataColumn(label: Text('Income')),
            DataColumn(label: Text('Expense')),
            DataColumn(label: Text('Balance')),
            DataColumn(label: Text('Transactions')),
          ],
          rows: monthlyData.map((data) {
            final balance = data['income'] - data['expense'];
            final isPositiveBalance = balance >= 0;

            return DataRow(
              cells: [
                DataCell(Text(data['month'])),
                DataCell(Text(
                  currencyFormat.format(data['income']),
                  style: const TextStyle(color: Color(0xFF48DC95)),
                )),
                DataCell(Text(
                  currencyFormat.format(data['expense']),
                  style: const TextStyle(color: Colors.redAccent),
                )),
                DataCell(Text(
                  currencyFormat.format(balance),
                  style: TextStyle(
                    color: isPositiveBalance ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                DataCell(Text(data['count'].toString())),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateMonthlyStats() {
    final transactions =
        Provider.of<TransactionProvider>(context, listen: false).transactions;

    final selectedYearInt = int.parse(selectedYear);

    // Khởi tạo dữ liệu cho 12 tháng
    final monthlyStats = List.generate(
        12,
        (index) => {
              'month': DateFormat('MMM')
                  .format(DateTime(selectedYearInt, index + 1)),
              'income': 0.0,
              'expense': 0.0,
              'count': 0,
            });

    // Tính toán thống kê theo tháng
    for (var transaction in transactions) {
      // Chỉ tính các giao dịch trong năm được chọn
      if (transaction.date.year == selectedYearInt) {
        final monthIndex = transaction.date.month - 1;
        final stats = monthlyStats[monthIndex];

        if (transaction.type == 'income') {
          stats['income'] = (stats['income'] as double) + transaction.amount;
        } else {
          stats['expense'] = (stats['expense'] as double) + transaction.amount;
        }
        stats['count'] = (stats['count'] as int) + 1;
      }
    }

    return monthlyStats;
  }
}
