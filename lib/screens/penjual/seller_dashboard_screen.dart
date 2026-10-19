import 'package:flutter/material.dart';

import 'dashboard_penjual_screen.dart';
import 'kelola_produk_screen.dart';
import 'pesanan_masuk_screen.dart';
import 'toko_saya_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  static const Color hijau = Color(0xFF006B42);
  static const Color latar = Color(0xFFF5F7F6);

  int _selectedIndex = 0;

  final List<String> _judul = [
    'Dashboard Penjual',
    'Kelola Produk',
    'Pesanan Masuk',
    'Toko Saya',
  ];

  void _pindahHalaman(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final halaman = [
      DashboardPenjualScreen(
        onKelolaProduk: () => _pindahHalaman(1),
        onPesananMasuk: () => _pindahHalaman(2),
      ),
      const KelolaProdukScreen(),
      const PesananMasukScreen(),
      const TokoSayaScreen(),
    ];

    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        backgroundColor: hijau,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _judul[_selectedIndex],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: halaman),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _pindahHalaman,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: hijau,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Toko Saya',
          ),
        ],
      ),
    );
  }
}
