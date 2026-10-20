import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'detail_produk_screen.dart';
import 'cart_screen.dart';
import 'akun_screen.dart';
import 'kategori_screen.dart';
import 'kategori_menu_screen.dart';
import 'toko_penjual_screen.dart';

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

  // ==========================================
  // PRODUK LOKAL CADANGAN
  // ==========================================
  final List<Map<String, String>> products = [
    {
      'name': 'Tas Rajut',
      'nama_produk': 'Tas Rajut',
      'price': 'Rp17.000',
      'harga': '17000',
      'image': 'assets/tas rajut.jpeg',
      'foto_url': '',
      'seller_id': '',
      'nama_penjual': 'Penjual UMKM',
      'kategori': 'Kerajinan',
      'stok': '10',
      'deskripsi': '',
      'varian': '',
      'id': '',
    },
    {
      'name': 'Keripik Pisang',
      'nama_produk': 'Keripik Pisang',
      'price': 'Rp10.000',
      'harga': '10000',
      'image': 'assets/rojomolo.jpeg',
      'foto_url': '',
      'seller_id': '',
      'nama_penjual': 'Penjual UMKM',
      'kategori': 'Makanan',
      'stok': '10',
      'deskripsi': '',
      'varian': '',
      'id': '',
    },
    {
      'name': 'Kopi Cendana',
      'nama_produk': 'Kopi Cendana',
      'price': 'Rp25.000',
      'harga': '25000',
      'image': 'assets/kopi cendono.jpeg',
      'foto_url': '',
      'seller_id': '',
      'nama_penjual': 'Penjual UMKM',
      'kategori': 'Minuman',
      'stok': '10',
      'deskripsi': '',
      'varian': '',
      'id': '',
    },
    {
      'name': 'Stik Kelor',
      'nama_produk': 'Stik Kelor',
      'price': 'Rp12.000',
      'harga': '12000',
      'image': 'assets/tiktik daun kelor.jpeg',
      'foto_url': '',
      'seller_id': '',
      'nama_penjual': 'Penjual UMKM',
      'kategori': 'Makanan',
      'stok': '10',
      'deskripsi': '',
      'varian': '',
      'id': '',
    },
  ];

  // ==========================================
  // KATEGORI
  // ==========================================
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.restaurant, 'label': 'Makanan'},
    {'icon': Icons.local_drink, 'label': 'Minuman'},
    {'icon': Icons.brush, 'label': 'Kerajinan'},
    {'icon': Icons.shopping_bag, 'label': 'Fashion'},
    {'icon': Icons.more_horiz, 'label': 'Lainnya'},
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

  // ==========================================
  // FORMAT HARGA
  // ==========================================
  String _formatHarga(dynamic harga) {
    final int nilai = harga is num
        ? harga.toInt()
        : int.tryParse(harga?.toString() ?? '') ?? 0;

    final String angka = nilai.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp$angka';
  }

  // ==========================================
  // AMBIL DATA USER
  // ==========================================
  Future<void> _getNamaUser() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('USER BELUM LOGIN');
        return;
      }

      final data = await supabase
          .from('profiles')
          .select('id, nama, email')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (data != null) {
        setState(() {
          _namaUser = data['nama']?.toString() ?? 'Pengguna';
          _emailUser = data['email']?.toString() ?? user.email ?? '';
        });
      } else {
        setState(() {
          _emailUser = user.email ?? '';
        });
      }
    } catch (e) {
      debugPrint('ERROR AMBIL PROFILE: $e');
    }
  }

  // ==========================================
  // AMBIL PRODUK DARI SUPABASE
  // SEKALIGUS AMBIL NAMA PENJUAL
  // ==========================================
  Future<List<Map<String, String>>> _getProdukTersedia() async {
    final supabase = Supabase.instance.client;

    try {
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

      final List<Map<String, dynamic>> produkDatabase =
          List<Map<String, dynamic>>.from(response);

      if (produkDatabase.isEmpty) {
        return products;
      }

      // Kumpulkan ID penjual yang berbeda.
      final Set<String> sellerIds = produkDatabase
          .map((produk) => produk['seller_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      final Map<String, String> namaPenjualMap = {};

      // Ambil profil penjual secara terpisah agar pengambilan
      // katalog produk tidak bergantung pada nested join.
      if (sellerIds.isNotEmpty) {
        try {
          final profiles = await supabase
              .from('profiles')
              .select('id, nama, role, seller_status')
              .inFilter('id', sellerIds.toList());

          for (final profile in profiles) {
            final id = profile['id']?.toString() ?? '';
            final nama = profile['nama']?.toString() ?? '';
            final role = profile['role']?.toString() ?? '';
            final status = profile['seller_status']?.toString() ?? '';

            if (id.isNotEmpty && role == 'seller' && status == 'approved') {
              namaPenjualMap[id] = nama.isNotEmpty ? nama : 'Penjual UMKM';
            }
          }
        } catch (e) {
          debugPrint('ERROR AMBIL PROFIL PENJUAL: $e');
        }
      }

      // Gabungkan data produk dengan nama penjual.
      return produkDatabase.map((produk) {
        final sellerId = produk['seller_id']?.toString() ?? '';

        final namaProduk = produk['nama_produk']?.toString() ?? '';

        final harga = produk['harga'];
        final fotoUrl = produk['foto_url']?.toString() ?? '';

        final varian = produk['varian'];

        return <String, String>{
          'id': produk['id']?.toString() ?? '',
          'seller_id': sellerId,
          'nama_produk': namaProduk,
          'name': namaProduk,
          'kategori': produk['kategori']?.toString() ?? '',
          'harga': harga?.toString() ?? '0',
          'price': _formatHarga(harga),
          'stok': produk['stok']?.toString() ?? '0',
          'deskripsi': produk['deskripsi']?.toString() ?? '',
          'foto_url': fotoUrl,
          'image': fotoUrl,
          'varian': varian == null
              ? ''
              : varian is String
              ? varian
              : varian.toString(),
          'created_at': produk['created_at']?.toString() ?? '',
          'nama_penjual': namaPenjualMap[sellerId] ?? 'Penjual UMKM',
        };
      }).toList();
    } catch (e) {
      debugPrint('ERROR AMBIL PRODUK: $e');

      // Produk lokal tetap ditampilkan jika database gagal.
      return products;
    }
  }

  // ==========================================
  // REFRESH PRODUK
  // ==========================================
  Future<void> _refreshProduk() async {
    setState(() {
      _produkFuture = _getProdukTersedia();
    });

    await _produkFuture;
  }

  // ==========================================
  // BOTTOM NAVIGATION
  // ==========================================
  void _onBottomNavigationTap(int index) {
    // Keranjang
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
      return;
    }

    // Kategori
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => KategoriMenuScreen()),
      );
      return;
    }

    // Beranda / Akun
    setState(() {
      _selectedIndex = index;
    });
  }

  // ==========================================
  // BUKA KATEGORI
  // ==========================================
  void _openCategory(String kategori) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KategoriScreen(kategori: kategori),
      ),
    );
  }

  // ==========================================
  // BUKA DETAIL PRODUK
  // ==========================================
  void _openDetail(Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailProductScreen(product: item),
      ),
    );
  }

  // ==========================================
  // BUKA TOKO PENJUAL
  // ==========================================
  void _openToko(String sellerId, String namaPenjual) {
    if (sellerId.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TokoPenjualScreen(sellerId: sellerId, namaPenjual: namaPenjual),
      ),
    );
  }

  // ==========================================
  // GAMBAR PRODUK
  // ==========================================
  Widget _buildProductImage(Map<String, String> item) {
    final imageUrl = item['foto_url'] ?? '';
    final imagePath = item['image'] ?? '';

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _gambarKosong();
        },
      );
    }

    if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _gambarKosong();
        },
      );
    }

    return _gambarKosong();
  }

  Widget _gambarKosong() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 35,
      ),
    );
  }

  // ==========================================
  // KARTU PRODUK
  // ==========================================
  Widget _buildProductCard(Map<String, String> item) {
    final name = item['name'] ?? '';
    final price = item['price'] ?? '';
    final sellerId = item['seller_id'] ?? '';
    final namaPenjual = item['nama_penjual'] ?? 'Penjual UMKM';

    return GestureDetector(
      onTap: () {
        _openDetail(item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: _buildProductImage(item),
              ),
            ),

            // INFORMASI PRODUK
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // NAMA PENJUAL
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 13,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          namaPenjual,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // TOMBOL LIHAT TOKO
                  if (sellerId.isNotEmpty)
                    InkWell(
                      onTap: () {
                        _openToko(sellerId, namaPenjual);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          'Lihat Toko →',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HALAMAN BERANDA
  // ==========================================
  Widget _buildHomeContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshProduk,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $_namaUser',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Temukan produk UMKM\nterbaik di sini',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFE8F5EF),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF006B42),
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SEARCH
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari Produk',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // KATEGORI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: categories.map((cat) {
                  final String categoryName = cat['label']?.toString() ?? '';

                  return GestureDetector(
                    onTap: () {
                      _openCategory(categoryName);
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: primaryColor,
                          child: Icon(
                            cat['icon'] as IconData? ?? Icons.category,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          categoryName,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // JUDUL PRODUK
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Produk Terbaru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: _refreshProduk,
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // GRID PRODUK
              FutureBuilder<List<Map<String, String>>>(
                future: _produkFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text('Produk belum dapat dimuat.'),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _refreshProduk,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final semuaProduk = snapshot.data ?? products;

                  final hasilPencarian = semuaProduk.where((item) {
                    final nama = (item['name'] ?? '').toLowerCase();
                    final kategori = (item['kategori'] ?? '').toLowerCase();
                    final penjual = (item['nama_penjual'] ?? '').toLowerCase();

                    return nama.contains(_searchQuery) ||
                        kategori.contains(_searchQuery) ||
                        penjual.contains(_searchQuery);
                  }).toList();

                  if (hasilPencarian.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Produk tidak ditemukan.'),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hasilPencarian.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.62,
                        ),
                    itemBuilder: (context, index) {
                      final item = hasilPencarian[index];
                      return _buildProductCard(item);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: _selectedIndex == 3
          ? AkunScreen(
              nama: _namaUser,
              email: _emailUser,
              showScaffold: false,
              onProfileUpdated: _getNamaUser,
            )
          : _buildHomeContent(),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavigationTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
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
