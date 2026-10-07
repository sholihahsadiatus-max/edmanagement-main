import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'detail_produk_screen.dart';
import 'cart_screen.dart';
import 'akun_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xFF006B42);

  int _selectedIndex = 0;

  String _namaUser = 'Pengguna';
  String _emailUser = '';

  // =========================
  // AMBIL DATA USER
  // =========================
  Future<void> _getNamaUser() async {
    try {
      final supabase = Supabase.instance.client;

      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('USER BELUM LOGIN');
        return;
      }

      debugPrint('USER ID LOGIN: ${user.id}');
      debugPrint('EMAIL LOGIN: ${user.email}');

      final data = await supabase
          .from('profiles')
          .select('id, nama, email')
          .eq('id', user.id)
          .maybeSingle();

      debugPrint('PROFILE: $data');

      if (data != null && mounted) {
        setState(() {
          _namaUser = data['nama']?.toString() ?? 'Pengguna';

          _emailUser =
              data['email']?.toString() ??
              user.email ??
              '';
        });

        debugPrint('NAMA YANG DITAMPILKAN: $_namaUser');
        debugPrint('EMAIL YANG DITAMPILKAN: $_emailUser');
      } else {
        debugPrint('PROFILE TIDAK DITEMUKAN');

        if (mounted) {
          setState(() {
            _emailUser = user.email ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('ERROR AMBIL PROFILE: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    _getNamaUser();
  }

  // =========================
  // KATEGORI
  // =========================
  final List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.restaurant,
      'label': 'Makanan',
    },
    {
      'icon': Icons.local_drink,
      'label': 'Minuman',
    },
    {
      'icon': Icons.brush,
      'label': 'Kerajinan',
    },
    {
      'icon': Icons.shopping_bag,
      'label': 'Fashion',
    },
    {
      'icon': Icons.more_horiz,
      'label': 'Lainnya',
    },
  ];

  // =========================
  // PRODUK
  // =========================
  final List<Map<String, String>> products = [
    {
      'name': 'Tas Rajut',
      'price': 'Rp17.000',
      'image': 'assets/tas rajut.jpeg',
    },
    {
      'name': 'Keripik Pisang',
      'price': 'Rp10.000',
      'image': 'assets/rojomolo.jpeg',
    },
    {
      'name': 'Kopi Cendana',
      'price': 'Rp25.000',
      'image': 'assets/kopi cendono.jpeg',
    },
    {
      'name': 'Stik Kelor',
      'price': 'Rp12.000',
      'image': 'assets/tiktik daun kelor.jpeg',
    },
  ];

  // =========================
  // BOTTOM NAVIGATION
  // =========================
  void _onBottomNavigationTap(int index) {
    // Keranjang tetap membuka CartScreen
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CartScreen(),
        ),
      );

      return;
    }

    // Kategori sementara
    if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu Kategori'),
        ),
      );

      return;
    }

    // Beranda / Akun
    setState(() {
      _selectedIndex = index;
    });
  }

  // =========================
  // HALAMAN BERANDA
  // =========================
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // HEADER
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
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

            // =========================
            // SEARCH
            // =========================
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari Produk',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // KATEGORI
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: categories.map((cat) {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: primaryColor,
                      child: Icon(
                        cat['icon'] as IconData? ??
                            Icons.category,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      cat['label']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // =========================
            // PRODUK TERBARU
            // =========================
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Produk Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                GestureDetector(
                  onTap: () {},
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

            // =========================
            // GRID PRODUK
            // =========================
            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final item = products[index];

                final imagePath =
                    item['image'] ?? '';

                final name =
                    item['name'] ?? '';

                final price =
                    item['price'] ?? '';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailProductScreen(
                          product: item,
                        ),
                      ),
                    );
                  },

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(16),

                          child: imagePath.isNotEmpty
                              ? Image.asset(
                                  imagePath,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return Container(
                                      color:
                                          Colors.grey.shade300,
                                      child: const Icon(
                                        Icons
                                            .image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color:
                                      Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: _selectedIndex == 3
          ? AkunScreen(
              nama: _namaUser,
              email: _emailUser,
              showScaffold: false,
            )
          : _buildHomeContent(),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
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