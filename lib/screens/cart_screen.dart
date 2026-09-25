import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final Map<String, String>? addedProduct;
  final int initialQuantity;

  const CartScreen({
    super.key,
    this.addedProduct,
    this.initialQuantity = 1,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedIndex = 2; // Indeks aktif untuk Keranjang
  final Color primaryColor = const Color(0xFF006B42);

  // Item bawaan keranjang sesuai desain gambar
  List<Map<String, dynamic>> cartItems = [
    {
      'name': 'Tas Rajut',
      'variant': 'Hitam',
      'price': 17000,
      'quantity': 1,
      'image': 'assets/tasrajut.jpeg',
      'selected': false,
    },
    {
      'name': 'Keripik Pisang',
      'variant': '250 g',
      'price': 10000,
      'quantity': 2,
      'image': 'assets/keripikpisang.jpeg',
      'selected': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Menambahkan produk dari halaman detail jika ada
    if (widget.addedProduct != null) {
      final newProduct = widget.addedProduct!;
      final priceString = newProduct['price']
              ?.replaceAll('Rp', '')
              .replaceAll('.', '')
              .trim() ??
          '0';
      final parsedPrice = int.tryParse(priceString) ?? 0;

      cartItems.add({
        'name': newProduct['name'] ?? 'Produk Baru',
        'variant': 'Default',
        'price': parsedPrice,
        'quantity': widget.initialQuantity,
        'image': newProduct['image'] ?? '',
        'selected': true,
      });
    }
  }

  // Hitung total item & harga
  int get totalItems {
    int total = 0;
    for (var item in cartItems) {
      total += (item['quantity'] as int);
    }
    return total;
  }

  int get totalPrice {
    int total = 0;
    for (var item in cartItems) {
      total += (item['price'] as int) * (item['quantity'] as int);
    }
    return total;
  }

  // Helper format rupiah
  String formatRupiah(int price) {
    return 'Rp${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, color: Colors.black12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: cartItems.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 32, color: Colors.black12),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Row(
                    children: [
                      // Checkbox
                      Checkbox(
                        value: item['selected'] as bool,
                        activeColor: primaryColor,
                        onChanged: (bool? value) {
                          setState(() {
                            item['selected'] = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 4),

                      // Gambar Produk
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: (item['image'] as String).isNotEmpty
                              ? Image.asset(
                                  item['image'] as String,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image, color: Colors.grey),
                                )
                              : const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Detail Produk
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item['variant'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatRupiah(item['price'] as int),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Counter Jumlah
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if ((item['quantity'] as int) > 1) {
                                  setState(() {
                                    item['quantity'] =
                                        (item['quantity'] as int) - 1;
                                  });
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Text('-', style: TextStyle(fontSize: 14)),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '${item['quantity']}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  item['quantity'] =
                                      (item['quantity'] as int) + 1;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Text('+', style: TextStyle(fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Footer Total & Tombol Checkout
            const Divider(height: 1, color: Colors.black12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total ($totalItems item)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        formatRupiah(totalPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final selectedOrders = cartItems.map((item){
                          return{
                            'name': item['name'],
                            'variant': item['variant'],
                            'qty': item['quantity'],
                            'price': formatRupiah((item['price'] as int) * (item['quantity'] as int)),
                          };
                        }).toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              totalPrice: totalPrice,
                              orderItems: selectedOrders,
                            ),
                             ),
                             );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}