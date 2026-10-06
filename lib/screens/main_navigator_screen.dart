import 'package:flutter/material.dart';

// Import semua halaman yang akan dituju saat icon diklik
import 'home_screen.dart'; // Sesuaikan nama file halaman Home Anda
import 'cart_screen.dart'; // Halaman Keranjang
import 'akun_screen.dart'; // Halaman Akun/Profil (buat placeholder jika belum ada)

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  // Daftar halaman yang dihubungkan dengan posisi icon (0: Home, 1: Kategori, 2: Keranjang, 3: Akun)
  final List<Widget> _screens = [
    const HomeScreen(),
    const KategoriScreenPlaceholder(), // Ganti dengan widget Kategori Anda
    const CartScreen(), // Memanggil Halaman Keranjang
    const AkunScreen(), // Ganti dengan widget Akun Anda
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menampilkan halaman sesuai index yang aktif
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF006B42),
        unselectedItemColor: Colors.black54,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

// Widget Sementara (Placeholder) untuk Kategori jika belum buat filenya
class KategoriScreenPlaceholder extends StatelessWidget {
  const KategoriScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Halaman Kategori')),
    );
  }
}

// Widget Sementara (Placeholder) untuk Akun jika belum buat filenya
class AkunScreenPlaceholder extends StatelessWidget {
  const AkunScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Halaman Akun')),
    );
  }
}