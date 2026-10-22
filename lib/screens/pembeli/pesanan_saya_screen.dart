import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PesananSayaScreen extends StatefulWidget {
  const PesananSayaScreen({super.key});

  @override
  State<PesananSayaScreen> createState() => _PesananSayaScreenState();
}

class _PesananSayaScreenState extends State<PesananSayaScreen> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _pesanan = [];

  @override
  void initState() {
    super.initState();
    _muatPesanan();
  }

  Future<void> _muatPesanan() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Silakan login terlebih dahulu.');
      }

      final response = await supabase
          .from('orders')
          .select(
            'id, buyer_name, delivery_address, '
            'total_amount, status, items, created_at',
          )
          .eq('buyer_id', user.id)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(
        (response as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );

      if (!mounted) return;

      setState(() {
        _pesanan = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _rupiah(dynamic value) {
    final nominal = value is num ? value : num.tryParse(value.toString()) ?? 0;

    final angka = nominal.toInt().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < angka.length; i++) {
      buffer.write(angka[i]);

      final sisa = angka.length - i - 1;
      if (sisa > 0 && sisa % 3 == 0) {
        buffer.write('.');
      }
    }

    return 'Rp$buffer';
  }

  String _tanggal(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _status(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return 'Menunggu konfirmasi';
      case 'confirmed':
        return 'Pesanan dikonfirmasi';
      case 'processing':
        return 'Pesanan diproses';
      case 'completed':
        return 'Pesanan selesai';
      case 'cancelled':
        return 'Pesanan dibatalkan';
      default:
        return value;
    }
  }

  Widget _gambarProduk(dynamic image) {
    final url = image?.toString() ?? '';

    if (url.isEmpty) {
      return const Icon(Icons.shopping_bag_outlined, size: 32);
    }

    return Image.network(
      url,
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox(
          width: 72,
          height: 72,
          child: Icon(Icons.image_not_supported_outlined),
        );
      },
    );
  }

  Widget _kartuPesanan(Map<String, dynamic> order) {
    final rawItems = order['items'];

    final List<Map<String, dynamic>> items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : [];

    final status = order['status']?.toString() ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Color(0xFF006B42)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Detail Pesanan',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                Flexible(
                  child: Text(
                    _status(status),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Color(0xFF006B42),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${order['id'] ?? '-'}',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            Text(
              'Tanggal: ${_tanggal(order['created_at'])}',
              style: const TextStyle(fontSize: 12),
            ),
            const Divider(height: 24),

            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Detail produk belum tersedia.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...items.map((item) {
                final quantity = item['quantity'] ?? 1;
                final price = item['unit_price'] ?? 0;
                final name = item['name']?.toString() ?? 'Produk';
                final variant = item['variant']?.toString() ?? 'Default';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _gambarProduk(item['image']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Varian: $variant',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${_rupiah(price)} × $quantity',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _rupiah(
                                (num.tryParse(price.toString()) ?? 0) *
                                    (num.tryParse(quantity.toString()) ?? 1),
                              ),
                              style: const TextStyle(
                                color: Color(0xFF006B42),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const Divider(height: 12),
            const Text(
              'Alamat pesanan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              order['delivery_address']?.toString() ?? '-',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total pembayaran',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  _rupiah(order['total_amount']),
                  style: const TextStyle(
                    color: Color(0xFF006B42),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: const Color(0xFF006B42),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _muatPesanan,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 42,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text('Pesanan gagal dimuat.'),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _muatPesanan,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : _pesanan.isEmpty
          ? RefreshIndicator(
              onRefresh: _muatPesanan,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(child: Text('Belum ada pesanan')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _muatPesanan,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    '${_pesanan.length} pesanan',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ..._pesanan.map(_kartuPesanan),
                ],
              ),
            ),
    );
  }
}
