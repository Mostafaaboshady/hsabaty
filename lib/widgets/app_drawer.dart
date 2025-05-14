import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/balance_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<BalanceProvider>(
        builder: (context, balanceProvider, _) => ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Khiat',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet),
                      title: const Text('Total Revenue'),
                      trailing: Text(
                        '\$${balanceProvider.tradingBalance['total_revenue']?.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.money_off),
                      title: const Text('Total Expenses'),
                      trailing: Text(
                        '\$${(balanceProvider.tradingBalance['total_expenses']! + balanceProvider.tradingBalance['total_supplies']!).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.account_balance),
                      title: const Text('Net Income'),
                      trailing: Text(
                        '\$${balanceProvider.tradingBalance['net_profit']?.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              balanceProvider.tradingBalance['net_profit']! >= 0
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Revenue'),
              onTap: () {
                Navigator.pushNamed(context, '/revenue');
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text('Expenses'),
              onTap: () {
                Navigator.pushNamed(context, '/expenses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Supplies'),
              onTap: () {
                Navigator.pushNamed(context, '/supplies');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Bank & Cash'),
              onTap: () {
                Navigator.pushNamed(context, '/bank-and-cash');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Debts'),
              onTap: () {
                Navigator.pushNamed(context, '/debts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.more_horiz),
              title: const Text('Others'),
              onTap: () {
                Navigator.pushNamed(context, '/others');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Rate Us'),
              onTap: () {
                // Rate us functionality implementation
              },
            ),
          ],
        ),
      ),
    );
  }
}
