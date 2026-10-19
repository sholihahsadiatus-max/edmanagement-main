import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_produk_screen.dart';

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
  final Color primaryColor = const Color(0xFF006B42);

  late Future<List<Map<String, String>>> _produkFuture;

  @override
  void initState() {
    super.initState();
    _produkFuture = _ambilProdukPenjual();
  }

  Future<List<Map<String, String>>> _ambilProdukPenjual() async {
    final response = await Supabase.instance.client
        .from('products')
        .select(
          'id, seller_id, nama_produk, kategori, harga, stok, '
          'deskripsi, foto_url, varian, created_at',
        )
        .eq('seller_id', widget.sellerId)
        .gt('stok', 0)
        .order('created_at', ascending: false);

    return (response as List).map((item) {
      final produk = Map<String, dynamic>.from(item);

      final harga =
          double.tryParse(produk['harga']?.toString() ?? '0')?.toInt() ?? 0;

      final hargaFormat = harga.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );

      final nama = produk['nama_produk']?.toString() ?? '';
      final foto = produk['foto_url']?.toString() ?? '';

      return <String, String>{
        'id': produk['id']?.toString() ?? '',
        'seller_id': produk['seller_id']?.toString() ?? '',
        'nama_produk': nama,
        'name': nama,
        'kategori': produk['kategori']?.toString() ?? '',
        'harga': produk['harga']?.toString() ?? '0',
        'price': 'Rp$hargaFormat',
        'stok': produk['stok']?.toString() ?? '0',
        'deskripsi': produk['deskripsi']?.toString() ?? '',
        'description': produk['deskripsi']?.toString() ?? '',
        'foto_url': foto,
        'image': foto,
        'varian': produk['varian']?.toString() ?? '',
        'created_at': produk['created_at']?.toString() ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Toko Penjual',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: primaryColor.withValues(alpha: 0.10),
                  child: Icon(Icons.storefront, color: primaryColor, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.namaPenjual,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Produk dari penjual ini',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Semua Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _produkFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Produk toko gagal dimuat. '
                        'Periksa koneksi dan izin akses database.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final produk = snapshot.data ?? [];

                if (produk.isEmpty) {
                  return const Center(
                    child: Text('Belum ada produk tersedia di toko ini.'),
                  );
                }

                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () async {
                    setState(() {
                      _produkFuture = _ambilProdukPenjual();
                    });
                    await _produkFuture;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: produk.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                    itemBuilder: (context, index) {
                      final item = produk[index];
                      final foto = item['image'] ?? '';

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailProductScreen(product: item),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: foto.startsWith('http')
                                      ? Image.network(
                                          foto,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _gambarKosong(),
                                        )
                                      : _gambarKosong(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['price'] ?? 'Rp0',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Stok: ${item['stok'] ?? '0'}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _gambarKosong() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 42, color: Colors.grey),
    );
  }
}
