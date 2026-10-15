import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Penjual UMKM',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
      ),
      home: const SellerDashboardScreen(),
    );
  }
}

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
              Icon(Icons.storefront_outlined, color: Colors.white, size: 38),
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
                style: TextStyle(color: Colors.white, fontSize: 13),
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
              MaterialPageRoute(builder: (_) => const LaporanPenjualanScreen()),
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
              MaterialPageRoute(builder: (_) => const PengaturanAkunScreen()),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TambahProdukScreen()),
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

        _kartuKosong(
          ikon: Icons.shopping_bag_outlined,
          judul: 'Belum Ada Pesanan',
          deskripsi: 'Pesanan dari pembeli akan muncul di halaman ini.',
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
                child: Icon(Icons.storefront, size: 40, color: hijau),
              ),
              SizedBox(height: 12),
              Text(
                'Toko UMKM Saya',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 6),
              Text(
                'Lengkapi informasi toko kamu.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
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
              MaterialPageRoute(builder: (_) => const LaporanPenjualanScreen()),
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
              MaterialPageRoute(builder: (_) => const PengaturanAkunScreen()),
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
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(judul, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(deskripsi, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            deskripsi,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
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
      labelStyle: const TextStyle(color: hijau, fontSize: 12),
    );
  }

  void _pesan(String isi) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isi)));
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
                _pesan('Hubungkan tombol ini ke Supabase Auth untuk logout.');
              },
              child: const Text('Keluar', style: TextStyle(color: hijau)),
            ),
          ],
        );
      },
    );
  }
}

// =======================================================
// HALAMAN TAMBAH PRODUK
// =======================================================

class TambahProdukScreen extends StatefulWidget {
  const TambahProdukScreen({super.key});

  @override
  State<TambahProdukScreen> createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  static const Color primaryColor = Color(0xFF006B42);

  // List untuk menyimpan varian produk yang ditambahkan
  final List<String> _daftarVarian = [];
  final TextEditingController _controllerVarian = TextEditingController();

  // Method untuk menampilkan dialog tambah varian
  void _tambahVarianDialog() {
    _controllerVarian.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Varian Produk'),
          content: TextField(
            controller: _controllerVarian,
            decoration: const InputDecoration(
              hintText: 'Contoh: Ukuran L / Warna Merah',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                if (_controllerVarian.text.trim().isNotEmpty) {
                  setState(() {
                    _daftarVarian.add(_controllerVarian.text.trim());
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Tambah',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Produk',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kotak Tambah Foto
            Center(
              child: Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.4),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: primaryColor,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tambah Foto',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '(1-5 foto)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nama Produk
            const Text(
              'Nama Produk',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Contoh: Kopi Arabika',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kategori (Pilihan: Makanan, Minuman, Kerajinan, Fashion, Lainnya)
            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              hint: Text(
                'Pilih Kategori',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              items: ['Makanan', 'Minuman', 'Kerajinan', 'Fashion', 'Lainnya']
                  .map(
                    (kategori) => DropdownMenuItem(
                      value: kategori,
                      child: Text(kategori),
                    ),
                  )
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),

            // Harga dan Stok (Row)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Harga',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Rp 0',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stok',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Deskripsi
            const Text(
              'Deskripsi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis deskripsi produk...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Varian (Opsional) & Tombol Tambah Varian
            Row(
              children: const [
                Text(
                  'Varian',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(width: 6),
                Text(
                  '(opsional)',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Daftar Varian yang telah ditambahkan
            if (_daftarVarian.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: _daftarVarian.map((varian) {
                  return Chip(
                    label: Text(varian),
                    backgroundColor: const Color(0xFFE0F2E9),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _daftarVarian.remove(varian);
                      });
                    },
                    labelStyle: const TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            InkWell(
              onTap: _tambahVarianDialog,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: primaryColor, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Tambah Varian',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Simpan Produk
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Simpan Produk',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
