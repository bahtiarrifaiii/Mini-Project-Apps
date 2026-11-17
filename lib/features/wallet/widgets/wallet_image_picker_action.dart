import 'package:flutter/material.dart';

class WalletImagePickerAction extends StatelessWidget {
  final bool hasImage;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const WalletImagePickerAction({
    super.key,
    required this.hasImage,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Pilih warna atau gunakan gambar dari galeri',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Pilih dari Galeri'),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Hapus gambar',
                onPressed: onRemoveImage,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
