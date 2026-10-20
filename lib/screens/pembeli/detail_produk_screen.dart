import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cart_screen.dart';
import 'cart_service.dart';
import 'toko_penjual_screen.dart';
import 'chat_penjual_screen.dart';

class DetailProductScreen extends StatefulWidget {
  final Map<String, String> product;

  const DetailProductScreen({super.key, required this.product});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  int _selectedVariantIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;

  final Color primaryColor = const Color(0xFF006B42);
  final supabase = Supabase.instance.client;

  // =========================================================
  // MENGAMBIL VARIAN PRODUK
  // =========================================================

  List<String> _getVariants() {
    final rawVariant = widget.product['varian'] ?? '';

    if (rawVariant.isEmpty || rawVariant == 'null' || rawVariant == '[]') {
      return [];
    }

    if (rawVariant.startsWith('[') && rawVariant.endsWith(']')) {
      final content = rawVariant.substring(1, rawVariant.length - 1);

      if (content.trim().isEmpty) {
        return [];
      }

      return content
          .split(',')
          .map((item) => item.trim().replaceAll('"', '').replaceAll("'", ''))
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return [rawVariant];
  }

  // =========================================================
  // FORMAT HARGA
  // =========================================================

  String _formatRupiah(String value) {
    final number =
        double.tryParse(
          value.replaceAll('Rp', '').replaceAll('.', '').trim(),
        ) ??
        0;

    final formatted = number.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp$formatted';
  }

  // =========================================================
  // GAMBAR PRODUK
  // =========================================================

  Widget _imageFallback() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 55,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _imageFallback();
        },
      );
    }

    if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _imageFallback();
        },
      );
    }

    return _imageFallback();
  }

  // =========================================================
  // FOTO PROFIL PENJUAL
  // =========================================================

  Widget _buildSellerAvatar(String fotoProfil) {
    if (fotoProfil.startsWith('http://') || fotoProfil.startsWith('https://')) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: primaryColor.withValues(alpha: 0.10),
        backgroundImage: NetworkImage(fotoProfil),
        onBackgroundImageError: (exception, stackTrace) {},
      );
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: primaryColor.withValues(alpha: 0.10),
      child: Icon(Icons.storefront, color: primaryColor, size: 28),
    );
  }

  // =========================================================
  // STATUS TOKO
  // =========================================================

  Widget _buildStoreStatus(String sellerId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: supabase
          .from('store_settings')
          .select('is_open, jam_buka, jam_tutup')
          .eq('seller_id', sellerId)
          .maybeSingle(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Status toko tidak dapat dimuat.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Memuat status toko...',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        final store = snapshot.data;

        if (store == null) {
          return const Text(
            'Status toko belum diatur',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        final isOpen = store['is_open'] == true;
        final openTime = store['jam_buka']?.toString() ?? '';
        final closeTime = store['jam_tutup']?.toString() ?? '';

        final hours = openTime.isNotEmpty && closeTime.isNotEmpty
            ? ' • $openTime - $closeTime'
            : '';

        return Row(
          children: [
            Icon(
              Icons.circle,
              size: 9,
              color: isOpen ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '${isOpen ? 'Toko buka' : 'Toko tutup'}$hours',
                style: TextStyle(
                  fontSize: 11,
                  color: isOpen ? Colors.green.shade700 : Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // RATING DAN ULASAN PENJUAL
  // =========================================================

  Widget _buildSellerRating(String sellerId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supabase
          .from('reviews')
          .select('rating, ulasan, created_at')
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Rating belum dapat dimuat.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Memuat rating...',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        final reviews = snapshot.data ?? [];

        final ratings = reviews
            .map((review) => int.tryParse(review['rating'].toString()) ?? 0)
            .where((rating) => rating >= 1 && rating <= 5)
            .toList();

        if (ratings.isEmpty) {
          return const Text(
            'Belum ada rating',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        final average = ratings.reduce((a, b) => a + b) / ratings.length;

        return InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rating dan Ulasan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${average.toStringAsFixed(1)} dari 5 '
                            '(${ratings.length} rating)',
                          ),
                          const Divider(height: 24),
                          Expanded(
                            child: ListView.builder(
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                final review = reviews[index];

                                final rating =
                                    int.tryParse(review['rating'].toString()) ??
                                    0;

                                final comment =
                                    review['ulasan']?.toString() ?? '';

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.person_outline,
                                    color: Colors.grey,
                                  ),
                                  title: Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 17,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    comment.isEmpty
                                        ? 'Tanpa komentar'
                                        : comment,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${average.toStringAsFixed(1)} (${ratings.length})',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.chevron_right, size: 15, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // AKUN PENJUAL
  // =========================================================

  Widget _buildSellerSection() {
    final sellerId = widget.product['seller_id'] ?? '';

    if (sellerId.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<dynamic>>(
      future: supabase.rpc(
        'get_public_seller_profile',
        params: {'p_seller_id': sellerId},
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Gagal memuat profil penjual: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Data profil penjual tidak ditemukan.'),
          );
        }

        final seller = Map<String, dynamic>.from(snapshot.data!.first as Map);

        final namaPenjual = seller['nama']?.toString().trim().isNotEmpty == true
            ? seller['nama'].toString()
            : 'Penjual UMKM';

        final fotoProfil = seller['foto_profil']?.toString() ?? '';
        final alamatPenjual = seller['alamat']?.toString() ?? '';
        final nomorHp = seller['no_handphone']?.toString() ?? '';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSellerAvatar(fotoProfil),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Penjual',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          namaPenjual,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Penjual terverifikasi',
                          style: TextStyle(fontSize: 11, color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Chat penjual',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPenjualScreen(
                            sellerId: sellerId,
                            namaPenjual: namaPenjual,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.chat_outlined, color: primaryColor),
                  ),
                ],
              ),
              if (alamatPenjual.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        alamatPenjual,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (nomorHp.isNotEmpty) ...[
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 17, color: primaryColor),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        nomorHp,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              _buildStoreStatus(sellerId),
              const SizedBox(height: 8),
              _buildSellerRating(sellerId),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TokoPenjualScreen(
                          sellerId: sellerId,
                          namaPenjual: namaPenjual,
                        ),
                      ),
                    );
                  },
                  child: const Text('Lihat Toko'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // TAMBAH PRODUK KE KERANJANG
  // =========================================================

  void _addToCart({
    required String name,
    required String price,
    required String imagePath,
    required String selectedVariant,
    required int stock,
  }) {
    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok produk sedang habis.')),
      );
      return;
    }

    if (_quantity < 1 || _quantity > stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jumlah produk harus antara 1 dan $stock.')),
      );
      return;
    }

    // Semua field produk asli tetap dipertahankan.
    // Field tambahan menyamakan format dengan CartService.
    final Map<String, dynamic> productToCart = {
      ...widget.product,
      'name': name,
      'nama_produk': name,
      'price': price,
      'image': imagePath,
      'variant': selectedVariant.isNotEmpty ? selectedVariant : 'Default',
    };

    // Produk hanya dimasukkan satu kali ke penyimpanan bersama.
    CartService.instance.addProduct(productToCart, quantity: _quantity);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name berhasil ditambahkan ke keranjang.'),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );

    // Buka keranjang tanpa mengirim ulang addedProduct.
    // Dengan begitu, produk tidak terhitung dua kali.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  // =========================================================
  // TAMPILAN DETAIL PRODUK
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final String name =
        widget.product['nama_produk'] ??
        widget.product['name'] ??
        'Detail Produk';

    final String price =
        widget.product['price'] ??
        _formatRupiah(widget.product['harga'] ?? '0');

    final String imagePath =
        widget.product['image'] ?? widget.product['foto_url'] ?? '';

    final String description =
        widget.product['deskripsi'] ?? widget.product['description'] ?? '';

    final List<String> variants = _getVariants();

    final int stock = int.tryParse(widget.product['stok'] ?? '0') ?? 0;

    final bool canBuy = stock > 0;

    final String selectedVariant =
        variants.isNotEmpty && _selectedVariantIndex < variants.length
        ? variants[_selectedVariantIndex]
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Detail Produk',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Favorit',
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR PRODUK
            Container(
              height: 260,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: _buildProductImage(imagePath),
            ),

            const SizedBox(height: 18),

            // NAMA PRODUK
            Text(
              name,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            // HARGA PRODUK
            Text(
              price,
              style: TextStyle(
                fontSize: 23,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // STOK PRODUK
            Row(
              children: [
                Icon(
                  canBuy ? Icons.inventory_2_outlined : Icons.info_outline,
                  size: 17,
                  color: canBuy ? primaryColor : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  canBuy ? 'Stok: $stock' : 'Stok habis',
                  style: TextStyle(
                    color: canBuy ? Colors.black54 : Colors.red,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // PROFIL PENJUAL
            _buildSellerSection(),

            const SizedBox(height: 12),

            // DESKRIPSI
            const Text(
              'Deskripsi Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Text(
              description.isNotEmpty
                  ? description
                  : 'Belum ada deskripsi produk.',
              style: const TextStyle(
                color: Colors.black54,
                height: 1.5,
                fontSize: 14,
              ),
            ),

            // VARIAN PRODUK
            if (variants.isNotEmpty) ...[
              const SizedBox(height: 22),
              const Text(
                'Pilih Varian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(variants.length, (index) {
                  final bool selected = _selectedVariantIndex == index;

                  return ChoiceChip(
                    label: Text(variants[index]),
                    selected: selected,
                    selectedColor: primaryColor.withValues(alpha: 0.15),
                    onSelected: (value) {
                      if (!value) return;

                      setState(() {
                        _selectedVariantIndex = index;
                      });
                    },
                  );
                }),
              ),
            ],

            // JUMLAH PRODUK
            const SizedBox(height: 22),
            const Text(
              'Jumlah Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _quantityButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),
                Container(
                  width: 55,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _quantityButton(
                  icon: Icons.add,
                  onTap: () {
                    if (_quantity < stock) {
                      setState(() {
                        _quantity++;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // TOMBOL TAMBAH KE KERANJANG
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: canBuy
                  ? () {
                      _addToCart(
                        name: name,
                        price: price,
                        imagePath: imagePath,
                        selectedVariant: selectedVariant,
                        stock: stock,
                      );
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text(
                canBuy ? 'Tambah ke Keranjang' : 'Stok Habis',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TOMBOL JUMLAH
  // =========================================================

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
    );
  }
}
