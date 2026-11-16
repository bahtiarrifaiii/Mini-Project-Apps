import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/enums/transaction_type.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/cash_flow_data.dart';

class DashboardScreen extends StatefulWidget {
  final CashFlowData data;

  const DashboardScreen({super.key, required this.data});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  late DateTime _now;
  Timer? _clockTimer;
  late DateTime _selectedChartMonth;
  bool _showIncomeChart = true;
  bool _hideBalance = false;

  CashFlowData get data => widget.data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = DateTime.now();
    _selectedChartMonth = DateTime(_now.year, _now.month, 1);
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _now = DateTime.now());
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String get _greeting {
    final hour = _now.hour;
    if (hour >= 5 && hour < 11) return 'Halo, selamat pagi!';
    if (hour >= 11 && hour < 15) return 'Halo, selamat siang!';
    if (hour >= 15 && hour < 18) return 'Halo, selamat sore!';
    return 'Halo, selamat malam!';
  }

  String get _formattedToday =>
      DateFormat('EEEE, d MMMM y', 'id_ID').format(_now);



  Widget _buildDateChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 15, color: Color(0xFF4775B8)),
          const SizedBox(width: 8),
          Text(
            _formattedToday,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF45658F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceHero(double balance) {
    return Container(
      padding: const EdgeInsets.fromLTRB(19, 18, 18, 19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF397FC7), Color(0xFF245B9D)],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF285F9F).withValues(alpha: 0.17),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Total Saldo',
                  style: TextStyle(
                    color: Color(0xDFFFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _hideBalance = !_hideBalance),
                visualDensity: VisualDensity.compact,
                tooltip: _hideBalance ? 'Tampilkan saldo' : 'Sembunyikan saldo',
                icon: Icon(
                  _hideBalance
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _hideBalance ? 'Rp ******' : formatCurrency(balance),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              letterSpacing: -0.7,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    bool wide = false,
  }) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF707989),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202938),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceChart() {
    // Tampilkan bulan berjalan dan 11 bulan sebelumnya agar bulan tetap
    // bisa dipilih meskipun belum ada transaksi pada bulan tersebut.
    final now = DateTime.now();
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
    final total = data.chartTotal(_selectedChartMonth, selectedType);
    final weeklyTotals =
        data.weeklyChartTotals(_selectedChartMonth, selectedType);
    final labels = data.weeklyChartLabels(_selectedChartMonth);
    final maxValue = weeklyTotals.fold<double>(
      0,
      (current, value) => value > current ? value : current,
    );

    // Skala dihitung ulang berdasarkan jenis transaksi yang dipilih.
    // Selalu tampilkan 5 label dengan jarak yang sama: 0 sampai batas atas.
    final maxInThousands = maxValue / 1000;
    final chartMax = maxInThousands <= 1200
        ? 1200.0
        : (maxInThousands / 4).ceil() * 4.0;
    final axisInterval = chartMax / 4;

    String formatAxisValue(double value) {
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

    final isCurrentMonth = _selectedChartMonth.year == _now.year &&
        _selectedChartMonth.month == _now.month;
    final baseColor = _showIncomeChart ? const Color(0xFF16A66A) : const Color(0xFFE05252);
    final mutedColor = _showIncomeChart ? const Color(0xFF9BCDB5) : const Color(0xFFE6A3A3);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8ECF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26364D).withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Color(0xFF3978C5),
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
                          return const Color(0xFFE8EFFD);
                        }
                        return const Color(0xFFF7F8FB);
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFF315F9D);
                        }
                        return const Color(0xFF687386);
                      }),
                      side: const WidgetStatePropertyAll(
                        BorderSide(color: Color(0xFFE5E9F0)),
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
              value: _selectedChartMonth,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF7F8FC),
                prefixIcon: const Icon(Icons.calendar_month_rounded, size: 21),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE3E7EF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF526B96),
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
              style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                            color: isCurrentMonth
                                ? baseColor
                                : mutedColor,
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
                      color: Colors.grey.withValues(alpha: 0.16),
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
                            formatAxisValue(value),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
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

  @override
  Widget build(BuildContext context) {
    final income = data.totalIncomeThisMonth();
    final expense = data.totalExpenseThisMonth();
    final balance = data.totalBalance();
    final budget = data.currentBudget();

    return RefreshIndicator(
      onRefresh: () async => data.refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 45, 18, 22),
        children: [
          Text(
            _greeting,
            style: const TextStyle(
              fontSize: 25,
              letterSpacing: -0.7,
              fontWeight: FontWeight.w800,
              color: Color(0xFF202938),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Yuk, pantau kondisi keuanganmu hari ini!',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7B8492),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 13),
          _buildDateChip(),
          const SizedBox(height: 19),
          _buildBalanceHero(balance),
          const SizedBox(height: 11),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 11) / 2;
              return Wrap(
                spacing: 11,
                runSpacing: 11,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _buildMetricCard(
                      title: 'Pemasukan',
                      value: formatCurrency(income),
                      color: const Color(0xFF1B9B68),
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildMetricCard(
                      title: 'Pengeluaran',
                      value: formatCurrency(expense),
                      color: const Color(0xFFE05B5B),
                      icon: Icons.trending_down_rounded,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _buildMetricCard(
                      title: 'Anggaran',
                      value: budget == null
                          ? 'Belum diatur'
                          : formatCurrency(budget.limit),
                      color: const Color(0xFFE6A13B),
                      icon: Icons.savings_rounded,
                      wide: true,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _buildFinanceChart(),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: const Color(0xFFE8ECF3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26364D).withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(17, 17, 17, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.wallet_rounded,
                        color: Color(0xFF3489D2),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Wallet',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...data.wallets.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final wallet = entry.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF4FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Color(0xFF3489D2),
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wallet.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF263142),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    formatCurrency(data.walletBalance(wallet)),
                                    style: const TextStyle(
                                      color: Color(0xFF7B8492),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index != data.wallets.length - 1)
                        const Divider(
                          height: 1,
                          indent: 55,
                          color: Color(0xFFEEF1F5),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
