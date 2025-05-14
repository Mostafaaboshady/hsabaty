import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/bank_transaction.dart';
import '../input_dialogs/add_bank_transaction_dialog.dart';

/// Screen for viewing and managing bank and cash transactions.
///
/// Displays balances and a list of transactions, and allows adding new transactions.
class BankAndCashScreen extends StatefulWidget {
  const BankAndCashScreen({super.key});

  @override
  State<BankAndCashScreen> createState() => _BankAndCashScreenState();
}

class _BankAndCashScreenState extends State<BankAndCashScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<BankTransaction> _transactions = [];
  double _bankBalance = 0;
  double _cashBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await _dbHelper.getBankTransactions();
    final balance = await _dbHelper.getTradingBalance();

    if (mounted) {
      setState(() {
        _transactions = transactions;
        _bankBalance = balance['bank_balance']!;
        _cashBalance = balance['cash_balance']!;
      });
    }
  }

  Future<void> _showAddTransactionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddBankTransactionDialog(
        bankBalance: _bankBalance,
        cashBalance: _cashBalance,
      ),
    );

    if (result == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank & Cash'),
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
                        'Bank Balance:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '\$${_bankBalance.toStringAsFixed(2)}',
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
                        'Cash Balance:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '\$${_cashBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(transaction.transactionType),
                        Text('\$${transaction.amount.toStringAsFixed(2)}'),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (transaction.description != null)
                          Text('Note: ${transaction.description}'),
                        Text(
                            'Date: ${transaction.date.toString().substring(0, 10)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
