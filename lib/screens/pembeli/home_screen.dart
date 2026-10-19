import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'detail_produk_screen.dart';
import 'cart_screen.dart';
import 'akun_screen.dart';
import 'kategori_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xFF006B42);
  final Color backgroundColor = const Color(0xFFF5F7F6);

  int _selectedIndex = 0;

  String _namaUser = 'Pengguna';
  String _emailUser = '';

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  late Future<List<Map<String, String>>> _produkFuture;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Makanan', 'icon': Icons.fastfood_outlined},
    {'name': 'Minuman', 'icon': Icons.local_cafe_outlined},
    {'name': 'Kerajinan', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Fashion', 'icon': Icons.checkroom_outlined},
    {'name': 'Lainnya', 'icon': Icons.category_outlined},
  ];

  @override
  void initState() {
    super.initState();

    _getNamaUser();
    _produkFuture = _getProdukTersedia();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // MENGAMBIL PROFIL PEMBELI
  // =====================================================

  Future<void> _getNamaUser() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final response = await supabase
          .from('profiles')
          .select('nama, email')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted || response == null) return;

      setState(() {
        _namaUser = response['nama']?.toString() ?? 'Pengguna';

        _emailUser = response['email']?.toString() ?? user.email ?? '';
      });
    } catch (e) {
      debugPrint('Gagal mengambil profil: $e');
    }
  }

  // =====================================================
  // MENGAMBIL PRODUK DARI SUPABASE
  // =====================================================

  Future<List<Map<String, String>>> _getProdukTersedia() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('products')
        .select('''
        id,
        seller_id,
        nama_produk,
        kategori,
        harga,
        stok,
        deskripsi,
        foto_url,
        varian,
        created_at
      ''')
        .gt('stok', 0)
        .order('created_at', ascending: false);

    debugPrint('JUMLAH PRODUK DARI SUPABASE: ${response.length}');
    debugPrint('DATA PRODUK: $response');

    final List<Map<String, String>> hasil = [];

    for (final item in response) {
      final produk = Map<String, dynamic>.from(item);

      final namaProduk = produk['nama_produk']?.toString() ?? '';
      final harga = produk['harga']?.toString() ?? '0';
      final hargaAngka = double.tryParse(harga)?.toInt() ?? 0;

      final hargaFormat = hargaAngka.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );

      final foto = produk['foto_url']?.toString() ?? '';

      hasil.add({
        'id': produk['id']?.toString() ?? '',
        'seller_id': produk['seller_id']?.toString() ?? '',
        'nama_produk': namaProduk,
        'kategori': produk['kategori']?.toString() ?? '',
        'harga': harga,
        'stok': produk['stok']?.toString() ?? '0',
        'deskripsi': produk['deskripsi']?.toString() ?? '',
        'foto_url': foto,
        'varian': produk['varian']?.toString() ?? '',
        'created_at': produk['created_at']?.toString() ?? '',
        'name': namaProduk,
        'price': 'Rp$hargaFormat',
        'image': foto,
      });
    }

    return hasil;
  }

  // =====================================================
  // REFRESH PRODUK
  // =====================================================

  Future<void> _refreshProduk() async {
    final futureBaru = _getProdukTersedia();

    setState(() {
      _produkFuture = futureBaru;
    });

    await futureBaru;
  }

  // =====================================================
  // NAVIGASI BAWAH
  // =====================================================

  void _onBottomNavigationTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => KategoriMenuScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartScreen()),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // =====================================================
  // MEMBUKA KATEGORI
  // =====================================================

  void _openCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KategoriMenuScreen()),
    );
  }

  // =====================================================
  // KONTEN BERANDA
  // =====================================================

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _refreshProduk,
      color: primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat datang,',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hi, $_namaUser',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Temukan produk UMKM favoritmu',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 28,
                    color: primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // PENCARIAN
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari Produk',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // KATEGORI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kategori',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => _onBottomNavigationTap(1),
                  child: Text(
                    'Lihat semua',
                    style: TextStyle(color: primaryColor, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 94,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return GestureDetector(
                    onTap: () {
                      _openCategory(category['name'].toString());
                    },
                    child: Container(
                      width: 76,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              category['icon'] as IconData,
                              color: primaryColor,
                              size: 25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['name'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            // JUDUL PRODUK
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Produk Terbaru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Icon(Icons.storefront_outlined, color: primaryColor),
              ],
            ),

            const SizedBox(height: 14),

            // DAFTAR PRODUK DARI SUPABASE
            FutureBuilder<List<Map<String, String>>>(
              future: _produkFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 36,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Gagal memuat produk',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _produkFuture = _getProdukTersedia();
                            });
                          },
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final semuaProduk = snapshot.data ?? [];

                final produkTampil = semuaProduk.where((produk) {
                  final nama = (produk['name'] ?? '').toLowerCase();

                  final kategori = (produk['kategori'] ?? '').toLowerCase();

                  return nama.contains(_searchQuery) ||
                      kategori.contains(_searchQuery);
                }).toList();

                if (produkTampil.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 44,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Produk tidak ditemukan'
                              : 'Belum ada produk tersedia',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Produk dari penjual yang disetujui '
                          'admin akan ditampilkan di sini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: produkTampil.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.64,
                  ),
                  itemBuilder: (context, index) {
                    final item = produkTampil[index];

                    final imageUrl = item['image'] ?? '';
                    final namaProduk = item['name'] ?? '';
                    final hargaProduk = item['price'] ?? 'Rp0';

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailProductScreen(product: item),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey.shade100,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 42,
                                                  color: Colors.grey.shade400,
                                                ),
                                              );
                                            },
                                      )
                                    : Container(
                                        color: Colors.grey.shade100,
                                        child: Icon(
                                          Icons.image_outlined,
                                          size: 42,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    namaProduk,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    hargaProduk,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Stok ${item['stok'] ?? '0'}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // TAMPILAN UTAMA
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _selectedIndex == 3
            ? AkunScreen(
                nama: _namaUser,
                email: _emailUser,
                showScaffold: false,
                onProfileUpdated: _getNamaUser,
              )
            : _buildHomeContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavigationTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
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
