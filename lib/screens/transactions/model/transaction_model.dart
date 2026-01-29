/// Transaction Model
/// Data class representing a financial transaction
class Transaction {
  final int id;
  final String reference;
  final int clientId;
  final String clientName;
  final DateTime date;
  final double amount;
  final double amountPaid;
  final double amountRemaining;
  final String paymentMethod;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.reference,
    required this.clientId,
    required this.clientName,
    required this.date,
    required this.amount,
    required this.amountPaid,
    required this.amountRemaining,
    required this.paymentMethod,
    required this.createdAt,
  });

  /// Check if fully paid
  bool get isFullyPaid => amountRemaining <= 0;

  /// Payment percentage
  double get paymentPercentage => amount > 0 ? (amountPaid / amount) * 100 : 0;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      reference: json['reference'] as String,
      clientId: json['clientId'] as int,
      clientName: json['clientName'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      amountRemaining: (json['amountRemaining'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'clientId': clientId,
      'clientName': clientName,
      'date': date.toIso8601String().split('T')[0],
      'amount': amount,
      'amountPaid': amountPaid,
      'amountRemaining': amountRemaining,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Transaction copyWith({
    int? id,
    String? reference,
    int? clientId,
    String? clientName,
    DateTime? date,
    double? amount,
    double? amountPaid,
    double? amountRemaining,
    String? paymentMethod,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      amountPaid: amountPaid ?? this.amountPaid,
      amountRemaining: amountRemaining ?? this.amountRemaining,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
