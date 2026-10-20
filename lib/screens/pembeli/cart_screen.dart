import 'package:flutter/material.dart';
import 'cart_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final Map<String, dynamic>? addedProduct;
  final int? initialQuantity;

  const CartScreen({super.key, this.addedProduct, this.initialQuantity});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService cartService = CartService.instance;

  final Color primaryColor = const Color(0xFF006B42);
  final Color backgroundColor = const Color(0xFFF5F7F6);

  @override
  void initState() {
    super.initState();

    if (widget.addedProduct != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        cartService.addProduct(
          widget.addedProduct!,
          quantity: widget.initialQuantity ?? 1,
        );

        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  // ==================================================
  // KONVERSI DATA
  // ==================================================

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  String _formatRupiah(int price) {
    return 'Rp${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.')}';
  }

  String _productName(Map<String, dynamic> item) {
    return (item['name'] ?? item['nama_produk'] ?? item['nama'] ?? 'Produk')
        .toString();
  }

  String _productVariant(Map<String, dynamic> item) {
    return (item['variant'] ?? item['varian'] ?? 'Default').toString();
  }

  String _productImage(Map<String, dynamic> item) {
    return (item['image'] ??
            item['foto_url'] ??
            item['foto_produk'] ??
            item['gambar_produk'] ??
            item['gambar'] ??
            item['imageUrl'] ??
            '')
        .toString()
        .trim();
  }

  String _productStoreName(Map<String, dynamic> item) {
    return (item['nama_toko'] ??
            item['namaToko'] ??
            item['seller_name'] ??
            item['nama_penjual'] ??
            item['nama_toko_penjual'] ??
            'Toko UMKM')
        .toString();
  }

  int _productPrice(Map<String, dynamic> item) {
    return _toInt(item['price'] ?? item['harga']);
  }

  int _productQuantity(Map<String, dynamic> item) {
    final quantity = _toInt(item['quantity']);
    return quantity < 1 ? 1 : quantity;
  }

  // ==================================================
  // PRODUK YANG DIPILIH
  // ==================================================

  List<Map<String, dynamic>> _selectedItems() {
    return cartService.items
        .where((item) => item['isSelected'] == true)
        .toList();
  }

  int _selectedTotal() {
    return _selectedItems().fold<int>(
      0,
      (total, item) => total + (_productPrice(item) * _productQuantity(item)),
    );
  }

  bool get _allSelected {
    if (cartService.items.isEmpty) return false;

    return cartService.items.every((item) => item['isSelected'] == true);
  }

  // ==================================================
  // GAMBAR PRODUK
  // ==================================================

  Widget _buildProductImage(String image) {
    if (image.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade400,
          size: 42,
        ),
      );
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _imageError();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return _imageError();
      },
    );
  }

  Widget _imageError() {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.grey.shade400,
        size: 38,
      ),
    );
  }

  // ==================================================
  // PILIH SEMUA PRODUK
  // ==================================================

  void _toggleSelectAll(bool? value) {
    setState(() {
      for (final item in cartService.items) {
        item['isSelected'] = value ?? false;
      }
    });
  }

  // ==================================================
  // PILIH PRODUK
  // ==================================================

  void _toggleProductSelection(Map<String, dynamic> item, bool? value) {
    setState(() {
      item['isSelected'] = value ?? false;
    });
  }

  // ==================================================
  // QUANTITY
  // ==================================================

  void _changeQuantity(Map<String, dynamic> item, int change) {
    setState(() {
      final currentQuantity = _productQuantity(item);
      final newQuantity = currentQuantity + change;

      if (newQuantity >= 1) {
        item['quantity'] = newQuantity;
      }
    });
  }

  // ==================================================
  // HAPUS PRODUK
  // ==================================================

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Hapus Produk'),
          content: Text(
            'Apakah Anda yakin ingin menghapus '
            '${_productName(item)} dari keranjang?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      cartService.items.remove(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil dihapus dari keranjang')),
    );
  }

  // ==================================================
  // CHECKOUT
  // ==================================================

  void _checkout() {
    final selected = _selectedItems();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu produk untuk checkout'),
        ),
      );
      return;
    }

    final totalPrice = _selectedTotal();

    // Pastikan seller_id ikut dikirim dari keranjang ke checkout.
    final List<Map<String, dynamic>> orderItems = selected.map((item) {
      final quantity = _productQuantity(item);
      final unitPrice = _productPrice(item);
      final image = _productImage(item);
      final namaToko = _productStoreName(item);

      final sellerId =
          (item['seller_id'] ?? item['sellerId'] ?? item['penjual_id'] ?? '')
              .toString()
              .trim();

      return <String, dynamic>{
        'id': item['id'],

        // ID penjual diperlukan untuk mencari nomor WhatsApp.
        'seller_id': sellerId,
        'sellerId': sellerId,
        'penjual_id': sellerId,

        'name': _productName(item),
        'nama_produk': item['nama_produk'] ?? _productName(item),

        'variant': _productVariant(item),
        'varian': _productVariant(item),

        'qty': quantity,
        'quantity': quantity,

        'price': unitPrice,
        'harga': unitPrice,
        'unitPrice': unitPrice,

        'image': image,
        'foto_url': item['foto_url'] ?? image,
        'foto_produk': item['foto_produk'] ?? image,
        'gambar_produk': item['gambar_produk'] ?? image,
        'gambar': item['gambar'] ?? image,
        'imageUrl': item['imageUrl'] ?? image,

        'nama_toko': namaToko,
        'namaToko': namaToko,
        'seller_name': namaToko,
        'nama_penjual': namaToko,
        'nama_toko_penjual': namaToko,

        'lineTotal': unitPrice * quantity,
        'subtotal': unitPrice * quantity,
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CheckoutScreen(totalPrice: totalPrice, orderItems: orderItems),
      ),
    );
  }

  // ==================================================
  // TOMBOL QUANTITY
  // ==================================================

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 17, color: primaryColor),
      ),
    );
  }

  // ==================================================
  // KARTU PRODUK
  // ==================================================

  Widget _buildCartItem(Map<String, dynamic> item) {
    final image = _productImage(item);
    final name = _productName(item);
    final variant = _productVariant(item);
    final storeName = _productStoreName(item);
    final price = _productPrice(item);
    final quantity = _productQuantity(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item['isSelected'] == true,
            activeColor: primaryColor,
            onChanged: (value) {
              _toggleProductSelection(item, value);
            },
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 90,
              height: 100,
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(4),
              child: _buildProductImage(image),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 5),

                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 7),

                Text(
                  _formatRupiah(price),
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 9),

                Row(
                  children: [
                    _quantityButton(
                      icon: Icons.remove,
                      onTap: () {
                        _changeQuantity(item, -1);
                      },
                    ),

                    SizedBox(
                      width: 34,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),

                    _quantityButton(
                      icon: Icons.add,
                      onTap: () {
                        _changeQuantity(item, 1);
                      },
                    ),

                    const Spacer(),

                    IconButton(
                      tooltip: 'Hapus produk',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () {
                        _confirmDelete(item);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // RINGKASAN TOTAL
  // ==================================================

  Widget _buildTotalSection() {
    final total = _selectedTotal();
    final selectedCount = _selectedItems().length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Produk dipilih', style: TextStyle(fontSize: 13)),
                ),
                Text(
                  '$selectedCount produk',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 9),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total pembayaran',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  _formatRupiah(total),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // TAMPILAN KERANJANG
  // ==================================================

  @override
  Widget build(BuildContext context) {
    final items = cartService.items;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Keranjang Saya',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _allSelected,
                        activeColor: primaryColor,
                        onChanged: _toggleSelectAll,
                      ),
                      const Expanded(
                        child: Text(
                          'Pilih semua produk',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        '${items.length} produk',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(items[index]);
                    },
                  ),
                ),

                _buildTotalSection(),
              ],
            ),
    );
  }

  // ==================================================
  // KERANJANG KOSONG
  // ==================================================

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 76,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'Keranjang masih kosong',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Text(
              'Yuk, pilih produk UMKM yang Anda inginkan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Mulai Belanja'),
            ),
          ],
        ),
      ),
    );
  }
}
