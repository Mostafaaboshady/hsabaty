/// Model representing an expense in the Khiat app.
///
/// Includes amount, date, payment method, and expense type.

import 'payment_method.dart';

/// Represents an expense entry in the application.
class Expense {
  final int? id;
  final DateTime date;
  final double amount;
  final int paymentMethodId;
  final String expenseType; // 'rent', 'salary', 'other'
  final String? description;
  final PaymentMethod? paymentMethod;

  Expense({
    this.id,
    required this.date,
    required this.amount,
    required this.paymentMethodId,
    required this.expenseType,
    this.description,
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'payment_method_id': paymentMethodId,
      'expense_type': expenseType,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      amount: map['amount'] as double,
      paymentMethodId: map['payment_method_id'] as int,
      expenseType: map['expense_type'] as String,
      description: map['description'] as String?,
      paymentMethod: map['payment_method'] != null
          ? PaymentMethod.fromMap(map['payment_method'] as Map<String, dynamic>)
          : null,
    );
  }
}
