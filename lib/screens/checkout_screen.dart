import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final int totalPrice;
  final List<Map<String, dynamic>> orderItems;

  const CheckoutScreen({
    super.key,
    this.totalPrice = 37000,
    this.orderItems = const [
      {
        'name': 'Tas Rajut',
        'variant': 'Hitam',
        'qty': 1,
        'price': 'Rp17.000',
      },
      {
        'name': 'Keripik Pisang 250g',
        'variant': '',
        'qty': 2,
        'price': 'Rp20.000',
      },
    ],
  });

  final Color primaryColor = const Color(0xFF006B42);

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
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Garis biru di bawah AppBar
              Container(
                height: 2,
                color: Colors.lightBlue,
              ),
              const SizedBox(height: 12),

              // Alamat Pengiriman
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 13, height: 1.4),
                  children: [
                    TextSpan(
                      text: 'Alamat : ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          '(Rika 08888899991) Dusun Pesanggrahan RT 03 RW 03 Desa Cendono Kecamatan Purwosari',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.black26),
              const SizedBox(height: 16),

              // Judul Ringkasan Pesanan
              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // List Items Ringkasan Pesanan
              Column(
                children: orderItems.map((item) {
                  final String variantText = item['variant'].toString().isNotEmpty
                      ? ' ,${item['variant']}'
                      : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item['name']}$variantText  ${item['qty']}x',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          item['price'].toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1, color: Colors.black26),
              const SizedBox(height: 16),

              // Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
              const SizedBox(height: 8),
              const Divider(height: 1, color: Colors.black26),
              const SizedBox(height: 32),

              // Tombol Beli
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Dialog/Aksi saat tombol Beli diklik
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pesanan Berhasil Dibuat!'),
                        backgroundColor: Color(0xFF006B42),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Beli',
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
      ),
    );
  }
}