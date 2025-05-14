import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/revenue.dart';
import '../models/expense.dart';

class DashboardCharts extends StatelessWidget {
  final List<Revenue> revenues;
  final List<Expense> expenses;

  const DashboardCharts({
    super.key,
    required this.revenues,
    required this.expenses,
  });

  Widget _buildRevenueChart() {
    // Group revenues by date
    final revenueData = <DateTime, double>{};
    for (var revenue in revenues) {
      final date =
          DateTime(revenue.date.year, revenue.date.month, revenue.date.day);
      revenueData[date] = (revenueData[date] ?? 0) + revenue.amount;
    }

    final spots = revenueData.entries
        .map((e) => FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Over Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('\$${value.toInt()}');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(DateFormat('MM/dd').format(date)),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensePieChart() {
    // Group expenses by type
    final expensesByType = <String, double>{};
    for (var expense in expenses) {
      expensesByType[expense.expenseType] =
          (expensesByType[expense.expenseType] ?? 0) + expense.amount;
    }

    final sections = expensesByType.entries.map((entry) {
      final color = Colors.primaries[
          expensesByType.keys.toList().indexOf(entry.key) %
              Colors.primaries.length];
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n\$${entry.value.toStringAsFixed(0)}',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      width: 400,
      child: AspectRatio(
        aspectRatio: 1.3,
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expenses by Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 0,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 400, child: _buildExpensePieChart()),
            const SizedBox(width: 16),
            SizedBox(width: 400, child: _buildRevenueChart()),
          ],
        ),
      ),
    );
  }
}
