
import 'package:flutter/material.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() =>
      _SellerDashboardScreenState();
}

class _SellerDashboardScreenState
    extends State<SellerDashboardScreen> {
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
    final List<Widget> halaman = [
      _dashboard(),
      _produk(),
      _pesanan(),
      _tokoSaya(),
    ];

    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        backgroundColor: hijau,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _judul[_selectedIndex],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: halaman,
        ),
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

  // =====================================================
  // DASHBOARD
  // =====================================================

  Widget _dashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: hijau,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.storefront_outlined,
                color: Colors.white,
                size: 38,
              ),
              SizedBox(height: 12),
              Text(
                'Selamat Datang, Penjual!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Kelola produk dan pesanan UMKM kamu '
                'dalam satu tempat.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _judulBagian('Ringkasan Toko'),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _kartuRingkasan(
                ikon: Icons.inventory_2_outlined,
                judul: 'Total Produk',
                nilai: '0',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _kartuRingkasan(
                ikon: Icons.shopping_bag_outlined,
                judul: 'Pesanan Baru',
                nilai: '0',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _kartuRingkasan(
                ikon: Icons.check_circle_outline,
                judul: 'Selesai',
                nilai: '0',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _kartuRingkasan(
                ikon: Icons.payments_outlined,
                judul: 'Penjualan',
                nilai: 'Rp0',
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        _judulBagian('Menu Pengelolaan'),

        const SizedBox(height: 12),

        _kartuMenu(
          ikon: Icons.add_box_outlined,
          judul: 'Kelola Produk',
          deskripsi: 'Tambah dan atur produk UMKM',
          aksi: () => _pindahHalaman(1),
        ),

        _kartuMenu(
          ikon: Icons.receipt_long_outlined,
          judul: 'Pesanan Masuk',
          deskripsi: 'Lihat pesanan dari pembeli',
          aksi: () => _pindahHalaman(2),
        ),

        _kartuMenu(
          ikon: Icons.bar_chart_outlined,
          judul: 'Laporan Penjualan',
          deskripsi: 'Lihat rekap transaksi dan produk terjual',
          aksi: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LaporanPenjualanScreen(),
              ),
            );
          },
        ),

        _kartuMenu(
          ikon: Icons.store_outlined,
          judul: 'Profil Toko',
          deskripsi: 'Atur informasi usaha kamu',
          aksi: () => _pindahHalaman(3),
        ),

        _kartuMenu(
          ikon: Icons.settings_outlined,
          judul: 'Pengaturan Akun',
          deskripsi: 'Kelola akun dan keamanan',
          aksi: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PengaturanAkunScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // =====================================================
  // PRODUK
  // =====================================================

  Widget _produk() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Produk Saya',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push( 
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TambahProdukScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hijau,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Text(
          'Kelola produk yang ditampilkan kepada pembeli.',
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 24),

        _kartuKosong(
          ikon: Icons.inventory_2_outlined,
          judul: 'Belum Ada Produk',
          deskripsi:
              'Tambahkan produk UMKM agar dapat ditampilkan '
              'di katalog pembeli.',
        ),
      ],
    );
  }

  // =====================================================
  // PESANAN
  // =====================================================

  Widget _pesanan() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Pesanan Pembeli',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
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

        _kartuKosong(
          ikon: Icons.shopping_bag_outlined,
          judul: 'Belum Ada Pesanan',
          deskripsi:
              'Pesanan dari pembeli akan muncul di halaman ini.',
        ),
      ],
    );
  }

  // =====================================================
  // TOKO SAYA
  // =====================================================

  Widget _tokoSaya() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xFFE0F2E9),
                child: Icon(
                  Icons.storefront,
                  size: 40,
                  color: hijau,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Toko UMKM Saya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Lengkapi informasi toko kamu.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _kartuMenu(
          ikon: Icons.store_outlined,
          judul: 'Informasi Toko',
          deskripsi: 'Nama, deskripsi, dan alamat toko',
          aksi: () {
            _pesan('Form informasi toko akan dibuat berikutnya.');
          },
        ),

        _kartuMenu(
          ikon: Icons.phone_outlined,
          judul: 'Nomor WhatsApp',
          deskripsi: 'Kontak yang dapat dihubungi pembeli',
          aksi: () {
            _pesan('Pengaturan WhatsApp akan dibuat berikutnya.');
          },
        ),

        _kartuMenu(
          ikon: Icons.bar_chart_outlined,
          judul: 'Laporan Penjualan',
          deskripsi: 'Lihat ringkasan hasil penjualan',
          aksi: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LaporanPenjualanScreen(),
              ),
            );
          },
        ),

        _kartuMenu(
          ikon: Icons.settings_outlined,
          judul: 'Pengaturan Akun',
          deskripsi: 'Keamanan dan pengaturan akun',
          aksi: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PengaturanAkunScreen(),
              ),
            );
          },
        ),

        _kartuMenu(
          ikon: Icons.logout,
          judul: 'Keluar',
          deskripsi: 'Keluar dari akun penjual',
          aksi: _konfirmasiKeluar,
        ),
      ],
    );
  }

  // =====================================================
  // WIDGET PENDUKUNG
  // =====================================================

  Widget _judulBagian(String judul) {
    return Text(
      judul,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _kartuRingkasan({
    required IconData ikon,
    required String judul,
    required String nilai,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: hijau, size: 26),
          const SizedBox(height: 12),
          Text(
            nilai,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            judul,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuMenu({
    required IconData ikon,
    required String judul,
    required String deskripsi,
    required VoidCallback aksi,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE7ECE8)),
      ),
      child: ListTile(
        onTap: aksi,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0F2E9),
          child: Icon(ikon, color: hijau),
        ),
        title: Text(
          judul,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          deskripsi,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _kartuKosong({
    required IconData ikon,
    required String judul,
    required String deskripsi,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(ikon, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            judul,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            deskripsi,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelStatus(String judul) {
    return Chip(
      label: Text(judul),
      backgroundColor: const Color(0xFFE0F2E9),
      side: BorderSide.none,
      labelStyle: const TextStyle(
        color: hijau,
        fontSize: 12,
      ),
    );
  }

  void _pesan(String isi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isi)),
    );
  }

  void _konfirmasiKeluar() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun penjual?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                _pesan(
                  'Hubungkan tombol ini ke Supabase Auth untuk logout.',
                );
              },
              child: const Text(
                'Keluar',
                style: TextStyle(color: hijau),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =======================================================
// HALAMAN TAMBAH PRODUK (TAMPILAN AWAL)
// =======================================================

class TambahProdukScreen extends StatelessWidget {
  const TambahProdukScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        backgroundColor: const Color(0xFF006B42),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Form tambah produk akan dibuat pada tahap berikutnya.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// =======================================================
// HALAMAN LAPORAN PENJUALAN
// =======================================================

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

// =======================================================
// HALAMAN PENGATURAN AKUN
// =======================================================

class PengaturanAkunScreen extends StatelessWidget {
  const PengaturanAkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        backgroundColor: const Color(0xFF006B42),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Data Diri'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Keamanan Akun'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifikasi'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
