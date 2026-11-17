const int defaultWalletThemeColor = 0xFFF9D365;

class Wallet {
  final String id;
  final String name;
  final double initialBalance;
  final int themeColor;

  Wallet({
    required this.id,
    required this.name,
    required this.initialBalance,
    this.themeColor = defaultWalletThemeColor,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initialBalance': initialBalance,
    'themeColor': themeColor,
  };

  factory Wallet.fromJson(Map<String, dynamic> map) => Wallet(
    id: map['id'] ?? '',
    name: map['name'] ?? 'Wallet',
    initialBalance: (map['initialBalance'] ?? 0).toDouble(),
    themeColor: (map['themeColor'] as num?)?.toInt() ?? defaultWalletThemeColor,
  );
}
