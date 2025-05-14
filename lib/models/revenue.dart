/// Model representing a revenue entry in the Khiat app.
///
/// Includes amount, date, payment method, and revenue type.
import 'payment_method.dart';

/// Represents a revenue entry with details such as amount, date, payment method, and revenue type.
class Revenue {
  final int? id;
  final DateTime date;
  final double amount;
  final int paymentMethodId;
  final String
      revenueType; // 'advance_payment', 'service_completion', 'end_of_service'
  final String? description;
  final PaymentMethod? paymentMethod;

  Revenue({
    this.id,
    required this.date,
    required this.amount,
    required this.paymentMethodId,
    required this.revenueType,
    this.description,
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'payment_method_id': paymentMethodId,
      'revenue_type': revenueType,
      'description': description,
    };
  }

  factory Revenue.fromMap(Map<String, dynamic> map) {
    return Revenue(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      amount: (map['amount'] as num).toDouble(),
      paymentMethodId: map['payment_method_id'] as int,
      revenueType: map['revenue_type'] as String,
      description: map['description'] as String?,
      paymentMethod: map['payment_method'] != null &&
              map['payment_method'] is Map<String, dynamic>
          ? PaymentMethod.fromMap(map['payment_method'] as Map<String, dynamic>)
          : null,
    );
  }
}
