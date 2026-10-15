import 'package:flutter/material.dart';

class PesananMasukScreen extends StatelessWidget {
  const PesananMasukScreen({super.key});

  static const Color hijau = Color(0xFF006B42);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Pesanan Pembeli',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pantau pesanan yang masuk ke toko kamu.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _labelStatus('Semua'),
            _labelStatus('Baru'),
            _labelStatus('Diproses'),
            _labelStatus('Selesai'),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 56,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Pesanan',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pesanan dari pembeli akan muncul di halaman ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _labelStatus(String judul) {
    return Chip(
      label: Text(judul),
      backgroundColor: const Color(0xFFE0F2E9),
      side: BorderSide.none,
      labelStyle: const TextStyle(color: hijau, fontSize: 12),
    );
  }
}
