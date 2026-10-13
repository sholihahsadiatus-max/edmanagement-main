import 'package:flutter/material.dart';
import 'succes_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final int totalPrice;
  final List<Map<String, dynamic>> orderItems;

  const CheckoutScreen({
    super.key,
    required this.totalPrice,
    required this.orderItems,
  });

  final Color primaryColor = const Color(0xFF006B42);

  String formatRupiah(int price) {
    return 'Rp${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ============================================================
      // APP BAR
      // ============================================================

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
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // GARIS ATAS
              Container(
                height: 2,
                color: Colors.lightBlue,
              ),

              const SizedBox(height: 12),

              // ======================================================
              // ALAMAT
              // ======================================================

              const Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                '(Rika 08888899991) '
                'Dusun Pesanggrahan RT 03 RW 03 '
                'Desa Cendono Kecamatan Purwosari',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              const Divider(
                color: Colors.black26,
              ),

              const SizedBox(height: 16),

              // ======================================================
              // RINGKASAN PESANAN
              // ======================================================

              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // ======================================================
              // DAFTAR PRODUK
              // ======================================================

              Expanded(
                child: ListView.builder(
                  itemCount: orderItems.length,

                  itemBuilder: (context, index) {
                    final item = orderItems[index];

                    final String nama =
                        item['name']?.toString() ?? 'Produk';

                    final String variant =
                        item['variant']?.toString() ?? '';

                    final int qty =
                        int.tryParse(
                              item['qty']?.toString() ?? '1',
                            ) ??
                            1;

                    final String price =
                        item['price']?.toString() ?? 'Rp0';

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),

                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,

                        borderRadius:
                            BorderRadius.circular(10),

                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),

                      child: Row(
                        children: [

                          // ==================================================
                          // INFORMASI PRODUK
                          // ==================================================

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  nama,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                if (variant.isNotEmpty)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      top: 4,
                                    ),

                                    child: Text(
                                      variant,
                                      style:
                                          const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 5),

                                Text(
                                  '$qty x $price',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        primaryColor,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ==================================================
                          // HARGA
                          // ==================================================

                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ============================================================
              // TOTAL
              // ============================================================

              const Divider(
                color: Colors.black26,
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    formatRupiah(totalPrice),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ============================================================
              // TOMBOL BELI
              // ============================================================

              SizedBox(
                width: double.infinity,
                height: 48,

                child: ElevatedButton(
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SuccessScreen(),
                      ),
                    );
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryColor,

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),

                  child: const Text(
                    'Beli',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}