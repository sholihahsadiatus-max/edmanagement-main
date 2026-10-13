import 'package:flutter/material.dart';
import 'kategori_screen.dart';

class KategoriMenuScreen extends StatelessWidget {
  const KategoriMenuScreen({super.key});

  static const Color primaryColor = Color(0xFF006B42);

  static const List<Map<String, dynamic>> categories = [
    {
      'nama': 'Makanan',
      'icon': Icons.restaurant,
    },
    {
      'nama': 'Minuman',
      'icon': Icons.local_drink,
    },
    {
      'nama': 'Fashion',
      'icon': Icons.shopping_bag,
    },
    {
      'nama': 'Kerajinan',
      'icon': Icons.brush,
    },
    {
      'nama': 'Lainnya',
      'icon': Icons.more_horiz,
    },
  ];

  void bukaKategori(
    BuildContext context,
    String kategori,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KategoriScreen(
          kategori: kategori,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Kategori',
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temukan Produk UMKM',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih kategori produk yang ingin kamu cari',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];

                  final String nama =
                      category['nama'] as String;

                  final IconData icon =
                      category['icon'] as IconData;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      bukaKategori(context, nama);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5EF),
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: primaryColor.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                primaryColor,
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nama,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}