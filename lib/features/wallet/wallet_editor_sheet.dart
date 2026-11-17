import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/enums/transaction_type.dart';
import '../../data/cash_flow_data.dart';
import '../../models/transaction.dart';
import '../../models/wallet.dart';
import 'widgets/wallet_card_preview.dart';
import 'widgets/wallet_color_picker.dart';
import 'widgets/wallet_image_picker_action.dart';

class WalletEditorSheet extends StatefulWidget {
  final CashFlowData data;
  final Wallet? wallet;

  const WalletEditorSheet({super.key, required this.data, this.wallet});

  @override
  State<WalletEditorSheet> createState() => _WalletEditorSheetState();
}

class _WalletEditorSheetState extends State<WalletEditorSheet> {
  late final TextEditingController nameController;
  late final TextEditingController balanceController;
  late int selectedThemeColor;
  String? selectedThemeImageBase64;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.wallet?.name ?? '');
    balanceController = TextEditingController(text: '0');
    selectedThemeColor = widget.wallet?.themeColor ?? defaultWalletThemeColor;
    selectedThemeImageBase64 = widget.wallet?.themeImageBase64;
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewBalance = widget.wallet == null
        ? (double.tryParse(
                balanceController.text.trim().replaceAll(',', '.'),
              ) ??
              0)
        : widget.data.walletBalance(widget.wallet!);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                widget.wallet == null ? 'Tambah Wallet' : 'Ubah Wallet',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Nama wallet'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tema & Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              WalletCardPreview(
                themeColor: selectedThemeColor,
                themeImageBase64: selectedThemeImageBase64,
                walletName: nameController.text,
                balance: previewBalance,
              ),
              WalletImagePickerAction(
                hasImage: selectedThemeImageBase64 != null,
                onPickImage: _pickThemeImage,
                onRemoveImage: () => setState(() {
                  selectedThemeImageBase64 = null;
                }),
              ),
              const SizedBox(height: 12),
              WalletColorPicker(
                selectedThemeColor: selectedThemeColor,
                isCustomImageActive: selectedThemeImageBase64 != null,
                onColorSelected: (color) => setState(() {
                  selectedThemeColor = color;
                  selectedThemeImageBase64 = null;
                }),
              ),
              if (widget.wallet == null) ...[
                const SizedBox(height: 18),
                TextField(
                  controller: balanceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Saldo awal (opsional)',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveWallet,
                  child: Text(
                    widget.wallet == null ? 'Simpan' : 'Simpan Perubahan',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickThemeImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1400,
        maxHeight: 1000,
        imageQuality: 80,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        selectedThemeImageBase64 = base64Encode(bytes);
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Tidak dapat membuka gambar dari galeri.',
          ),
        ),
      );
    }
  }

  void _saveWallet() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama wallet tidak boleh kosong.')),
      );
      return;
    }

    final existingWallet = widget.wallet;
    if (existingWallet != null) {
      widget.data.updateWallet(
        existingWallet.id,
        name,
        themeColor: selectedThemeColor,
        themeImageBase64: selectedThemeImageBase64,
        clearThemeImage: selectedThemeImageBase64 == null,
      );
      Navigator.pop(context);
      return;
    }

    final balance =
        double.tryParse(balanceController.text.trim().replaceAll(',', '.')) ??
        0;
    final incomeCategories = widget.data.categoriesByType(
      TransactionType.income,
    );
    if (balance > 0 && incomeCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori pemasukan belum tersedia.')),
      );
      return;
    }

    final walletId = DateTime.now().microsecondsSinceEpoch.toString();
    widget.data.addWallet(
      Wallet(
        id: walletId,
        name: name,
        initialBalance: 0,
        themeColor: selectedThemeColor,
        themeImageBase64: selectedThemeImageBase64,
      ),
    );

    if (balance > 0) {
      widget.data.addTransaction(
        Transaction(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          walletId: walletId,
          categoryId: incomeCategories.first.id,
          type: TransactionType.income,
          amount: balance,
          date: DateTime.now(),
          description: 'Saldo awal wallet',
        ),
      );
    }
    Navigator.pop(context);
  }
}
