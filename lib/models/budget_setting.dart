import '../core/utils/date_formatter.dart';

class BudgetSetting {
  final String monthKeyValue;
  final double limit;

  const BudgetSetting({required this.monthKeyValue, required this.limit});

  Map<String, dynamic> toJson() => {
    'monthKeyValue': monthKeyValue,
    'limit': limit,
  };

  factory BudgetSetting.fromJson(Map<String, dynamic> map) => BudgetSetting(
    monthKeyValue: map['monthKeyValue'] ?? monthKey(DateTime.now()),
    limit: (map['limit'] ?? 0).toDouble(),
  );
}
