import 'package:sqflite/sqflite.dart';
import '../database_config.dart';
import '../../models/expense.dart';

class ExpenseRepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig();

  Future<int> insert(Expense expense) async {
    final Database db = await _databaseConfig.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getAll() async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*, p.* 
      FROM expenses e 
      LEFT JOIN payment_methods p ON e.payment_method_id = p.id
    ''');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }
}
