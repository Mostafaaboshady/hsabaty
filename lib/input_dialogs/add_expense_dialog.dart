import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/expense.dart';
import '../models/payment_method.dart';
import '../providers/balance_provider.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;

  const AddExpenseDialog({
    super.key,
    required this.paymentMethods,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedExpenseType = 'other';
  DateTime _selectedDate = DateTime.now();
  int? _selectedPaymentMethodId;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethodId = widget.paymentMethods.isNotEmpty
        ? widget.paymentMethods.first.id
        : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Expense'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (\$)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedExpenseType,
                decoration: const InputDecoration(labelText: 'Expense Type'),
                items: ['rent', 'salary', 'utilities', 'other']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExpenseType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedPaymentMethodId,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: widget.paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method.id,
                    child: Text(method.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethodId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a payment method';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
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
              final expense = Expense(
                date: _selectedDate,
                amount: double.parse(_amountController.text),
                paymentMethodId: _selectedPaymentMethodId!,
                expenseType: _selectedExpenseType,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
              );

              await _dbHelper.insertExpense(expense);
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
