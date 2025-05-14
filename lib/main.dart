import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/language_provider.dart';
import 'providers/balance_provider.dart';
import 'homepage.dart';
import 'screens/revenue_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/supplies_screen.dart';
import 'screens/bank_and_cash_screen.dart';
import 'screens/others_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/debts_screen.dart';

/// Main entry point for the Khiat application.
///
/// Initializes FFI for Windows support and sets up providers and routes.
void main() {
  // Initialize FFI for Windows support
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

/// The root widget for the Khiat app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
      ],
      child: MaterialApp(
        title: 'hsapaty',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => const HomePage(),
          '/revenue': (context) => const RevenueScreen(),
          '/expenses': (context) => const ExpensesScreen(),
          '/supplies': (context) => const SuppliesScreen(),
          '/bank-and-cash': (context) => const BankAndCashScreen(),
          '/others': (context) => const OthersScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/debts': (context) => const DebtsScreen(),
        },
      ),
    );
  }
}
