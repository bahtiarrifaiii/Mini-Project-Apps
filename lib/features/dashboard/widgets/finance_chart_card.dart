import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/transaction_type.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/cash_flow_data.dart';

class FinanceChartCard extends StatefulWidget {
  final CashFlowData data;
  final DateTime now;

  const FinanceChartCard({
    super.key,
    required this.data,
    required this.now,
  });

  @override
  State<FinanceChartCard> createState() => _FinanceChartCardState();
}

class _FinanceChartCardState extends State<FinanceChartCard> {
  late DateTime _selectedChartMonth;
  bool _showIncomeChart = true;

  @override
  void initState() {
    super.initState();
    _selectedChartMonth = DateTime(widget.now.year, widget.now.month, 1);
  }

  @override
  void didUpdateWidget(covariant FinanceChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.now.month != widget.now.month ||
        oldWidget.now.year != widget.now.year) {
      if (_selectedChartMonth.year == oldWidget.now.year &&
          _selectedChartMonth.month == oldWidget.now.month) {
        _selectedChartMonth = DateTime(widget.now.year, widget.now.month, 1);
      }
    }
  }

  String _formatAxisValue(double value) {
    if (value == 0) return '0';
    if (value >= 1000) {
      final millions = value / 1000;
      final text = millions == millions.roundToDouble()
          ? millions.toStringAsFixed(0)
          : millions.toStringAsFixed(1).replaceAll('.', ',');
      return '$text jt';
    }
    return '${value.round()} rb';
  }

  @override
  Widget build(BuildContext context) {
    final now = widget.now;
    final months = List<DateTime>.generate(
      12,
      (index) => DateTime(now.year, now.month - index, 1),
    );
    if (!months.any((month) =>
        month.year == _selectedChartMonth.year &&
        month.month == _selectedChartMonth.month)) {
      _selectedChartMonth = months.first;
    }

    final selectedType =
        _showIncomeChart ? TransactionType.income : TransactionType.expense;
    final total = widget.data.chartTotal(_selectedChartMonth, selectedType);
    final weeklyTotals =
        widget.data.weeklyChartTotals(_selectedChartMonth, selectedType);
    final labels = widget.data.weeklyChartLabels(_selectedChartMonth);
    final maxValue = weeklyTotals.fold<double>(
      0,
      (current, value) => value > current ? value : current,
    );

    final maxInThousands = maxValue / 1000;
    final chartMax = maxInThousands <= 1200
        ? 1200.0
        : (maxInThousands / 4).ceil() * 4.0;
    final axisInterval = chartMax / 4;

    final isCurrentMonth = _selectedChartMonth.year == now.year &&
        _selectedChartMonth.month == now.month;
    final baseColor =
        _showIncomeChart ? const Color(0xFF16A66A) : const Color(0xFFE05252);
    final mutedColor =
        _showIncomeChart ? const Color(0xFF9BCDB5) : const Color(0xFFE6A3A3);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafik Keuangan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.35,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Pemasukan')),
                    ButtonSegment(value: false, label: Text('Pengeluaran')),
                  ],
                  selected: {_showIncomeChart},
                  onSelectionChanged: (selection) {
                    setState(() => _showIncomeChart = selection.first);
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 11, horizontal: 9),
                    ),
                    textStyle: const WidgetStatePropertyAll(
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFF404040);
                      }
                      return const Color(0xFF1E1E1E);
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return Colors.white60;
                    }),
                    side: const WidgetStatePropertyAll(
                      BorderSide(color: Color(0xFF404040)),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DateTime>(
            initialValue: _selectedChartMonth,
            isExpanded: true,
            dropdownColor: const Color(0xFF1E1E1E),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              prefixIcon: const Icon(
                Icons.calendar_month_rounded,
                size: 21,
                color: Colors.white70,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF404040)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
            ),
            items: months.map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(month),
                ),
              );
            }).toList(),
            onChanged: (month) {
              if (month != null) {
                setState(() => _selectedChartMonth = month);
              }
            },
          ),
          const SizedBox(height: 18),
          Text(
            formatCurrency(total),
            style: TextStyle(
              fontSize: 26,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w800,
              color: baseColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Total ${_showIncomeChart ? 'pemasukan' : 'pengeluaran'} · '
            '${DateFormat('MMMM yyyy', 'id_ID').format(_selectedChartMonth)}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 218,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: chartMax,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${labels[group.x]}\n${formatCurrency(rod.toY * 1000)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(4, (index) {
                  final valueInThousands = weeklyTotals[index] / 1000;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: valueInThousands,
                        width: 25,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(7),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isCurrentMonth
                              ? [
                                  baseColor.withValues(alpha: 0.65),
                                  baseColor,
                                ]
                              : [
                                  mutedColor.withValues(alpha: 0.55),
                                  mutedColor,
                                ],
                        ),
                        borderSide: BorderSide(
                          color: isCurrentMonth ? baseColor : mutedColor,
                          width: isCurrentMonth ? 1.2 : 0.5,
                        ),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: axisInterval,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white12,
                    strokeWidth: 1,
                    dashArray: isCurrentMonth ? [5, 4] : null,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: axisInterval,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatAxisValue(value),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white60,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[index],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
