import 'package:sqflite/sqflite.dart';
import '../database_config.dart';
import '../../models/revenue.dart';
import '../../models/payment_method.dart';

class RevenueRepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig();

  Future<int> insert(Revenue revenue) async {
    final Database db = await _databaseConfig.database;
    return await db.insert('revenues', revenue.toMap());
  }

  Future<List<Revenue>> getAll() async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT r.*, p.* 
      FROM revenues r 
      LEFT JOIN payment_methods p ON r.payment_method_id = p.id
    ''');

    return List.generate(maps.length, (i) {
      final paymentMethod = maps[i]['payment_method_id'] != null
          ? PaymentMethod.fromMap({
              'id': maps[i]['payment_method_id'],
              'name': maps[i]['name'],
              'description': maps[i]['description'],
            })
          : null;

      return Revenue.fromMap({
        ...maps[i],
        'payment_method': paymentMethod,
      });
    });
  }

  Future<Revenue?> getById(int id) async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT r.*, p.* 
      FROM revenues r 
      LEFT JOIN payment_methods p ON r.payment_method_id = p.id
      WHERE r.id = ?
    ''', [id]);

    if (maps.isEmpty) return null;

    final paymentMethod = maps.first['payment_method_id'] != null
        ? PaymentMethod.fromMap({
            'id': maps.first['payment_method_id'],
            'name': maps.first['name'],
            'description': maps.first['description'],
          })
        : null;

    return Revenue.fromMap({
      ...maps.first,
      'payment_method': paymentMethod,
    });
  }

  Future<bool> delete(int id) async {
    final Database db = await _databaseConfig.database;
    final count = await db.delete(
      'revenues',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<bool> update(Revenue revenue) async {
    if (revenue.id == null) return false;

    final Database db = await _databaseConfig.database;
    final count = await db.update(
      'revenues',
      revenue.toMap(),
      where: 'id = ?',
      whereArgs: [revenue.id],
    );
    return count > 0;
  }
}
