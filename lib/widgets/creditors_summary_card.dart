import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';

class CreditorsSummaryCard extends StatelessWidget {
  final List<Debt> debts;

  const CreditorsSummaryCard({
    super.key,
    required this.debts,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Creditors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/debts'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (debts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No debts recorded'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: debts.length > 5 ? 5 : debts.length,
                itemBuilder: (context, index) {
                  final debt = debts[index];
                  return ListTile(
                    title: Text(debt.creditorName),
                    subtitle: Text(
                      'Due: ${NumberFormat.currency(symbol: '\$').format(debt.totalAmount - debt.paidAmount)}',
                    ),
                    trailing: Text(
                      '${(debt.paidAmount / debt.totalAmount * 100).toStringAsFixed(1)}% paid',
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
