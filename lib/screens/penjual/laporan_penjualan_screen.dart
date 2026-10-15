import 'package:flutter/material.dart';

class LaporanPenjualanScreen extends StatelessWidget {
  const LaporanPenjualanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: const Color(0xFF006B42),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Laporan penjualan akan ditampilkan berdasarkan '
            'data pesanan yang tersimpan.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
