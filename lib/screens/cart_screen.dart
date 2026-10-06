import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final Map<String, dynamic>? addedProduct;
  final int? initialQuantity;

  const CartScreen({
    super.key,
    this.addedProduct,
    this.initialQuantity,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Color primaryColor = const Color(0xFF006B42);

  // ============================================================
  // DATA KERANJANG
  // ============================================================

  final List<Map<String, dynamic>> cartItems = [
    {
      'name': 'Tas Rajut',
      'variant': 'Hitam',
      'price': 17000,
      'quantity': 1,
      'image': 'assets/tas_rajut.jpeg',
      'isSelected': false,
    },
    {
      'name': 'Keripik Pisang',
      'variant': '250 g',
      'price': 10000,
      'quantity': 1,
      'image': 'assets/keripik_pisang.jpeg',
      'isSelected': false,
    },
  ];

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Jika halaman ini menerima produk dari halaman sebelumnya,
    // produk tersebut akan ditambahkan ke keranjang.
    if (widget.addedProduct != null) {
      final product =
          Map<String, dynamic>.from(widget.addedProduct!);

      cartItems.add({
        'name':
            product['name'] ??
            product['nama'] ??
            'Produk',

        'variant':
            product['variant'] ??
            product['varian'] ??
            'Default',

        'price': _convertPrice(
          product['price'] ??
          product['harga'] ??
          0,
        ),

        'quantity':
            widget.initialQuantity ?? 1,

        'image':
            product['image'] ??
            product['gambar'] ??
            '',

        'isSelected': true,
      });
    }
  }

  // ============================================================
  // KONVERSI HARGA
  // ============================================================

  int _convertPrice(dynamic price) {
    if (price == null) {
      return 0;
    }

    if (price is int) {
      return price;
    }

    if (price is double) {
      return price.toInt();
    }

    return int.tryParse(
          price
              .toString()
              .replaceAll(
                RegExp(r'[^0-9]'),
                '',
              ),
        ) ??
        0;
  }

  // ============================================================
  // TOTAL ITEM
  // ============================================================

  int get totalSelectedItems {
    int total = 0;

    for (final item in cartItems) {
      if (item['isSelected'] == true) {
        total += item['quantity'] as int;
      }
    }

    return total;
  }

  // ============================================================
  // TOTAL HARGA
  // ============================================================

  int get totalPrice {
    int total = 0;

    for (final item in cartItems) {
      if (item['isSelected'] == true) {
        total +=
            (item['price'] as int) *
            (item['quantity'] as int);
      }
    }

    return total;
  }

  // ============================================================
  // FORMAT RUPIAH
  // ============================================================

  String formatRupiah(int number) {
    return 'Rp${number.toString().replaceAllMapped(
          RegExp(
            r'(\d{1,3})(?=(\d{3})+(?!\d))',
          ),
          (Match m) => '${m[1]}.',
        )}';
  }

  // ============================================================
  // TAMBAH JUMLAH
  // ============================================================

  void tambahQuantity(int index) {
    setState(() {
      cartItems[index]['quantity'] =
          (cartItems[index]['quantity'] as int) + 1;
    });
  }

  // ============================================================
  // KURANGI JUMLAH
  // ============================================================

  void kurangiQuantity(int index) {
    final int quantity =
        cartItems[index]['quantity'] as int;

    if (quantity > 1) {
      setState(() {
        cartItems[index]['quantity'] =
            quantity - 1;
      });
    }
  }

  // ============================================================
  // HAPUS ITEM
  // ============================================================

  void hapusItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  // ============================================================
  // CHECKOUT
  // ============================================================

  void checkout() {
    // Ambil produk yang dicentang.
    final selectedItems = cartItems
        .where(
          (item) => item['isSelected'] == true,
        )
        .toList();

    // Jika tidak ada produk yang dipilih.
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih produk terlebih dahulu',
          ),
        ),
      );

      return;
    }

    // Ubah format data CartScreen
    // menjadi format orderItems
    // yang digunakan CheckoutScreen.
    final List<Map<String, dynamic>> orderItems =
        selectedItems.map((item) {
      final int price =
          item['price'] as int;

      final int quantity =
          item['quantity'] as int;

      return {
        'name': item['name'],
        'variant': item['variant'],
        'qty': quantity,
        'price': formatRupiah(
          price * quantity,
        ),
      };
    }).toList();

    // ========================================================
    // MASUK KE CHECKOUT
    // ========================================================

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          totalPrice: totalPrice,
          orderItems: orderItems,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Keranjang',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(1),

          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : ListView.separated(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 12,
              ),

              itemCount:
                  cartItems.length,

              separatorBuilder:
                  (context, index) {
                return Divider(
                  color:
                      Colors.grey.shade200,
                  height: 24,
                );
              },

              itemBuilder:
                  (context, index) {
                return _buildCartItem(
                  index,
                );
              },
            ),

      // ========================================================
      // BOTTOM CHECKOUT
      // ========================================================

      bottomNavigationBar:
          cartItems.isEmpty
              ? null
              : _buildBottomCheckout(),
    );
  }

  // ============================================================
  // KERANJANG KOSONG
  // ============================================================

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons
                .shopping_cart_outlined,
            size: 80,
            color:
                Colors.grey.shade300,
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            'Keranjang masih kosong',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            'Tambahkan produk terlebih dahulu',
            style: TextStyle(
              fontSize: 13,
              color:
                  Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ITEM KERANJANG
  // ============================================================

  Widget _buildCartItem(int index) {
    final item = cartItems[index];

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ====================================================
          // CHECKBOX
          // ====================================================

          Checkbox(
            value:
                item['isSelected'] == true,

            activeColor:
                primaryColor,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                4,
              ),
            ),

            onChanged: (value) {
              setState(() {
                item['isSelected'] =
                    value ?? false;
              });
            },
          ),

          const SizedBox(
            width: 4,
          ),

          // ====================================================
          // GAMBAR
          // ====================================================

          _buildProductImage(item),

          const SizedBox(
            width: 12,
          ),

          // ====================================================
          // INFORMASI PRODUK
          // ====================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  item['name']
                      .toString(),

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  item['variant']
                      .toString(),

                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  formatRupiah(
                    item['price']
                        as int,
                  ),

                  style:
                      TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        primaryColor,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // ==================================================
                // QUANTITY
                // ==================================================

                Row(
                  children: [
                    _quantityButton(
                      icon:
                          Icons.remove,

                      onTap: () {
                        kurangiQuantity(
                          index,
                        );
                      },
                    ),

                    Container(
                      width: 35,

                      alignment:
                          Alignment.center,

                      child: Text(
                        '${item['quantity']}',

                        style:
                            const TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    _quantityButton(
                      icon:
                          Icons.add,

                      onTap: () {
                        tambahQuantity(
                          index,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ====================================================
          // HAPUS
          // ====================================================

          IconButton(
            icon: Icon(
              Icons
                  .delete_outline,

              color:
                  Colors.grey.shade600,
            ),

            onPressed: () {
              hapusItem(index);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GAMBAR PRODUK
  // ============================================================

  Widget _buildProductImage(
    Map<String, dynamic> item,
  ) {
    final String image =
        item['image']
                ?.toString() ??
            '';

    // Jika tidak ada gambar.
    if (image.isEmpty) {
      return _imagePlaceholder();
    }

    // Jika gambar berasal dari assets.
    if (image.startsWith(
      'assets/',
    )) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(
          8,
        ),

        child: Image.asset(
          image,

          width: 70,
          height: 70,

          fit: BoxFit.cover,

          errorBuilder:
              (context, error,
                  stackTrace) {
            return _imagePlaceholder();
          },
        ),
      );
    }

    // Jika gambar berasal dari URL.
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        8,
      ),

      child: Image.network(
        image,

        width: 70,
        height: 70,

        fit: BoxFit.cover,

        errorBuilder:
            (context, error,
                stackTrace) {
          return _imagePlaceholder();
        },
      ),
    );
  }

  // ============================================================
  // PLACEHOLDER GAMBAR
  // ============================================================

  Widget _imagePlaceholder() {
    return Container(
      width: 70,
      height: 70,

      decoration:
          BoxDecoration(
        color:
            Colors.grey.shade200,

        borderRadius:
            BorderRadius.circular(
          8,
        ),
      ),

      child: const Icon(
        Icons
            .image_outlined,

        color: Colors.grey,
      ),
    );
  }

  // ============================================================
  // TOMBOL + DAN -
  // ============================================================

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(
        6,
      ),

      child: Container(
        width: 30,
        height: 30,

        decoration:
            BoxDecoration(
          color:
              Colors.grey.shade100,

          borderRadius:
              BorderRadius.circular(
            6,
          ),
        ),

        child: Icon(
          icon,
          size: 16,
        ),
      ),
    );
  }

  // ============================================================
  // BAGIAN BAWAH
  // ============================================================

  Widget _buildBottomCheckout() {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color:
                Colors.grey.shade200,
          ),
        ),
      ),

      child: SafeArea(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            // ==================================================
            // TOTAL
            // ==================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [
                Text(
                  'Total ($totalSelectedItems item)',

                  style:
                      const TextStyle(
                    fontSize: 14,
                    color:
                        Colors.black54,
                  ),
                ),

                Text(
                  formatRupiah(
                    totalPrice,
                  ),

                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // TOMBOL CHECKOUT
            // ==================================================

            SizedBox(
              width:
                  double.infinity,

              height: 48,

              child:
                  ElevatedButton(
                onPressed:
                    totalSelectedItems >
                            0
                        ? checkout
                        : null,

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      primaryColor,

                  disabledBackgroundColor:
                      Colors.grey
                          .shade300,

                  elevation: 0,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),
                ),

                child:
                    const Text(
                  'Checkout',

                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}