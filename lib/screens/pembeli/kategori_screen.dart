import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'detail_produk_screen.dart';

class KategoriScreen extends StatefulWidget {
  final String kategori;

  const KategoriScreen({super.key, required this.kategori});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final Color primaryColor = const Color(0xFF006B42);
  final Color backgroundColor = const Color(0xFFF5F7F6);

  late Future<List<Map<String, String>>> _produkFuture;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _produkFuture = _getProdukKategori();
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
  // AMBIL PRODUK SESUAI KATEGORI DARI SUPABASE
  // ==========================================
  Future<List<Map<String, String>>> _getProdukKategori() async {
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
          .eq('kategori', widget.kategori)
          .gt('stok', 0)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> dataProduk =
          List<Map<String, dynamic>>.from(response);

      if (dataProduk.isEmpty) {
        return [];
      }

      // Ambil ID penjual.
      final Set<String> sellerIds = dataProduk
          .map((produk) => produk['seller_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      final Map<String, String> namaPenjualMap = {};

      // Ambil nama penjual yang sudah disetujui admin.
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

            if (role == 'seller' && status == 'approved') {
              namaPenjualMap[id] = nama.isNotEmpty ? nama : 'Penjual UMKM';
            }
          }
        } catch (e) {
          debugPrint('ERROR AMBIL NAMA PENJUAL: $e');
        }
      }

      // Gabungkan data produk dan nama penjual.
      return dataProduk.map((produk) {
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
      debugPrint('ERROR AMBIL PRODUK KATEGORI: $e');
      rethrow;
    }
  }

  // ==========================================
  // REFRESH PRODUK
  // ==========================================
  Future<void> _refreshProduk() async {
    final future = _getProdukKategori();

    setState(() {
      _produkFuture = future;
    });

    await future;
  }

  // ==========================================
  // BUKA DETAIL PRODUK
  // ==========================================
  void _openProduct(Map<String, String> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailProductScreen(product: product),
      ),
    );
  }

  // ==========================================
  // GAMBAR PRODUK
  // ==========================================
  Widget _buildProductImage(Map<String, String> product) {
    final fotoUrl = product['foto_url'] ?? '';
    final imagePath = product['image'] ?? '';

    if (fotoUrl.isNotEmpty) {
      return Image.network(
        fotoUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _gambarKosong();
        },
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _gambarKosong();
        },
      );
    }

    return _gambarKosong();
  }

  Widget _gambarKosong() {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade500,
        size: 38,
      ),
    );
  }

  // ==========================================
  // KARTU PRODUK
  // ==========================================
  Widget _buildProductCard(Map<String, String> product) {
    final nama = product['nama_produk'] ?? '';
    final harga = product['price'] ?? '';
    final namaPenjual = product['nama_penjual'] ?? 'Penjual UMKM';

    return InkWell(
      onTap: () => _openProduct(product),
      borderRadius: BorderRadius.circular(14),
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
                child: _buildProductImage(product),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    harga,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                ],
              ),
            ),
          ],
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          widget.kategori,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // PENCARIAN DALAM KATEGORI
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari ${widget.kategori}',
                  prefixIcon: const Icon(Icons.search),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
            ),

            // DAFTAR PRODUK
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProduk,
                color: primaryColor,
                child: FutureBuilder<List<Map<String, String>>>(
                  future: _produkFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    if (snapshot.hasError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          const Icon(
                            Icons.wifi_off_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          const Center(child: Text('Produk gagal dimuat.')),
                          Center(
                            child: TextButton(
                              onPressed: _refreshProduk,
                              child: const Text('Coba Lagi'),
                            ),
                          ),
                        ],
                      );
                    }

                    final semuaProduk = snapshot.data ?? [];

                    final hasilPencarian = semuaProduk.where((product) {
                      final nama = (product['nama_produk'] ?? '').toLowerCase();
                      final penjual = (product['nama_penjual'] ?? '')
                          .toLowerCase();

                      return nama.contains(_searchQuery) ||
                          penjual.contains(_searchQuery);
                    }).toList();

                    if (hasilPencarian.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 55,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'Produk tidak ditemukan.'
                                  : 'Belum ada produk ${widget.kategori}.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: hasilPencarian.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.68,
                          ),
                      itemBuilder: (context, index) {
                        return _buildProductCard(hasilPencarian[index]);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
