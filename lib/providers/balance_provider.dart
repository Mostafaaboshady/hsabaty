import 'package:flutter/material.dart';
import '../data/repositories/ledger_repository.dart';
import '../data/database_helper.dart';
import '../models/debt.dart';
import '../models/revenue.dart';
import '../models/expense.dart';

/// Provider for managing and refreshing financial balances, debts, revenues, and expenses.
///
/// Uses repositories and database helpers to fetch and update data for the app dashboard.
class BalanceProvider extends ChangeNotifier {
  final LedgerRepository _ledgerRepo = LedgerRepository();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Map<String, double> _tradingBalance = {
    'total_revenue': 0.0,
    'total_expenses': 0.0,
    'total_supplies': 0.0,
    'bank_balance': 0.0,
    'cash_balance': 0.0,
    'net_profit': 0.0,
  };

  List<Debt> _debts = [];
  List<Revenue> _revenues = [];
  List<Expense> _expenses = [];

  Map<String, double> get tradingBalance => _tradingBalance;
  List<Debt> get debts => _debts;
  List<Revenue> get revenues => _revenues;
  List<Expense> get expenses => _expenses;

  Future<void> refreshAll() async {
    await Future.wait([
      updateBalance(),
      refreshDebts(),
      refreshRevenues(),
      refreshExpenses(),
    ]);
  }

  Future<void> updateBalance() async {
    final balance = await _ledgerRepo.getFinancialSummary();
    _tradingBalance = balance;
    notifyListeners();
  }

  Future<void> refreshDebts() async {
    _debts = await _dbHelper.getDebts();
    notifyListeners();
  }

  Future<void> refreshRevenues() async {
    _revenues = await _dbHelper.getRevenues();
    notifyListeners();
  }

  Future<void> refreshExpenses() async {
    _expenses = await _dbHelper.getExpenses();
    notifyListeners();
  }
}
