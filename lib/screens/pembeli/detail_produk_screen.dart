import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cart_screen.dart';
import 'toko_penjual_screen.dart';

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

  // =========================================================
  // MENGAMBIL VARIAN PRODUK
  // =========================================================

  List<String> _getVariants() {
    final rawVariant = widget.product['varian'] ?? '';

    if (rawVariant.isEmpty || rawVariant == 'null' || rawVariant == '[]') {
      return [];
    }

    // Mendukung format JSONB seperti ["kg", "500 gram"].
    if (rawVariant.startsWith('[') && rawVariant.endsWith(']')) {
      final content = rawVariant.substring(1, rawVariant.length - 1);

      if (content.trim().isEmpty) return [];

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
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imageFallback();
        },
      );
    }

    if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imageFallback();
        },
      );
    }

    return _imageFallback();
  }

  // =========================================================
  // AKUN PENJUAL
  // =========================================================

  Widget _buildSellerSection() {
    final sellerId = widget.product['seller_id'] ?? '';

    if (sellerId.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: Supabase.instance.client
          .from('profiles')
          .select('id, nama, role, seller_status')
          .eq('id', sellerId)
          .maybeSingle(),
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

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final seller = snapshot.data!;

        if (seller['role'] != 'seller' ||
            seller['seller_status'] != 'approved') {
          return const SizedBox.shrink();
        }

        final namaPenjual = seller['nama']?.toString().trim().isNotEmpty == true
            ? seller['nama'].toString()
            : 'Penjual UMKM';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: primaryColor.withValues(alpha: 0.10),
                child: Icon(Icons.storefront, color: primaryColor, size: 28),
              ),
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
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
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
                child: const Text('Lihat Toko', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
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

            // REVISI: AKUN PENJUAL DAN TOMBOL LIHAT TOKO
            _buildSellerSection(),

            const SizedBox(height: 12),

            // DESKRIPSI PRODUK
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

      // TOMBOL KERANJANG
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
                      final productToCart = <String, String>{
                        ...widget.product,
                        'varian_dipilih': selectedVariant,
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartScreen(
                            addedProduct: productToCart,
                            initialQuantity: _quantity,
                          ),
                        ),
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
