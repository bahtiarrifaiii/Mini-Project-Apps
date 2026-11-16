import '../core/enums/transaction_type.dart';

class Transaction {
  final String id;
  final String walletId;
  final String categoryId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String description;

  const Transaction({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'walletId': walletId,
    'categoryId': categoryId,
    'type': type.storageValue,
    'amount': amount,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory Transaction.fromJson(Map<String, dynamic> map) => Transaction(
    id: map['id'] ?? '',
    walletId: map['walletId'] ?? '',
    categoryId: map['categoryId'] ?? '',
    type: TransactionTypeX.fromString(map['type'] ?? 'expense'),
    amount: (map['amount'] ?? 0).toDouble(),
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    description: map['description'] ?? '',
  );
}
