/// Model representing a ledger in the Khiat app.
///
/// Includes ledger details, balances, and entries.
class Ledger {
  final int? ledgerId;
  final String ledgerName;
  final String
      ledgerType; // 'revenue', 'expense', 'supply', 'bank', 'cash', 'debt'
  final double? openingBalance;
  final double currentBalance;
  final DateTime lastUpdated;
  final String? description;

  Ledger({
    this.ledgerId,
    required this.ledgerName,
    required this.ledgerType,
    this.openingBalance,
    required this.currentBalance,
    required this.lastUpdated,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'ledger_id': ledgerId,
      'ledger_name': ledgerName,
      'ledger_type': ledgerType,
      'opening_balance': openingBalance,
      'current_balance': currentBalance,
      'last_updated': lastUpdated.toIso8601String(),
      'description': description,
    };
  }

  factory Ledger.fromMap(Map<String, dynamic> map) {
    return Ledger(
      ledgerId: map['ledger_id'] as int?,
      ledgerName: map['ledger_name'] as String,
      ledgerType: map['ledger_type'] as String,
      openingBalance: map['opening_balance'] as double?,
      currentBalance: map['current_balance'] as double,
      lastUpdated: DateTime.parse(map['last_updated'] as String),
      description: map['description'] as String?,
    );
  }
}

/// Model representing an entry in a ledger.
class LedgerEntry {
  final String entryType; // 'revenue', 'expense', 'supply'
  final DateTime date;
  final double amount;
  final String transactionType;
  final String? description;
  final int? paymentMethodId;

  LedgerEntry({
    required this.entryType,
    required this.date,
    required this.amount,
    required this.transactionType,
    this.description,
    this.paymentMethodId,
  });

  Map<String, dynamic> toMap() {
    return {
      'entry_type': entryType,
      'date': date.toIso8601String(),
      'amount': amount,
      'transaction_type': transactionType,
      'description': description,
      'payment_method_id': paymentMethodId,
    };
  }

  factory LedgerEntry.fromMap(Map<String, dynamic> map) {
    return LedgerEntry(
      entryType: map['entry_type'] as String,
      date: DateTime.parse(map['date'] as String),
      amount: map['amount'] as double,
      transactionType: map['transaction_type'] as String,
      description: map['description'] as String?,
      paymentMethodId: map['payment_method_id'] as int?,
    );
  }
}
