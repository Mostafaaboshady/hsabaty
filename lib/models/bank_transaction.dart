/// Model representing a bank transaction in the Khiat app.
///
/// Includes transaction type, amount, date, and resulting balances.
class BankTransaction {
  final int? id;
  final DateTime date;
  final double amount;
  final String transactionType; // 'bank_to_cash', 'capital_withdrawal'
  final String? description;
  final double bankBalanceAfter;
  final double cashBalanceAfter;

  BankTransaction({
    this.id,
    required this.date,
    required this.amount,
    required this.transactionType,
    required this.bankBalanceAfter,
    required this.cashBalanceAfter,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'transaction_type': transactionType,
      'bank_balance_after': bankBalanceAfter,
      'cash_balance_after': cashBalanceAfter,
      'description': description,
    };
  }

  factory BankTransaction.fromMap(Map<String, dynamic> map) {
    return BankTransaction(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      amount: map['amount'] as double,
      transactionType: map['transaction_type'] as String,
      bankBalanceAfter: map['bank_balance_after'] as double,
      cashBalanceAfter: map['cash_balance_after'] as double,
      description: map['description'] as String?,
    );
  }
}
