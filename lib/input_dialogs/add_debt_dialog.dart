import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/debt.dart';
import '../providers/balance_provider.dart';
import 'package:intl/intl.dart';

class AddDebtDialog extends StatefulWidget {
  const AddDebtDialog({super.key});

  @override
  State<AddDebtDialog> createState() => _AddDebtDialogState();
}

class _AddDebtDialogState extends State<AddDebtDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _creditorNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedDebtType = 'loan_received';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _totalAmountController.dispose();
    _creditorNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Debt'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDebtType,
                decoration: const InputDecoration(labelText: 'Debt Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'loan_received',
                    child: Text('Loan Received'),
                  ),
                  DropdownMenuItem(
                    value: 'opening_balance',
                    child: Text('Opening Balance'),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _selectedDebtType = value!;
                  });
                },
              ),
              TextFormField(
                controller: _totalAmountController,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _creditorNameController,
                decoration: const InputDecoration(labelText: 'Creditor Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter creditor name';
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final firstDayOfYear = DateTime(now.year, 1, 1);
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: firstDayOfYear,
                        lastDate: now,
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
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
              final debt = Debt(
                creditorName: _creditorNameController.text,
                totalAmount: double.parse(_totalAmountController.text),
                paidAmount: 0, // Initially no amount is paid
                date: _selectedDate,
                debtType: _selectedDebtType,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                payments: [],
              );

              await _dbHelper.insertDebt(debt);
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
