/// Model representing a payment method in the Khiat app.
///
/// Used for transactions such as cash or bank transfer.
class PaymentMethod {
  final int? id;
  final dynamic name; // 'cash', 'bank_transfer'
  final String? description;

  PaymentMethod({
    this.id,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] as int?,
      name: map['name'] as dynamic,
      description: map['description'] as String?,
    );
  }
}
