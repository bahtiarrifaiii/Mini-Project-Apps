import 'package:flutter/material.dart';

import '../../core/enums/transaction_type.dart';
import '../../data/cash_flow_data.dart';
import '../../models/category.dart';

class CategoryScreen extends StatelessWidget {
  final CashFlowData data;

  const CategoryScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CategorySection(
            title: 'Pemasukan',
            categories: data.categoriesByType(TransactionType.income),
          ),
          const SizedBox(height: 16),
          _CategorySection(
            title: 'Pengeluaran',
            categories: data.categoriesByType(TransactionType.expense),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<Category> categories;

  const _CategorySection({required this.title, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ...categories.map(
              (category) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (!category.isDefault)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {},
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
