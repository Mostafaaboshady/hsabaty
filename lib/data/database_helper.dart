import 'repositories/bank_transaction_repository.dart';
import 'repositories/debt_repository.dart';
import 'repositories/expense_repository.dart';
import 'repositories/payment_method_repository.dart';
import 'repositories/revenue_repository.dart';
import 'repositories/supply_repository.dart';
import '../models/bank_transaction.dart';
import '../models/debt.dart';
import '../models/expense.dart';
import '../models/payment_method.dart';
import '../models/revenue.dart';
import '../models/supply.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final _bankTransactionRepo = BankTransactionRepository();
  final _debtRepo = DebtRepository();
  final _expenseRepo = ExpenseRepository();
  final _paymentMethodRepo = PaymentMethodRepository();
  final _revenueRepo = RevenueRepository();
  final _supplyRepo = SupplyRepository();

  // Bank Transaction operations
  Future<int> insertBankTransaction(BankTransaction transaction) =>
      _bankTransactionRepo.insert(transaction);
  Future<List<BankTransaction>> getBankTransactions() =>
      _bankTransactionRepo.getAll();
  Future<Map<String, double>> getTradingBalance() =>
      _bankTransactionRepo.getTradingBalance();

  // Debt operations
  Future<int> insertDebt(Debt debt) => _debtRepo.insert(debt);
  Future<int> insertDebtPayment(DebtPayment payment) =>
      _debtRepo.insertDebtPayment(payment);
  Future<List<Debt>> getDebts() => _debtRepo.getAll();
  Future<List<DebtPayment>> getDebtPayments(int debtId) =>
      _debtRepo.getPaymentsForDebt(debtId);

  // Expense operations
  Future<int> insertExpense(Expense expense) => _expenseRepo.insert(expense);
  Future<List<Expense>> getExpenses() => _expenseRepo.getAll();

  // Payment Method operations
  Future<int> insertPaymentMethod(PaymentMethod method) =>
      _paymentMethodRepo.insert(method);
  Future<List<PaymentMethod>> getPaymentMethods() =>
      _paymentMethodRepo.getAll();
  Future<PaymentMethod?> getPaymentMethodById(int id) =>
      _paymentMethodRepo.getById(id);

  // Revenue operations
  Future<int> insertRevenue(Revenue revenue) => _revenueRepo.insert(revenue);
  Future<List<Revenue>> getRevenues() => _revenueRepo.getAll();

  // Supply operations
  Future<int> insertSupply(Supply supply) => _supplyRepo.insert(supply);
  Future<List<Supply>> getSupplies() => _supplyRepo.getAll();
}
