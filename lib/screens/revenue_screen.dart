import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/revenue.dart';
import '../models/payment_method.dart';
import '../input_dialogs/add_revenue_dialog.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Revenue> _revenues = [];
  List<PaymentMethod> _paymentMethods = [];
  double _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final revenues = await _dbHelper.getRevenues();
    final paymentMethods = await _dbHelper.getPaymentMethods();
    double total = 0;
    for (var revenue in revenues) {
      total += revenue.amount;
    }

    if (mounted) {
      setState(() {
        _revenues = revenues;
        _paymentMethods = paymentMethods;
        _totalRevenue = total;
      });
    }
  }

  Future<void> _showAddRevenueDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddRevenueDialog(),
    );

    if (result == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue'),
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
                    'Total Revenue:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '\$${_totalRevenue.toStringAsFixed(2)}',
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
              itemCount: _revenues.length,
              itemBuilder: (context, index) {
                final revenue = _revenues[index];
                final paymentMethod = _paymentMethods.firstWhere(
                  (method) => method.id == revenue.id,
                  orElse: () => PaymentMethod(id: -1, name: 'Unknown'),
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text('\$${revenue.amount.toStringAsFixed(2)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${revenue.revenueType}'),
                        Text('Payment: ${paymentMethod.name}'),
                        if (revenue.description != null)
                          Text('Note: ${revenue.description}'),
                        Text(
                            'Date: ${revenue.date.toString().substring(0, 10)}'),
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
        onPressed: _showAddRevenueDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
