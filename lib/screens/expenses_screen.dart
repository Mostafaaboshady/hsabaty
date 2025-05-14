import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/expense.dart';
import '../models/payment_method.dart';
import '../input_dialogs/add_expense_dialog.dart';

/// Screen for viewing and managing all expenses.
///
/// Displays a list of expenses, their details, and allows adding new expenses.
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Expense> _expenses = [];
  List<PaymentMethod> _paymentMethods = [];
  double _totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final expenses = await _dbHelper.getExpenses();
    final paymentMethods = await _dbHelper.getPaymentMethods();
    double total = 0;
    for (var expense in expenses) {
      total += expense.amount;
    }

    if (mounted) {
      setState(() {
        _expenses = expenses;
        _paymentMethods = paymentMethods;
        _totalExpenses = total;
      });
    }
  }

  Future<void> _showAddExpenseDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddExpenseDialog(paymentMethods: _paymentMethods),
    );

    if (result == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Expenses:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '\$${_totalExpenses.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                final paymentMethod = _paymentMethods.firstWhere(
                  (method) => method.id == expense.paymentMethodId,
                  orElse: () => PaymentMethod(id: -1, name: 'Unknown'),
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text('\$${expense.amount.toStringAsFixed(2)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${expense.expenseType.toUpperCase()}'),
                        if (expense.description != null)
                          Text('Note: ${expense.description}'),
                        Text('Payment: ${paymentMethod.name}'),
                      ],
                    ),
                    trailing: Text(
                      expense.date.toString().substring(0, 10),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
