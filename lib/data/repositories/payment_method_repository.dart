import 'package:sqflite/sqflite.dart';
import '../database_config.dart';
import '../../models/payment_method.dart';

class PaymentMethodRepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig();

  Future<int> insert(PaymentMethod paymentMethod) async {
    final Database db = await _databaseConfig.database;
    return await db.insert('payment_methods', paymentMethod.toMap());
  }

  Future<List<PaymentMethod>> getAll() async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> maps = await db.query('payment_methods');
    return List.generate(maps.length, (i) => PaymentMethod.fromMap(maps[i]));
  }

  Future<PaymentMethod?> getById(int id) async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payment_methods',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PaymentMethod.fromMap(maps.first);
  }

  Future<bool> delete(int id) async {
    final Database db = await _databaseConfig.database;
    final count = await db.delete(
      'payment_methods',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<bool> update(PaymentMethod paymentMethod) async {
    if (paymentMethod.id == null) return false;

    final Database db = await _databaseConfig.database;
    final count = await db.update(
      'payment_methods',
      paymentMethod.toMap(),
      where: 'id = ?',
      whereArgs: [paymentMethod.id],
    );
    return count > 0;
  }
}
