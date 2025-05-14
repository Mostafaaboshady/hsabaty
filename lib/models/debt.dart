/// Model representing a debt and its payments in the Khiat app.
///
/// Includes debt details, creditor, and associated payments.
import 'payment_method.dart';

/// Model representing a debt and its payments in the Khiat app.
///
/// Includes debt details, creditor, and associated payments.
class Debt {
  final int? id;
  final DateTime date;
  final String debtType; // 'loan_received', 'opening_balance'
  final double totalAmount;
  final double paidAmount;
  final String creditorName;
  final String? description;
  final List<DebtPayment>? payments;

  Debt({
    this.id,
    required this.date,
    required this.debtType,
    required this.totalAmount,
    required this.paidAmount,
    required this.creditorName,
    this.description,
    this.payments,
  });

  double get remainingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'debt_type': debtType,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'creditor_name': creditorName,
      'description': description,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      debtType: map['debt_type'] as String,
      totalAmount: map['total_amount'] as double,
      paidAmount: map['paid_amount'] as double,
      creditorName: map['creditor_name'] as String,
      description: map['description'] as String?,
      payments: map['payments'] != null
          ? (map['payments'] as List)
              .map((payment) =>
                  DebtPayment.fromMap(payment as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

/// Model representing a payment towards a debt.
class DebtPayment {
  final int? id;
  final int debtId;
  final DateTime date;
  final double amount;
  final int paymentMethodId;
  final String? description;
  final PaymentMethod? paymentMethod;

  DebtPayment({
    this.id,
    required this.debtId,
    required this.date,
    required this.amount,
    required this.paymentMethodId,
    this.description,
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debt_id': debtId,
      'date': date.toIso8601String(),
      'amount': amount,
      'payment_method_id': paymentMethodId,
      'description': description,
    };
  }

  factory DebtPayment.fromMap(Map<String, dynamic> map) {
    return DebtPayment(
      id: map['id'] as int?,
      debtId: map['debt_id'] as int,
      date: DateTime.parse(map['date'] as String),
      amount: map['amount'] as double,
      paymentMethodId: map['payment_method_id'] as int,
      description: map['description'] as String?,
      paymentMethod: map['payment_method'] != null
          ? PaymentMethod.fromMap(map['payment_method'] as Map<String, dynamic>)
          : null,
    );
  }
}
