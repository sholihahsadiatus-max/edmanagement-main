import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_screen.dart';

class TokoPenjualScreen extends StatefulWidget {
  final String sellerId;
  final String namaPenjual;

  const TokoPenjualScreen({
    super.key,
    required this.sellerId,
    required this.namaPenjual,
  });

  @override
  State<TokoPenjualScreen> createState() => _TokoPenjualScreenState();
}

class _TokoPenjualScreenState extends State<TokoPenjualScreen> {
  final supabase = Supabase.instance.client;
  final Color primaryColor = const Color(0xFF006B42);

  late Future<List<Map<String, dynamic>>> _productsFuture;
  late Future<List<Map<String, dynamic>>> _profileFuture;
  late Future<Map<String, dynamic>?> _storeFuture;
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // MEMUAT DATA
  // ============================================================

  void _loadData() {
    _productsFuture = _loadProducts();
    _profileFuture = _loadProfile();
    _storeFuture = _loadStore();
    _reviewsFuture = _loadReviews();
  }

  Future<List<Map<String, dynamic>>> _loadProducts() async {
    final result = await supabase
        .from('products')
        .select()
        .eq('seller_id', widget.sellerId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<List<Map<String, dynamic>>> _loadProfile() async {
    final result = await supabase.rpc(
      'get_public_seller_profile',
      params: {'p_seller_id': widget.sellerId},
    );

    return List<Map<String, dynamic>>.from(result);
  }

  Future<Map<String, dynamic>?> _loadStore() async {
    final result = await supabase
        .from('store_settings')
        .select('is_open, jam_buka, jam_tutup')
        .eq('seller_id', widget.sellerId)
        .maybeSingle();

    return result;
  }

  Future<List<Map<String, dynamic>>> _loadReviews() async {
    final result = await supabase
        .from('reviews')
        .select('rating, ulasan, created_at, buyer_id')
        .eq('seller_id', widget.sellerId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  // ============================================================
  // KONVERSI HARGA
  // ============================================================

  int _convertPrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  String _rupiah(dynamic value) {
    final number = _convertPrice(value);

    return 'Rp${number.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
  }

  // ============================================================
  // TAMBAH PRODUK KE KERANJANG
  // ============================================================

  void _addToCart(Map<String, dynamic> product) {
    final int stock = int.tryParse(product['stok']?.toString() ?? '0') ?? 0;

    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maaf, stok produk sedang habis.')),
      );
      return;
    }

    final String namaProduk =
        product['nama_produk']?.toString() ?? 'Produk UMKM';

    final int harga = _convertPrice(product['harga']);

    final String foto = product['foto_url']?.toString() ?? '';

    // Mendukung varian dalam bentuk String, List, atau Map.
    final dynamic varianData = product['varian'];
    String varian = 'Default';

    if (varianData is String && varianData.trim().isNotEmpty) {
      varian = varianData;
    } else if (varianData is List && varianData.isNotEmpty) {
      varian = varianData.join(', ');
    } else if (varianData is Map && varianData.isNotEmpty) {
      varian = varianData.values.join(', ');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          addedProduct: {
            'product_id': product['id']?.toString(),
            'name': namaProduk,
            'variant': varian,
            'price': harga,
            'image': foto,
          },
          initialQuantity: 1,
        ),
      ),
    );
  }

  // ============================================================
  // PROFIL PENJUAL
  // ============================================================

  Widget _profileSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Gagal memuat profil: ${snapshot.error}'),
          );
        }

        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Profil penjual tidak ditemukan.'),
          );
        }

        final seller = snapshot.data!.first;

        final name = seller['nama']?.toString() ?? widget.namaPenjual;
        final phone = seller['no_handphone']?.toString() ?? '';
        final address = seller['alamat']?.toString() ?? '';
        final photo = seller['foto_profil']?.toString() ?? '';

        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                backgroundImage: photo.startsWith('http')
                    ? NetworkImage(photo)
                    : null,
                child: photo.startsWith('http')
                    ? null
                    : Icon(Icons.storefront, size: 42, color: primaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _infoRow(
                Icons.phone_outlined,
                phone.isEmpty ? 'Nomor HP belum tersedia' : phone,
              ),
              const SizedBox(height: 8),
              _infoRow(
                Icons.location_on_outlined,
                address.isEmpty ? 'Alamat belum tersedia' : address,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: primaryColor),
        const SizedBox(width: 9),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  // ============================================================
  // STATUS TOKO
  // ============================================================

  Widget _storeStatus() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _storeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Status toko tidak dapat dimuat.');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        final store = snapshot.data;

        if (store == null) {
          return const Text('Status toko belum diatur.');
        }

        final isOpen = store['is_open'] == true;
        final openTime = store['jam_buka']?.toString() ?? '';
        final closeTime = store['jam_tutup']?.toString() ?? '';

        final jamToko = openTime.isNotEmpty && closeTime.isNotEmpty
            ? ' • $openTime - $closeTime'
            : '';

        return Row(
          children: [
            Icon(
              Icons.circle,
              size: 11,
              color: isOpen ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${isOpen ? 'Toko sedang buka' : 'Toko sedang tutup'}$jamToko',
                style: TextStyle(
                  color: isOpen ? Colors.green.shade700 : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // RATING DAN ULASAN
  // ============================================================

  Widget _ratingSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Gagal memuat ulasan: ${snapshot.error}'),
          );
        }

        final reviews = snapshot.data ?? [];

        final ratings = reviews
            .map((review) => int.tryParse(review['rating'].toString()) ?? 0)
            .where((rating) => rating >= 1 && rating <= 5)
            .toList();

        final average = ratings.isEmpty
            ? 0.0
            : ratings.reduce((a, b) => a + b) / ratings.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    ratings.isEmpty
                        ? 'Belum ada rating'
                        : '${average.toStringAsFixed(1)} / 5 (${ratings.length} rating)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (reviews.isEmpty)
              const Text('Belum ada ulasan dari pembeli.')
            else
              ...reviews.map((review) {
                final rating = int.tryParse(review['rating'].toString()) ?? 0;
                final comment = review['ulasan']?.toString() ?? '';

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      ),
                      if (comment.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(comment),
                      ],
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // ============================================================
  // GAMBAR PRODUK: TAMPIL UTUH TANPA CROP
  // ============================================================

  Widget _productImage(String? url) {
    if (url != null && url.startsWith('http')) {
      return Container(
        width: double.infinity,
        height: 155,
        color: Colors.white,
        alignment: Alignment.center,
        child: Image.network(
          url,
          width: double.infinity,
          height: 155,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _imagePlaceholder(),
        ),
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 155,
      color: Colors.grey.shade50,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 42, color: Colors.grey.shade400),
    );
  }

  // ============================================================
  // KARTU PRODUK
  // ============================================================

  Widget _productCard(Map<String, dynamic> product) {
    final namaProduk = product['nama_produk']?.toString() ?? 'Produk UMKM';

    final harga = product['harga'] ?? 0;

    final stok = int.tryParse(product['stok']?.toString() ?? '0') ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Foto produk tampil utuh
          _productImage(product['foto_url']?.toString()),

          // Informasi dan tombol
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama produk maksimal dua baris
                  SizedBox(
                    height: 36,
                    child: Text(
                      namaProduk,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Harga menyesuaikan lebar kartu
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _rupiah(harga),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Stok: $stok',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),

                  const Spacer(),

                  // Tombol keranjang
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: stok > 0 ? () => _addToCart(product) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_shopping_cart, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              stok > 0 ? 'Tambah ke Keranjang' : 'Stok Habis',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAMPILAN UTAMA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: const Text('Toko Penjual'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_loadData);

          await Future.wait([
            _productsFuture,
            _profileFuture,
            _storeFuture,
            _reviewsFuture,
          ]);
        },
        child: ListView(
          children: [
            // Profil penjual
            _profileSection(),

            // Status toko
            Container(
              margin: const EdgeInsets.only(top: 10),
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: _storeStatus(),
            ),

            // Rating dan ulasan
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating dan Ulasan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _ratingSection(),
                ],
              ),
            ),

            // Judul produk
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: const Text(
                'Produk Toko',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),

            // Daftar produk
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Gagal memuat produk: ${snapshot.error}'),
                  );
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('Belum ada produk.')),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  itemBuilder: (context, index) {
                    return _productCard(products[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
