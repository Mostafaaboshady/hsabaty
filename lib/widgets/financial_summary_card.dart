import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialSummaryCard extends StatelessWidget {
  final Map<String, double> tradingBalance;
  final double totalDebts;

  const FinancialSummaryCard({
    super.key,
    required this.tradingBalance,
    required this.totalDebts,
  });

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$').format(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: amount < 0 ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Income', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildSummaryRow('Revenue', tradingBalance['total_revenue']!),
            _buildSummaryRow('Expenses', tradingBalance['total_expenses']!),
            const Divider(),
            _buildSummaryRow('Operating Profit', tradingBalance['net_profit']!),
            const SizedBox(height: 16),
            const Text('Assets', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildSummaryRow(
                'Supplies Inventory', tradingBalance['total_supplies']!),
            _buildSummaryRow('Cash Balance', tradingBalance['cash_balance']!),
            _buildSummaryRow('Bank Balance', tradingBalance['bank_balance']!),
            const SizedBox(height: 16),
            const Text('Liabilities',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildSummaryRow('Total Credits', totalDebts, isTotal: true),
          ],
        ),
      ),
    );
  }
}
