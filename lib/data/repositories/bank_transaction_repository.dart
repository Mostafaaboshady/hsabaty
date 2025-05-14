import 'package:sqflite/sqflite.dart';
import '../database_config.dart';
import '../../models/bank_transaction.dart';

class BankTransactionRepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig();

  Future<int> insert(BankTransaction transaction) async {
    final Database db = await _databaseConfig.database;
    return await db.insert('bank_transactions', transaction.toMap());
  }

  Future<List<BankTransaction>> getAll() async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> maps = await db.query('bank_transactions');
    return List.generate(maps.length, (i) => BankTransaction.fromMap(maps[i]));
  }

  Future<Map<String, double>> getTradingBalance() async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
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

    return {
      'bank_balance': (result.first['bank_balance'] as num).toDouble(),
      'cash_balance': (result.first['cash_balance'] as num).toDouble(),
    };
  }
}
