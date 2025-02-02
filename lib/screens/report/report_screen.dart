import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}): super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildYearButton('2023', true),
                    _buildYearButton('2022', false),
                    _buildYearButton('2021', false),
                    // Add more years as needed
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Line chart
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 11,
                    minY: 0,
                    maxY: 25,
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey,
                          strokeWidth: 1,
                        );
                      },
                      drawVerticalLine: false,
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 10),
                          FlSpot(1, 15),
                          FlSpot(2, 10),
                          FlSpot(3, 20),
                          FlSpot(4, 15),
                          FlSpot(5, 25),
                          FlSpot(6, 20),
                          FlSpot(7, 15),
                          FlSpot(8, 20),
                          FlSpot(9, 18),
                          FlSpot(10, 23),
                          FlSpot(11, 25),
                        ],
                        isCurved: true,
                        color: Colors.tealAccent,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.tealAccent.withOpacity(0.5),
                        ),
                      ),
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 12),
                          FlSpot(1, 8),
                          FlSpot(2, 12),
                          FlSpot(3, 13),
                          FlSpot(4, 10),
                          FlSpot(5, 15),
                          FlSpot(6, 18),
                          FlSpot(7, 13),
                          FlSpot(8, 16),
                          FlSpot(9, 19),
                          FlSpot(10, 15),
                          FlSpot(11, 20),
                        ],
                        isCurved: true,
                        color: Colors.pinkAccent,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.pinkAccent.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Income, Outcome, Savings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    'Income',
                    '\$22,600.00',
                    Colors.tealAccent,
                  ),
                  _buildInfoItem(
                    'Outcome',
                    '\$23,500.00',
                    Colors.pinkAccent,
                  ),
                  _buildInfoItem(
                    'Savings',
                    '\$9,100.00',
                    Colors.yellow!, // Use a darker yellow
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Monthly budget
              const Text(
                'Monthly budget',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '\$580/\$820',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '25%',
                    style: TextStyle(fontSize: 16, color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: 0.25,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange!),
              ),
              const SizedBox(height: 10),
              const Text(
                'Daily budget was (\$26.45 - 45.33), Saved \$340',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Most of money goes to
              const Text(
                'Most of money goes to',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'House',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  const Text(
                    '-\$232.00',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearButton(String year, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Handle year selection
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected? Colors.blue: Colors.grey,
          foregroundColor: isSelected? Colors.white: Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(year),
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
}