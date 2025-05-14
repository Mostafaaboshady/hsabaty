import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseConfig {
  static final DatabaseConfig _instance = DatabaseConfig._internal();
  factory DatabaseConfig() => _instance;

  DatabaseConfig._internal() {
    // Initialize FFI for Windows support
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'khiat.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Payment Methods table
    await db.execute('''
      CREATE TABLE payment_methods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Revenue table
    await db.execute('''
      CREATE TABLE revenues(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method_id INTEGER NOT NULL,
        revenue_type TEXT NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(payment_method_id) REFERENCES payment_methods(id)
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method_id INTEGER NOT NULL,
        expense_type TEXT NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(payment_method_id) REFERENCES payment_methods(id)
      )
    ''');

    // Supplies table
    await db.execute('''
      CREATE TABLE supplies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method_id INTEGER NOT NULL,
        supply_type TEXT NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(payment_method_id) REFERENCES payment_methods(id)
      )
    ''');

    // Bank Transactions table
    await db.execute('''
      CREATE TABLE bank_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        transaction_type TEXT NOT NULL,
        description TEXT,
        bank_balance_after REAL NOT NULL,
        cash_balance_after REAL NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Debts table
    await db.execute('''
      CREATE TABLE debts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        creditor_name TEXT NOT NULL,
        description TEXT,
        is_paid INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Debt Payments table
    await db.execute('''
      CREATE TABLE debt_payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debt_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method_id INTEGER NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(debt_id) REFERENCES debts(id),
        FOREIGN KEY(payment_method_id) REFERENCES payment_methods(id)
      )
    ''');

    // Initial Balances table
    await db.execute('''
      CREATE TABLE initial_balances(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        cash_balance REAL NOT NULL,
        bank_balance REAL NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }
}
