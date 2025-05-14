import 'package:sqflite/sqflite.dart';
import '../database_config.dart';
import '../../models/ledger.dart';

class LedgerRepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig();

  Future<List<LedgerEntry>> getLedgerEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final Database db = await _databaseConfig.database;

    String dateFilter = '';
    List<String> whereArgs = [];

    if (startDate != null && endDate != null) {
      dateFilter = 'WHERE date BETWEEN ? AND ?';
      whereArgs = [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ];
    }

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        'revenue' as entry_type,
        date,
        amount,
        revenue_type as transaction_type,
        description,
        payment_method_id
      FROM revenues
      $dateFilter
      
      UNION ALL
      
      SELECT 
        'expense' as entry_type,
        date,
        -amount as amount,
        expense_type as transaction_type,
        description,
        payment_method_id
      FROM expenses
      $dateFilter
      
      UNION ALL
      
      SELECT 
        'supply' as entry_type,
        date,
        -amount as amount,
        supply_type as transaction_type,
        description,
        payment_method_id
      FROM supplies
      $dateFilter
      
      ORDER BY date DESC
    ''', whereArgs);

    return List.generate(
      results.length,
      (i) => LedgerEntry.fromMap(results[i]),
    );
  }

  Future<Map<String, double>> getFinancialSummary() async {
    final Database db = await _databaseConfig.database;

    // Get total revenues
    final revenueResult = await db
        .rawQuery('SELECT COALESCE(SUM(amount), 0) as total FROM revenues');
    final totalRevenues = (revenueResult.first['total'] as num).toDouble();

    // Get total expenses
    final expenseResult = await db
        .rawQuery('SELECT COALESCE(SUM(amount), 0) as total FROM expenses');
    final totalExpenses = (expenseResult.first['total'] as num).toDouble();

    // Get total supplies using total_amount
    final supplyResult = await db.rawQuery(
        'SELECT COALESCE(SUM(total_amount), 0) as total FROM supplies');
    final totalSupplies = (supplyResult.first['total'] as num).toDouble();

    // Get latest bank and cash balances
    final bankCashResult = await db.rawQuery('''
      SELECT COALESCE(
        (SELECT bank_balance_after 
         FROM bank_transactions 
         ORDER BY id DESC LIMIT 1),
        0
      ) as bank_balance,
      COALESCE(
        (SELECT cash_balance_after 
         FROM bank_transactions 
         ORDER BY id DESC LIMIT 1),
        0
      ) as cash_balance
    ''');

    final bankBalance =
        (bankCashResult.first['bank_balance'] as num).toDouble();
    final cashBalance =
        (bankCashResult.first['cash_balance'] as num).toDouble();

    return {
      'total_revenue': totalRevenues,
      'total_expenses': totalExpenses,
      'total_supplies': totalSupplies,
      'bank_balance': bankBalance,
      'cash_balance': cashBalance,
      'net_profit': totalRevenues - totalExpenses - totalSupplies,
    };
  }
}
