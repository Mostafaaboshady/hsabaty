import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/supply.dart';
import '../models/payment_method.dart';
import '../providers/balance_provider.dart';
import 'package:intl/intl.dart';

class AddSupplyDialog extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;

  const AddSupplyDialog({
    super.key,
    required this.paymentMethods,
  });

  @override
  State<AddSupplyDialog> createState() => _AddSupplyDialogState();
}

class _AddSupplyDialogState extends State<AddSupplyDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedPaymentType = 'cash';
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
    _nameController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Supply'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Supply Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter supply name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _totalAmountController,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _paidAmountController,
                decoration: const InputDecoration(labelText: 'Paid Amount'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter paid amount';
                  }
                  final paidAmount = double.tryParse(value);
                  if (paidAmount == null || paidAmount < 0) {
                    return 'Please enter a valid amount';
                  }
                  final totalAmount =
                      double.tryParse(_totalAmountController.text);
                  if (totalAmount != null && paidAmount > totalAmount) {
                    return 'Paid amount cannot exceed total amount';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedPaymentType,
                decoration: const InputDecoration(labelText: 'Payment Type'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'credit', child: Text('Credit')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentType = value!;
                  });
                },
              ),
              if (_selectedPaymentType == 'cash') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedPaymentMethodId,
                  decoration:
                      const InputDecoration(labelText: 'Payment Method'),
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
                    if (_selectedPaymentType == 'cash' && value == null) {
                      return 'Please select a payment method';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
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
              final supply = Supply(
                name: _nameController.text,
                totalAmount: double.parse(_totalAmountController.text),
                paidAmount: double.parse(_paidAmountController.text),
                paymentType: _selectedPaymentType,
                paymentMethodId: _selectedPaymentType == 'cash'
                    ? _selectedPaymentMethodId
                    : null,
                date: _selectedDate,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
              );

              await _dbHelper.insertSupply(supply);
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
