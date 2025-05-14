import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/supply.dart';
import '../models/payment_method.dart';
import '../input_dialogs/add_supply_dialog.dart';

class SuppliesScreen extends StatefulWidget {
  const SuppliesScreen({super.key});

  @override
  State<SuppliesScreen> createState() => _SuppliesScreenState();
}

class _SuppliesScreenState extends State<SuppliesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Supply> _supplies = [];
  List<PaymentMethod> _paymentMethods = [];
  double _totalSupplies = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final supplies = await _dbHelper.getSupplies();
    final paymentMethods = await _dbHelper.getPaymentMethods();
    double total = 0;
    for (var supply in supplies) {
      total += supply.totalAmount;
    }

    if (mounted) {
      setState(() {
        _supplies = supplies;
        _paymentMethods = paymentMethods;
        _totalSupplies = total;
      });
    }
  }

  Future<void> _showAddSupplyDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddSupplyDialog(paymentMethods: _paymentMethods),
    );

    if (result == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplies'),
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
                    'Total Supplies:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '\$${_totalSupplies.toStringAsFixed(2)}',
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
              itemCount: _supplies.length,
              itemBuilder: (context, index) {
                final supply = _supplies[index];
                final paymentMethod = supply.paymentMethodId != null
                    ? _paymentMethods.firstWhere(
                        (method) => method.id == supply.paymentMethodId,
                        orElse: () => PaymentMethod(id: -1, name: 'Unknown'),
                      )
                    : null;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(supply.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Total Amount: \$${supply.totalAmount.toStringAsFixed(2)}'),
                        Text(
                            'Paid Amount: \$${supply.paidAmount.toStringAsFixed(2)}'),
                        Text(
                            'Remaining: \$${(supply.totalAmount - supply.paidAmount).toStringAsFixed(2)}'),
                        Text('Payment Type: ${supply.paymentType}'),
                        if (paymentMethod != null)
                          Text('Payment Method: ${paymentMethod.name}'),
                        if (supply.description != null)
                          Text('Note: ${supply.description}'),
                        Text(
                            'Date: ${supply.date.toString().substring(0, 10)}'),
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
        onPressed: _showAddSupplyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
