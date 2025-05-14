import 'package:sqflite/sqflite.dart';
import '../database_config.dart';
import '../../models/supply.dart';
import '../../models/payment_method.dart';

class SupplyRepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig();

  Future<int> insert(Supply supply) async {
    final Database db = await _databaseConfig.database;
    return await db.insert('supplies', supply.toMap());
  }

  Future<List<Supply>> getAll() async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.*, p.* 
      FROM supplies s 
      LEFT JOIN payment_methods p ON s.payment_method_id = p.id
    ''');

    return List.generate(maps.length, (i) {
      final paymentMethod = maps[i]['payment_method_id'] != null
          ? PaymentMethod.fromMap({
              'id': maps[i]['payment_method_id'],
              'name': maps[i]['name'],
              'description': maps[i]['description'],
            })
          : null;

      return Supply.fromMap({
        ...maps[i],
        'payment_method': paymentMethod,
      });
    });
  }

  Future<Supply?> getById(int id) async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.*, p.* 
      FROM supplies s 
      LEFT JOIN payment_methods p ON s.payment_method_id = p.id
      WHERE s.id = ?
    ''', [id]);

    if (maps.isEmpty) return null;

    final paymentMethod = maps.first['payment_method_id'] != null
        ? PaymentMethod.fromMap({
            'id': maps.first['payment_method_id'],
            'name': maps.first['name'],
            'description': maps.first['description'],
          })
        : null;

    return Supply.fromMap({
      ...maps.first,
      'payment_method': paymentMethod,
    });
  }

  Future<bool> delete(int id) async {
    final Database db = await _databaseConfig.database;
    final count = await db.delete(
      'supplies',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<bool> update(Supply supply) async {
    if (supply.id == null) return false;

    final Database db = await _databaseConfig.database;
    final count = await db.update(
      'supplies',
      supply.toMap(),
      where: 'id = ?',
      whereArgs: [supply.id],
    );
    return count > 0;
  }
}
