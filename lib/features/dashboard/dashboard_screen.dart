import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/utils/currency_formatter.dart';
import '../../data/cash_flow_data.dart';
import '../../models/wallet.dart';
import '../wallet/wallet_editor_sheet.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_metric_card.dart';
import 'widgets/finance_chart_card.dart';
import 'widgets/select_asset_sheet.dart';
import 'widgets/total_asset_header.dart';
import 'widgets/wallet_carousel.dart';
import 'widgets/wallet_detail_sheet.dart';

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
  bool _hideBalance = false;
  late final PageController _walletPageController;
  int _activeWalletIndex = 0;

  CashFlowData get data => widget.data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = DateTime.now();
    _walletPageController = PageController(viewportFraction: 0.88);
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
    _walletPageController.dispose();
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

  void _openSelectAssetSheet() {
    SelectAssetSheet.show(
      context,
      data: data,
      activeWalletIndex: _activeWalletIndex,
      onSelectWallet: (index) {
        setState(() => _activeWalletIndex = index);
        _walletPageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      onAddWallet: _showAddWalletSheet,
      onEditWallet: _editWallet,
      onDeleteWallet: _confirmDeleteWallet,
    );
  }

  void _openWalletDetail(Wallet wallet) {
    final transactions = data.transactions
        .where((t) => t.walletId == wallet.id)
        .toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));

    WalletDetailSheet.show(
      context,
      wallet: wallet,
      balance: data.walletBalance(wallet),
      transactions: transactions,
    );
  }

  Future<void> _showAddWalletSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WalletEditorSheet(data: data),
    );
    if (mounted) setState(() {});
  }

  Future<void> _editWallet(Wallet wallet) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WalletEditorSheet(data: data, wallet: wallet),
    );
    if (mounted) setState(() {});
  }

  Future<void> _confirmDeleteWallet(Wallet wallet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Hapus Wallet?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus wallet "${wallet.name}"?\nSemua transaksi terkait wallet ini juga akan terhapus.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      data.deleteWallet(wallet.id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final income = data.totalIncomeThisMonth();
    final expense = data.totalExpenseThisMonth();
    final balance = data.totalBalance();

    if (_activeWalletIndex >= data.wallets.length && data.wallets.isNotEmpty) {
      _activeWalletIndex = data.wallets.length - 1;
    }

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async => data.refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 18, 24),
          children: [
            DashboardHeader(
              greeting: _greeting,
              formattedToday: _formattedToday,
            ),
            const SizedBox(height: 18),
            TotalAssetHeader(
              totalBalance: balance,
              walletCount: data.wallets.length,
              hideBalance: _hideBalance,
              onTap: _openSelectAssetSheet,
            ),
            const SizedBox(height: 14),
            WalletCarousel(
              wallets: data.wallets,
              getWalletBalance: data.walletBalance,
              pageController: _walletPageController,
              activeWalletIndex: _activeWalletIndex,
              hideBalance: _hideBalance,
              onPageChanged: (index) =>
                  setState(() => _activeWalletIndex = index),
              onEditWallet: _editWallet,
              onToggleHideBalance: () =>
                  setState(() => _hideBalance = !_hideBalance),
              onSeeDetail: _openWalletDetail,
              onAddWallet: _showAddWalletSheet,
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 11) / 2;
                return Wrap(
                  spacing: 11,
                  runSpacing: 11,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: DashboardMetricCard(
                        title: 'Pemasukan',
                        value: formatCurrency(income),
                        color: const Color(0xFF1B9B68),
                        icon: Icons.trending_up_rounded,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: DashboardMetricCard(
                        title: 'Pengeluaran',
                        value: formatCurrency(expense),
                        color: const Color(0xFFE05B5B),
                        icon: Icons.trending_down_rounded,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            FinanceChartCard(data: data, now: _now),
          ],
        ),
      ),
    );
  }
}
