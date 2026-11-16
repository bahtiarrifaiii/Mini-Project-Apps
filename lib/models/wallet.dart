class Wallet {
  final String id;
  final String name;
  final double initialBalance;

  Wallet({required this.id, required this.name, required this.initialBalance});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initialBalance': initialBalance,
  };

  factory Wallet.fromJson(Map<String, dynamic> map) => Wallet(
    id: map['id'] ?? '',
    name: map['name'] ?? 'Wallet',
    initialBalance: (map['initialBalance'] ?? 0).toDouble(),
  );
}
