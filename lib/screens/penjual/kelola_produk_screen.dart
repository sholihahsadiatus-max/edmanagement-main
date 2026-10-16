import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'tambah_produk_screen.dart';

class KelolaProdukScreen extends StatefulWidget {
  const KelolaProdukScreen({super.key});

  @override
  State<KelolaProdukScreen> createState() => _KelolaProdukScreenState();
}

class _KelolaProdukScreenState extends State<KelolaProdukScreen> {
  static const Color hijau = Color(0xFF006B42);
  static const Color latar = Color(0xFFF5F7F6);

  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> produk = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _ambilProduk();
  }

  // ==================================================
  // AMBIL PRODUK DARI SUPABASE
  // ==================================================
  Future<void> _ambilProduk() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Sesi login tidak ditemukan. Silakan login kembali.';
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final data = await supabase
          .from('products')
          .select()
          .eq('seller_id', user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        produk = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Gagal mengambil produk: $e';
      });
    }
  }

  // ==================================================
  // TAMBAH DAN EDIT PRODUK
  // ==================================================

  Future<void> _bukaForm({Map<String, dynamic>? item}) async {
    debugPrint('MEMBUKA FORM TAMBAH / EDIT PRODUK');
    debugPrint('MODE EDIT: ${item != null}');

    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TambahProdukScreen(product: item)),
    );

    debugPrint('HASIL DARI FORM: $hasil');

    if (!mounted) return;

    if (hasil == true) {
      debugPrint('MEMUAT ULANG DAFTAR PRODUK');
      await _ambilProduk();
    }
  }

  // ==================================================
  // HAPUS PRODUK
  // ==================================================
  Future<void> _hapusProduk(Map<String, dynamic> item) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(
          'Apakah kamu yakin ingin menghapus '
          '"${item['nama_produk']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (setuju != true) return;

    final user = supabase.auth.currentUser;

    if (user == null) {
      _tampilkanPesan('Sesi login tidak ditemukan.');
      return;
    }

    try {
      await supabase
          .from('products')
          .delete()
          .eq('id', item['id'])
          .eq('seller_id', user.id);

      if (!mounted) return;

      _tampilkanPesan('Produk berhasil dihapus.');

      await _ambilProduk();
    } on PostgrestException catch (e) {
      _tampilkanPesan('Gagal menghapus produk: ${e.message}');
    } catch (e) {
      _tampilkanPesan('Gagal menghapus produk: $e');
    }
  }

  // ==================================================
  // FORMAT HARGA
  // ==================================================
  String _formatHarga(dynamic harga) {
    final nilai = double.tryParse(harga.toString()) ?? 0;

    return 'Rp ${nilai.toStringAsFixed(0)}';
  }

  // ==================================================
  // FORMAT VARIAN
  // ==================================================
  String _formatVarian(dynamic dataVarian) {
    if (dataVarian == null) return '';

    if (dataVarian is List) {
      return dataVarian
          .map((v) => v.toString())
          .where((v) => v.trim().isNotEmpty)
          .join(', ');
    }

    // Mendukung data lama yang tersimpan sebagai teks.
    return dataVarian.toString().trim();
  }

  // ==================================================
  // PESAN
  // ==================================================
  void _tampilkanPesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // ==================================================
  // TAMPILAN UTAMA
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      body: RefreshIndicator(
        onRefresh: _ambilProduk,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // JUDUL DAN TOMBOL TAMBAH
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Produk Saya',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _bukaForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hijau,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              'Kelola produk yang ditampilkan kepada pembeli.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // KONDISI LOADING
            if (loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: hijau)),
              )
            // KONDISI ERROR
            else if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 44,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _ambilProduk,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            // KONDISI PRODUK KOSONG
            else if (produk.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 56,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Produk',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan produk UMKM agar dapat '
                      'ditampilkan di katalog pembeli.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              )
            // DAFTAR PRODUK
            else
              ...produk.map((item) {
                final foto = item['foto_url']?.toString() ?? '';

                final stok = item['stok'] ?? 0;

                // TAMBAHAN VARIAN PRODUK
                final teksVarian = _formatVarian(item['varian']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FOTO PRODUK
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 82,
                          height: 82,
                          child: foto.isNotEmpty
                              ? Image.network(
                                  foto,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _placeholderFoto();
                                  },
                                )
                              : _placeholderFoto(),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // INFORMASI PRODUK
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NAMA PRODUK
                            Text(
                              item['nama_produk']?.toString() ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // KATEGORI
                            Text(
                              item['kategori']?.toString() ?? '-',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // HARGA
                            Text(
                              _formatHarga(item['harga']),
                              style: const TextStyle(
                                color: hijau,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // STOK
                            Text(
                              'Stok: $stok',
                              style: const TextStyle(fontSize: 12),
                            ),

                            // VARIAN
                            if (teksVarian.isNotEmpty && teksVarian != '[]')
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Varian: $teksVarian',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                            // DESKRIPSI
                            if ((item['deskripsi']?.toString() ?? '')
                                .trim()
                                .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  item['deskripsi'].toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // MENU EDIT DAN HAPUS
                      PopupMenuButton<String>(
                        onSelected: (pilihan) {
                          if (pilihan == 'edit') {
                            _bukaForm(item: item);
                          } else if (pilihan == 'hapus') {
                            _hapusProduk(item);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit Produk'),
                          ),
                          PopupMenuItem(
                            value: 'hapus',
                            child: Text('Hapus Produk'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // FOTO PENGGANTI JIKA FOTO TIDAK TERSEDIA
  // ==================================================
  Widget _placeholderFoto() {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 32, color: Colors.grey.shade400),
    );
  }
}
