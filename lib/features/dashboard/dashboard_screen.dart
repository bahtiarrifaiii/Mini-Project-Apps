import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/enums/transaction_type.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/cash_flow_data.dart';
import '../../models/wallet.dart';
import '../wallet/wallet_editor_sheet.dart';
import '../wallet/wallet_theme.dart';

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
  late final PageController _walletPageController;
  int _activeWalletIndex = 0;

  CashFlowData get data => widget.data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = DateTime.now();
    _selectedChartMonth = DateTime(_now.year, _now.month, 1);
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



  Widget _buildDateChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 15, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            _formattedToday,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAssetHeader(double totalBalance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Kiri: TOTAL ASSETS > & Nilai Total Saldo
        InkWell(
          onTap: () => _showSelectAssetSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_rounded,
                      color: Color(0xFFE5A93C),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'TOTAL ASSETS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white60,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Colors.white54,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _hideBalance ? 'Rp ******' : formatCurrency(totalBalance),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Kanan: Indikator Jumlah Wallet & Tombol Grid "Select Asset"
        Row(
          children: [
            if (data.wallets.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF404040)),
                ),
                child: Text(
                  '${data.wallets.length} Wallets',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            InkWell(
              onTap: () => _showSelectAssetSheet(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF404040)),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletCarousel() {
    if (data.wallets.isEmpty) {
      return Container(
        height: 190,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF404040)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 38,
                color: Colors.white54,
              ),
              const SizedBox(height: 10),
              const Text(
                'Belum ada wallet.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _showAddWalletSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Wallet'),
              ),
            ],
          ),
        ),
      );
    }

    if (_activeWalletIndex >= data.wallets.length) {
      _activeWalletIndex = data.wallets.length - 1;
    }

    return Column(
      children: [
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: _walletPageController,
            itemCount: data.wallets.length,
            onPageChanged: (index) => setState(() => _activeWalletIndex = index),
            itemBuilder: (context, index) {
              final wallet = data.wallets[index];
              final balance = data.walletBalance(wallet);
              final isCurrent = index == _activeWalletIndex;
              final themeColor = walletColor(wallet);
              final textColor = walletTextColor(wallet);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: isCurrent ? 0 : 7,
                ),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isCurrent
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                    width: isCurrent ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const WalletBrandMark(size: 34),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 105),
                              child: Text(
                                wallet.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: textColor,
                              ),
                              onPressed: () => _editWalletName(context, wallet),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                _hideBalance
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 18,
                                color: textColor,
                              ),
                              onPressed: () =>
                                  setState(() => _hideBalance = !_hideBalance),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _hideBalance ? 'Rp ******' : formatCurrency(balance),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () => _showWalletDetailSheet(context, wallet),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'See Detail >>',
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.78),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (data.wallets.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(data.wallets.length, (index) {
              final isCurrent = index == _activeWalletIndex;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  void _showSelectAssetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final totalBalance = data.totalBalance();

            return SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Judul Sheet
                    const Center(
                      child: Text(
                        'Select Asset',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Banner Total Assets & Tombol + Add Asset
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF404040)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL ASSETS',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatCurrency(totalBalance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFDE749B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () async {
                              await _showAddWalletSheet(context);
                              setSheetState(() {});
                              if (mounted) setState(() {});
                            },
                            icon: const Icon(Icons.add, size: 17),
                            label: const Text(
                              '+ Add Asset',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header REGULAR WALLETS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'REGULAR WALLETS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white60,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          formatCurrency(totalBalance),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grid Daftar Wallet
                    if (data.wallets.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            'Belum ada wallet. Tekan "+ Add Asset" untuk menambah.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.05,
                          ),
                          itemCount: data.wallets.length,
                          itemBuilder: (context, index) {
                            final wallet = data.wallets[index];
                            final isSelected = index == _activeWalletIndex;
                            final balance = data.walletBalance(wallet);
                            final textColor = walletTextColor(wallet);

                            return InkWell(
                              onTap: () {
                                setState(() => _activeWalletIndex = index);
                                _walletPageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: walletColor(wallet),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.35),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const WalletBrandMark(size: 34),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: textColor,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          wallet.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          formatCurrency(balance),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: textColor.withValues(
                                              alpha: 0.7,
                                            ),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                            color: textColor,
                                          ),
                                          onPressed: () async {
                                            await _editWalletName(
                                                context, wallet);
                                            setSheetState(() {});
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Icon(
                                            Icons.delete_outline,
                                            size: 16,
                                            color: textColor,
                                          ),
                                          onPressed: () async {
                                            await _confirmDeleteWallet(
                                                context, wallet);
                                            setSheetState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWalletDetailSheet(BuildContext context, Wallet wallet) {
    final walletTransactions = data.transactions
        .where((t) => t.walletId == wallet.id)
        .toList();
    walletTransactions.sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(18),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallet.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          formatCurrency(data.walletBalance(wallet)),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: walletTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada transaksi di wallet ini.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: walletTransactions.length,
                          separatorBuilder: (_, _) =>
                              const Divider(color: Color(0xFF404040)),
                          itemBuilder: (context, i) {
                            final tx = walletTransactions[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor:
                                    tx.type.color.withValues(alpha: 0.15),
                                child: Icon(
                                  tx.type.icon,
                                  color: tx.type.color,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                tx.description.isEmpty
                                    ? 'Transaksi'
                                    : tx.description,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                formatDate(tx.date),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                '${tx.type == TransactionType.income ? '+' : '-'}${formatCurrency(tx.amount)}',
                                style: TextStyle(
                                  color: tx.type.color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddWalletSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WalletEditorSheet(data: data),
    );
    if (mounted) setState(() {});
  }

  Future<void> _editWalletName(BuildContext context, Wallet wallet) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WalletEditorSheet(data: data, wallet: wallet),
    );
    if (mounted) setState(() {});
  }

  Future<void> _confirmDeleteWallet(BuildContext context, Wallet wallet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Wallet?', style: TextStyle(color: Colors.white)),
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
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF404040)),
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
                    color: Colors.white70,
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
                    color: Colors.white,
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
              value: _selectedChartMonth,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                prefixIcon: const Icon(Icons.calendar_month_rounded, size: 21, color: Colors.white70),
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
                            formatAxisValue(value),
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Yuk, pantau kondisi keuanganmu hari ini!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 13),
          _buildDateChip(),
          const SizedBox(height: 18),
          _buildTotalAssetHeader(balance),
          const SizedBox(height: 14),
          _buildWalletCarousel(),
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
        ],
      ),
    );
  }
}
