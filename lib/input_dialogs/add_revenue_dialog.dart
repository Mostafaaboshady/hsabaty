import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/revenue.dart';
import '../providers/balance_provider.dart';
import 'package:intl/intl.dart';

class AddRevenueDialog extends StatefulWidget {
  const AddRevenueDialog({super.key});

  @override
  State<AddRevenueDialog> createState() => _AddRevenueDialogState();
}

class _AddRevenueDialogState extends State<AddRevenueDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedRevenueType = 'advance_payment';
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
      title: const Text('Add New Revenue'),
      content: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRevenueType,
                  items: const [
                    DropdownMenuItem(
                        value: 'advance_payment',
                        child: Text('Advance Payment')),
                    DropdownMenuItem(
                        value: 'service_completion',
                        child: Text('Service Completion')),
                    DropdownMenuItem(
                        value: 'end_of_service', child: Text('End of Service')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRevenueType = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Revenue Type'),
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
                  subtitle:
                      Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final revenue = Revenue(
                date: _selectedDate,
                amount: double.parse(_amountController.text),
                paymentMethodId: 22, // تم إلغاؤه
                revenueType: _selectedRevenueType,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
              );

              await _dbHelper.insertRevenue(revenue);
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
