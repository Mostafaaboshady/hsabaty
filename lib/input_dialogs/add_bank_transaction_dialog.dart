import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/bank_transaction.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/balance_provider.dart';

class AddBankTransactionDialog extends StatefulWidget {
  final double bankBalance;
  final double cashBalance;

  const AddBankTransactionDialog({
    super.key,
    required this.bankBalance,
    required this.cashBalance,
  });

  @override
  State<AddBankTransactionDialog> createState() =>
      _AddBankTransactionDialogState();
}

class _AddBankTransactionDialogState extends State<AddBankTransactionDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedTransactionType = 'bank_to_cash';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Bank Transaction'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedTransactionType,
                decoration:
                    const InputDecoration(labelText: 'Transaction Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'bank_to_cash',
                    child: Text('Bank to Cash'),
                  ),
                  DropdownMenuItem(
                    value: 'cash_to_bank',
                    child: Text('Cash to Bank'),
                  ),
                  DropdownMenuItem(
                    value: 'capital_withdrawal',
                    child: Text('Capital Withdrawal'),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _selectedTransactionType = value!;
                  });
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (\$)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  // Check if sufficient balance is available
                  if (_selectedTransactionType == 'bank_to_cash' &&
                      amount > widget.bankBalance) {
                    return 'Insufficient bank balance';
                  }
                  if (_selectedTransactionType == 'cash_to_bank' &&
                      amount > widget.cashBalance) {
                    return 'Insufficient cash balance';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final now = DateTime.now();
                  final firstDayOfYear = DateTime(now.year, 1, 1);
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: firstDayOfYear,
                    lastDate: now,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final transaction = BankTransaction(
                date: _selectedDate,
                amount: double.parse(_amountController.text),
                transactionType: _selectedTransactionType,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                bankBalanceAfter: _selectedTransactionType == 'bank_to_cash' ||
                        _selectedTransactionType == 'capital_withdrawal'
                    ? widget.bankBalance - double.parse(_amountController.text)
                    : widget.bankBalance + double.parse(_amountController.text),
                cashBalanceAfter: _selectedTransactionType == 'bank_to_cash'
                    ? widget.cashBalance + double.parse(_amountController.text)
                    : _selectedTransactionType == 'cash_to_bank'
                        ? widget.cashBalance -
                            double.parse(_amountController.text)
                        : widget
                            .cashBalance, // for capital_withdrawal, cash balance doesn't change
              );

              await _dbHelper.insertBankTransaction(transaction);
              if (mounted) {
                Navigator.pop(context, true);
                context.read<BalanceProvider>().refreshAll();
              }
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
