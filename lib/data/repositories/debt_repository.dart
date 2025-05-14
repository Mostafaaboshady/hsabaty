import 'package:sqflite/sqflite.dart';
import '../database_config.dart';
import '../../models/debt.dart';

class DebtRepository {
  final DatabaseConfig _databaseConfig = DatabaseConfig();

  Future<int> insert(Debt debt) async {
    final Database db = await _databaseConfig.database;
    return await db.insert('debts', debt.toMap());
  }

  Future<int> insertDebtPayment(DebtPayment payment) async {
    final Database db = await _databaseConfig.database;
    return await db.insert('debt_payments', payment.toMap());
  }

  Future<List<Debt>> getAll() async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> debts = await db.query('debts');

    final List<Debt> debtList = [];
    for (var debtMap in debts) {
      final payments = await db.query(
        'debt_payments',
        where: 'debt_id = ?',
        whereArgs: [debtMap['id']],
      );

      // Calculate total paid amount from payments
      final totalPaid = payments.fold<double>(
        0,
        (sum, payment) => sum + (payment['amount'] as double),
      );

      // Update the paid_amount in the debt map
      debtMap['paid_amount'] = totalPaid;

      // Create debt instance with payments
      final debt = Debt.fromMap({
        ...debtMap,
        'payments': payments,
      });

      debtList.add(debt);
    }
    return debtList;
  }

  Future<List<DebtPayment>> getPaymentsForDebt(int debtId) async {
    final Database db = await _databaseConfig.database;
    final List<Map<String, dynamic>> payments = await db.query(
      'debt_payments',
      where: 'debt_id = ?',
      whereArgs: [debtId],
    );
    return payments.map((p) => DebtPayment.fromMap(p)).toList();
  }
}
