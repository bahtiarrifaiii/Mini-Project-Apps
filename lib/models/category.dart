import '../core/enums/transaction_type.dart';

class Category {
  final String id;
  final String name;
  final TransactionType type;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.storageValue,
    'isDefault': isDefault,
  };

  factory Category.fromJson(Map<String, dynamic> map) => Category(
    id: map['id'] ?? '',
    name: map['name'] ?? 'Kategori',
    type: TransactionTypeX.fromString(map['type'] ?? 'expense'),
    isDefault: map['isDefault'] ?? false,
  );
}
