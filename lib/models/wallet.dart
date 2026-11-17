const int defaultWalletThemeColor = 0xFFF9D365;

class Wallet {
  final String id;
  final String name;
  final double initialBalance;
  final int themeColor;
  final String? themeImageBase64;

  Wallet({
    required this.id,
    required this.name,
    required this.initialBalance,
    this.themeColor = defaultWalletThemeColor,
    this.themeImageBase64,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initialBalance': initialBalance,
    'themeColor': themeColor,
    'themeImageBase64': themeImageBase64,
  };

  factory Wallet.fromJson(Map<String, dynamic> map) => Wallet(
    id: map['id'] ?? '',
    name: map['name'] ?? 'Wallet',
    initialBalance: (map['initialBalance'] ?? 0).toDouble(),
    themeColor: (map['themeColor'] as num?)?.toInt() ?? defaultWalletThemeColor,
    themeImageBase64: map['themeImageBase64'] as String?,
  );
}
