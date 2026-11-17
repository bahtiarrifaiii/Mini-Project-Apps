import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/transaction_type.dart';
import '../../../models/category.dart';

class TransactionFilters extends StatelessWidget {
  final TransactionType? typeFilter;
  final ValueChanged<TransactionType?> onTypeFilterChanged;
  final String timeFilter;
  final ValueChanged<String> onTimeFilterChanged;
  final DateTimeRange? selectedRange;
  final ValueChanged<DateTimeRange?> onRangeChanged;
  final String? categoryFilter;
  final ValueChanged<String?> onCategoryFilterChanged;
  final List<Category> categories;
  final String monthLabel;

  const TransactionFilters({
    super.key,
    required this.typeFilter,
    required this.onTypeFilterChanged,
    required this.timeFilter,
    required this.onTimeFilterChanged,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.categoryFilter,
    required this.onCategoryFilterChanged,
    required this.categories,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTypeFilters(),
        _buildTimeFilter(context),
        _buildCategoryFilter(),
      ],
    );
  }

  Widget _buildTypeFilters() {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _typeChip('Semua', null),
          const SizedBox(width: 8),
          _typeChip('Pemasukan', TransactionType.income),
          const SizedBox(width: 8),
          _typeChip('Pengeluaran', TransactionType.expense),
        ],
      ),
    );
  }

  Widget _typeChip(String label, TransactionType? type) {
    final selected = typeFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTypeFilterChanged(type),
    );
  }

  Widget _buildTimeFilter(BuildContext context) {
    final label = timeFilter == 'month'
        ? 'Bulan ini ($monthLabel)'
        : timeFilter == 'range'
            ? 'Pilih rentang waktu'
            : 'Semua bulan';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter waktu',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          PopupMenuButton<String>(
            onSelected: onTimeFilterChanged,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('Semua bulan')),
              PopupMenuItem(value: 'month', child: Text('Bulan ini')),
              PopupMenuItem(
                value: 'range',
                child: Text('Pilih rentang waktu...'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF202124),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 19),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
          if (timeFilter == 'range') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _rangeDateField(
                    label: 'Dari',
                    date: selectedRange?.start,
                    onTap: () => _pickRangeDate(context, isStart: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _rangeDateField(
                    label: 'Sampai',
                    date: selectedRange?.end,
                    onTap: () => _pickRangeDate(context, isStart: false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _rangeDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white60)),
        const SizedBox(height: 5),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF202124),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date == null
                        ? 'Pilih tanggal'
                        : DateFormat('d MMM yyyy', 'id_ID').format(date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickRangeDate(BuildContext context,
      {required bool isStart}) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final currentStart = selectedRange?.start;
    final currentEnd = selectedRange?.end;
    final initial = isStart
        ? (currentStart ?? currentEnd ?? today)
        : (currentEnd ?? currentStart ?? today);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(today) ? today : initial,
      firstDate: DateTime(2000),
      lastDate: today,
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih tanggal akhir',
    );
    if (picked == null) return;

    if (isStart) {
      final end = currentEnd != null && currentEnd.isBefore(picked)
          ? picked
          : currentEnd ?? picked;
      onRangeChanged(DateTimeRange(start: picked, end: end));
    } else {
      final start = currentStart ?? picked;
      if (picked.isBefore(start)) {
        onRangeChanged(DateTimeRange(start: picked, end: start));
      } else {
        onRangeChanged(DateTimeRange(start: start, end: picked));
      }
    }
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter kategori',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _categoryChip('Semua kategori', null),
                ...categories.map((category) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _categoryChip(category.name, category.id),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String? id) {
    return ChoiceChip(
      label: Text(label),
      selected: categoryFilter == id,
      onSelected: (_) => onCategoryFilterChanged(id),
    );
  }
}
