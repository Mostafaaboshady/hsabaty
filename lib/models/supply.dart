/// Model representing a supply entry in the Khiat app.
///
/// Includes supply details, payment status, and payment method.

import 'payment_method.dart';

/// Represents a supply entry with details about the supply, payment status, and payment method.
class Supply {
  final int? id;
  final DateTime date;
  final String name;
  final double totalAmount;
  final double paidAmount;
  final String paymentType; // 'cash', 'credit', 'advance_payment'
  final int? paymentMethodId; // Null if credit purchase
  final String? description;
  final PaymentMethod? paymentMethod;

  Supply({
    this.id,
    required this.date,
    required this.name,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentType,
    this.paymentMethodId,
    this.description,
    this.paymentMethod,
  });

  double get remainingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'name': name,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'payment_type': paymentType,
      'payment_method_id': paymentMethodId,
      'description': description,
    };
  }

  factory Supply.fromMap(Map<String, dynamic> map) {
    return Supply(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      name: map['name'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      paymentType: map['payment_type'] as String,
      paymentMethodId: map['payment_method_id'] as int?,
      description: map['description'] as String?,
      paymentMethod: map['payment_method'] != null &&
              map['payment_method'] is Map<String, dynamic>
          ? PaymentMethod.fromMap(map['payment_method'] as Map<String, dynamic>)
          : null,
    );
  }
}
