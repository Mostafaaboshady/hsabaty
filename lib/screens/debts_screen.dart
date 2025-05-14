import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/debt.dart';
import '../input_dialogs/add_debt_dialog.dart';
import 'debt_payment_screen.dart';

/// Screen for viewing and managing all debts.
///
/// Displays a list of debts, their status, and allows adding new debts.
class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Debt> _debts = [];
  double _totalDebts = 0;
  double _remainingDebts = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final debts = await _dbHelper.getDebts();
    double totalDebts = 0;
    double remainingDebts = 0;

    for (var debt in debts) {
      totalDebts += debt.totalAmount;
      remainingDebts += debt.remainingAmount;
    }

    if (mounted) {
      setState(() {
        _debts = debts;
        _totalDebts = totalDebts;
        _remainingDebts = remainingDebts;
      });
    }
  }

  Future<void> _showAddDebtDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddDebtDialog(),
    );

    if (result == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Debts:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '\$${_totalDebts.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remaining:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '\$${_remainingDebts.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _debts.length,
              itemBuilder: (context, index) {
                final debt = _debts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(debt.creditorName),
                        Text(
                          '\$${debt.remainingAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: debt.remainingAmount > 0
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Total Amount: \$${debt.totalAmount.toStringAsFixed(2)}'),
                        Text('Type: ${debt.debtType}'),
                        if (debt.description != null)
                          Text('Note: ${debt.description}'),
                        Text('Date: ${debt.date.toString().substring(0, 10)}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DebtPaymentScreen(debt: debt),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _loadData();
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDebtDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
