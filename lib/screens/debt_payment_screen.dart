import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../models/debt.dart';
import '../models/payment_method.dart';
import '../providers/balance_provider.dart';
import 'package:intl/intl.dart';

/// Screen for viewing and managing payments for a specific debt.
///
/// Displays payment history and allows adding new payments.
class DebtPaymentScreen extends StatefulWidget {
  final Debt debt;

  const DebtPaymentScreen({super.key, required this.debt});

  @override
  State<DebtPaymentScreen> createState() => _DebtPaymentScreenState();
}

class _DebtPaymentScreenState extends State<DebtPaymentScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  PaymentMethod? _selectedPaymentMethod;
  List<PaymentMethod> _paymentMethods = [];
  List<DebtPayment> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final paymentMethods = await _dbHelper.getPaymentMethods();
    final debts = await _dbHelper.getDebts();
    final currentDebt = debts.firstWhere((debt) => debt.id == widget.debt.id);

    if (mounted) {
      setState(() {
        _paymentMethods = paymentMethods;
        _selectedPaymentMethod =
            paymentMethods.isNotEmpty ? paymentMethods.first : null;
        _payments = currentDebt.payments ?? [];
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
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
  }

  Future<void> _addPayment() async {
    if (!_formKey.currentState!.validate() || _selectedPaymentMethod == null)
      return;

    final payment = DebtPayment(
      debtId: widget.debt.id!,
      date: _selectedDate,
      amount: double.parse(_amountController.text),
      paymentMethodId: _selectedPaymentMethod!.id!,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
    );

    await _dbHelper.insertDebtPayment(payment);
    await _loadData();

    if (mounted) {
      _amountController.clear();
      _descriptionController.clear();
      context.read<BalanceProvider>().refreshAll();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments for ${widget.debt.creditorName}'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Total Amount: \$${widget.debt.totalAmount.toStringAsFixed(2)}'),
                  Text(
                      'Paid Amount: \$${widget.debt.paidAmount.toStringAsFixed(2)}'),
                  Text(
                      'Remaining: \$${widget.debt.remainingAmount.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                return ListTile(
                  title: Text('\$${payment.amount.toStringAsFixed(2)}'),
                  subtitle: Text(
                    '${DateFormat('yyyy-MM-dd').format(payment.date)}\n'
                    '${payment.paymentMethod?.name ?? 'Unknown method'}',
                  ),
                  trailing: payment.description != null
                      ? IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(payment.description!)),
                            );
                          },
                        )
                      : null,
                );
              },
            ),
          ),
          if (!widget.debt.isFullyPaid)
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Amount'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          if (amount > widget.debt.remainingAmount) {
                            return 'Amount cannot exceed remaining balance';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<PaymentMethod>(
                        value: _selectedPaymentMethod,
                        decoration:
                            const InputDecoration(labelText: 'Payment Method'),
                        items: _paymentMethods.map((PaymentMethod method) {
                          return DropdownMenuItem<PaymentMethod>(
                            value: method,
                            child: Text(method.name),
                          );
                        }).toList(),
                        onChanged: (PaymentMethod? value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a payment method';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            labelText: 'Description (Optional)'),
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
                            onPressed: () => _selectDate(context),
                            child: const Text('Select Date'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addPayment,
                        child: const Text('Add Payment'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
