import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/app_drawer.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/creditors_summary_card.dart';
import 'widgets/dashboard_charts.dart';
import 'providers/balance_provider.dart';

/// Home page of the Khiat application.
///
/// Displays financial summary, dashboard charts, and creditors summary.
class HomePage extends StatefulWidget {
  /// The main home page widget.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      await context.read<BalanceProvider>().refreshAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khiat'),
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<BalanceProvider>(
              builder: (context, balanceProvider, _) {
                final totalDebts = balanceProvider.debts.fold(0.0,
                    (sum, debt) => sum + (debt.totalAmount - debt.paidAmount));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FinancialSummaryCard(
                      tradingBalance: balanceProvider.tradingBalance,
                      totalDebts: totalDebts,
                    ),
                    const SizedBox(height: 16),
                    DashboardCharts(
                      revenues: balanceProvider.revenues,
                      expenses: balanceProvider.expenses,
                    ),
                    const SizedBox(height: 16),
                    CreditorsSummaryCard(debts: balanceProvider.debts),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
