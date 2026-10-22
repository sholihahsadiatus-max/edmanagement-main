import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'succes_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int totalPrice;
  final List<Map<String, dynamic>> orderItems;

  const CheckoutScreen({
    super.key,
    required this.totalPrice,
    required this.orderItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Color primaryColor = const Color(0xFF006B42);
  final Color backgroundColor = const Color(0xFFF5F7F6);

  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  bool _isLoadingProfile = true;
  bool _isProcessing = false;
  bool _isOpeningWhatsApp = false;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    _loadBuyerProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  String formatRupiah(int price) {
    return 'Rp${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _itemName(Map<String, dynamic> item) {
    return (item['name'] ?? item['nama_produk'] ?? item['nama'] ?? 'Produk')
        .toString();
  }

  String _itemVariant(Map<String, dynamic> item) {
    return (item['variant'] ?? item['varian'] ?? 'Default').toString();
  }

  String _itemStoreName(Map<String, dynamic> item) {
    return (item['nama_toko'] ??
            item['namaToko'] ??
            item['seller_name'] ??
            item['nama_penjual'] ??
            item['nama_toko_penjual'] ??
            'Toko UMKM')
        .toString();
  }

  String _itemImage(Map<String, dynamic> item) {
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

  int _itemQuantity(Map<String, dynamic> item) {
    final quantity = _toInt(item['qty'] ?? item['quantity']);
    return quantity < 1 ? 1 : quantity;
  }

  int _itemUnitPrice(Map<String, dynamic> item) {
    return _toInt(
      item['unitPrice'] ?? item['unit_price'] ?? item['price'] ?? item['harga'],
    );
  }

  int _itemSubtotal(Map<String, dynamic> item) {
    final subtotal = item['lineTotal'] ?? item['subtotal'];

    if (subtotal != null) {
      return _toInt(subtotal);
    }

    return _itemUnitPrice(item) * _itemQuantity(item);
  }

  // Mengambil ID penjual dari data produk.
  String _itemSellerId(Map<String, dynamic> item) {
    return (item['seller_id'] ?? item['sellerId'] ?? item['penjual_id'] ?? '')
        .toString()
        .trim();
  }

  Future<void> _loadBuyerProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoadingProfile = false;
        _profileError = 'Silakan login terlebih dahulu.';
      });
      return;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select('nama, no_handphone, alamat')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (response == null) {
        setState(() {
          _isLoadingProfile = false;
          _profileError =
              'Data profil belum tersedia. Silakan lengkapi profil.';
        });
        return;
      }

      setState(() {
        _namaController.text = (response['nama'] ?? '').toString();
        _teleponController.text = (response['no_handphone'] ?? '').toString();
        _alamatController.text = (response['alamat'] ?? '').toString();

        _isLoadingProfile = false;
        _profileError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingProfile = false;
        _profileError = 'Gagal mengambil profil pembeli.';
      });

      debugPrint('Gagal memuat profil checkout: $error');
    }
  }

  Future<void> _saveAddress({
    required String nama,
    required String telepon,
    required String alamat,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Silakan login kembali.');
    }

    await supabase
        .from('profiles')
        .update({'nama': nama, 'no_handphone': telepon, 'alamat': alamat})
        .eq('id', user.id);

    if (!mounted) return;

    setState(() {
      _namaController.text = nama;
      _teleponController.text = telepon;
      _alamatController.text = alamat;
    });
  }

  Future<void> _showEditAddressDialog() async {
    final namaController = TextEditingController(text: _namaController.text);
    final teleponController = TextEditingController(
      text: _teleponController.text,
    );
    final alamatController = TextEditingController(
      text: _alamatController.text,
    );

    final formKey = GlobalKey<FormState>();

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          bool saving = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Ubah Alamat Pembeli'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: namaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama penerima',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama penerima wajib diisi.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: teleponController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Nomor telepon',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nomor telepon wajib diisi.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: alamatController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Alamat lengkap',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Alamat wajib diisi.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              await _saveAddress(
                                nama: namaController.text.trim(),
                                telepon: teleponController.text.trim(),
                                alamat: alamatController.text.trim(),
                              );

                              if (!mounted) return;
                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext);

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Alamat berhasil diperbarui.'),
                                ),
                              );
                            } catch (error) {
                              if (!dialogContext.mounted) return;

                              setDialogState(() {
                                saving = false;
                              });

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal menyimpan alamat: $error',
                                  ),
                                ),
                              );
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      namaController.dispose();
      teleponController.dispose();
      alamatController.dispose();
    }
  }

  // =========================================================
  // WHATSAPP CHECKOUT
  // =========================================================

  Future<void> _openWhatsAppOrders() async {
    if (_isOpeningWhatsApp) return;

    if (_isLoadingProfile || _profileError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pastikan profil pembeli sudah dimuat.')),
      );
      return;
    }

    if (widget.orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada produk untuk dipesan.')),
      );
      return;
    }

    // Kelompokkan produk berdasarkan seller_id.
    final Map<String, List<Map<String, dynamic>>> groupedItems = {};

    for (final item in widget.orderItems) {
      final sellerId = _itemSellerId(item);

      if (sellerId.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ID penjual produk "${_itemName(item)}" tidak ditemukan. '
              'Periksa data produk dan keranjang.',
            ),
          ),
        );
        return;
      }

      groupedItems.putIfAbsent(sellerId, () => []);
      groupedItems[sellerId]!.add(item);
    }

    setState(() {
      _isOpeningWhatsApp = true;
    });

    try {
      final List<Map<String, dynamic>> destinations = [];

      // Cari nomor WhatsApp masing-masing penjual.
      for (final entry in groupedItems.entries) {
        final profile = await supabase
            .from('profiles')
            .select('id, nama, no_handphone')
            .eq('id', entry.key)
            .maybeSingle();

        if (profile == null) {
          continue;
        }

        final phone = (profile['no_handphone'] ?? '').toString().trim();

        if (phone.isEmpty) {
          continue;
        }

        destinations.add({
          'seller_id': entry.key,
          'seller_name': profile['nama'] ?? 'Penjual',
          'phone': phone,
          'items': entry.value,
        });
      }

      if (!mounted) return;

      if (destinations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nomor WhatsApp penjual tidak ditemukan. '
              'Periksa profil dan izin akses Supabase.',
            ),
          ),
        );
        return;
      }

      // Jika hanya satu penjual, langsung buka WhatsApp.
      if (destinations.length == 1) {
        await _launchSellerWhatsApp(destinations.first);
        return;
      }

      // Jika banyak penjual, pembeli memilih penjual tujuan.
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Pilih Penjual'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  final items =
                      destination['items'] as List<Map<String, dynamic>>;

                  return ListTile(
                    leading: Icon(Icons.storefront, color: primaryColor),
                    title: Text(destination['seller_name'].toString()),
                    subtitle: Text('${items.length} jenis produk'),
                    trailing: Icon(Icons.chat, color: primaryColor),
                    onTap: () {
                      Navigator.pop(dialogContext);

                      _launchSellerWhatsApp(destination);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data WhatsApp penjual: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningWhatsApp = false;
        });
      }
    }
  }

  Future<void> _launchSellerWhatsApp(Map<String, dynamic> destination) async {
    var phone = destination['phone'].toString().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    // Normalisasi nomor Indonesia.
    if (phone.startsWith('0062')) {
      phone = phone.substring(2);
    } else if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    } else if (phone.startsWith('8')) {
      phone = '62$phone';
    }

    if (phone.length < 10) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format nomor WhatsApp penjual tidak valid.'),
        ),
      );
      return;
    }

    final items = destination['items'] as List<Map<String, dynamic>>;

    final message = StringBuffer()
      ..writeln('Halo ${destination['seller_name']},')
      ..writeln()
      ..writeln(
        'Saya ingin memesan produk dari Marketplace UMKM ED Management.',
      )
      ..writeln()
      ..writeln('Detail pesanan:')
      ..writeln('Nama pembeli: ${_namaController.text.trim()}')
      ..writeln('Telepon pembeli: ${_teleponController.text.trim()}')
      ..writeln('Alamat: ${_alamatController.text.trim()}')
      ..writeln();

    var total = 0;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final quantity = _itemQuantity(item);
      final unitPrice = _itemUnitPrice(item);
      final subtotal = unitPrice * quantity;

      total += subtotal;

      message
        ..writeln('${i + 1}. ${_itemName(item)}')
        ..writeln('   Varian: ${_itemVariant(item)}')
        ..writeln('   Harga satuan: ${formatRupiah(unitPrice)}')
        ..writeln('   Jumlah: $quantity')
        ..writeln('   Subtotal: ${formatRupiah(subtotal)}')
        ..writeln();
    }

    message
      ..writeln('Total produk toko ini: ${formatRupiah(total)}')
      ..writeln('Ongkos kirim: Rp0')
      ..writeln()
      ..writeln('Mohon konfirmasi ketersediaan produk. Terima kasih.');

    final uri = Uri.https('wa.me', '/$phone', {'text': message.toString()});

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'WhatsApp tidak dapat dibuka. '
              'Periksa koneksi internet atau aplikasi WhatsApp.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka WhatsApp: $error')));
    }
  }

  // =========================================================
  // GAMBAR PRODUK
  // =========================================================

  Widget _buildProductImage(String imagePath) {
    if (imagePath.isEmpty) {
      return _imagePlaceholder();
    }

    if (imagePath.startsWith('https://') || imagePath.startsWith('http://')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    return Image.asset(
      imagePath,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _imagePlaceholder();
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 32,
        color: Colors.grey.shade500,
      ),
    );
  }

  // =========================================================
  // ALAMAT PEMBELI
  // =========================================================

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: primaryColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Alamat Pembeli',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: _isLoadingProfile ? null : _showEditAddressDialog,
                child: const Text('Ubah'),
              ),
            ],
          ),
          const Divider(height: 20),
          if (_isLoadingProfile)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_profileError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profileError!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _loadBuyerProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            )
          else ...[
            Text(
              _namaController.text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _teleponController.text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              _alamatController.text,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // PRODUK YANG DIBELI
  // =========================================================

  Widget _buildProductCard(Map<String, dynamic> item) {
    final name = _itemName(item);
    final storeName = _itemStoreName(item);
    final variant = _itemVariant(item);
    final image = _itemImage(item);
    final quantity = _itemQuantity(item);
    final unitPrice = _itemUnitPrice(item);
    final subtotal = _itemSubtotal(item);

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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 82,
              height: 96,
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
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 15,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Varian: $variant',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Text(
                  '${formatRupiah(unitPrice)} × $quantity',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 7),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatRupiah(subtotal),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // RINGKASAN PEMBAYARAN
  // =========================================================

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pembayaran',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total harga produk',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Text(
                formatRupiah(widget.totalPrice),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text('Ongkos kirim', style: TextStyle(fontSize: 13)),
              ),
              Text('Rp0', style: TextStyle(fontSize: 13, color: primaryColor)),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Pembayaran',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                formatRupiah(widget.totalPrice),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUAT PESANAN LAMA - TETAP DIPERTAHANKAN
  // =========================================================

  // =========================================================
  // BUAT PESANAN - REVISI: SIMPAN KE SUPABASE
  // =========================================================

  Future<void> _buatPesanan() async {
    debugPrint('CHECKOUT 1: Fungsi _buatPesanan dimulai');

    // Mencegah pesanan dikirim berulang kali.
    if (_isProcessing) {
      debugPrint('CHECKOUT: Proses pesanan masih berjalan.');
      return;
    }

    // Validasi profil pembeli.
    if (_isLoadingProfile || _profileError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pastikan profil pembeli sudah berhasil dimuat.'),
        ),
      );
      return;
    }

    // Validasi keranjang.
    if (widget.orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada produk untuk dipesan.')),
      );
      return;
    }

    // Validasi nama, telepon, dan alamat.
    final nama = _namaController.text.trim();
    final telepon = _teleponController.text.trim();
    final alamat = _alamatController.text.trim();

    if (nama.isEmpty || telepon.isEmpty || alamat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi nama, nomor telepon, dan alamat.'),
        ),
      );
      return;
    }

    // Pastikan pembeli sudah login.
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login berakhir. Silakan login kembali.'),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      debugPrint('CHECKOUT 2: Menyiapkan data pesanan');

      // Siapkan data produk untuk fungsi RPC Supabase.
      final List<Map<String, dynamic>> items = [];

      debugPrint('DATA ORDER ITEMS: ${widget.orderItems}');

      for (final item in widget.orderItems) {
        final sellerId = _itemSellerId(item);

        if (sellerId.isEmpty) {
          throw Exception(
            'ID penjual produk "${_itemName(item)}" tidak ditemukan. '
            'Periksa data produk dan keranjang.',
          );
        }

        final quantity = _itemQuantity(item);
        final unitPrice = _itemUnitPrice(item);

        if (unitPrice <= 0) {
          throw Exception('Harga produk "${_itemName(item)}" tidak valid.');
        }

        // Pertahankan ID produk jika tersedia di data keranjang.
        final productId =
            item['product_id'] ??
            item['productId'] ??
            item['produk_id'] ??
            item['id_produk'] ??
            item['id'];
        // TAMBAHAN: periksa ID sebelum dikirim ke Supabase.
        debugPrint('ID PRODUK YANG DIKIRIM: $productId');
        debugPrint('ID PENJUAL YANG DIKIRIM: $sellerId');

        if (unitPrice <= 0) {
          throw Exception('Harga produk "${_itemName(item)}" tidak valid.');
        }

        items.add({
          'seller_id': sellerId,
          'product_id': productId,
          'name': _itemName(item),
          'variant': _itemVariant(item),
          'quantity': quantity,
          'unit_price': unitPrice,
          'image': _itemImage(item),
        });
      }

      debugPrint('CHECKOUT 3: Mengirim ${items.length} item ke Supabase');

      // Simpan pesanan melalui fungsi SQL buat_pesanan.
      final response = await supabase.rpc(
        'buat_pesanan',
        params: {
          'p_nama': nama,
          'p_telepon': telepon,
          'p_alamat': alamat,
          'p_items': items,
        },
      );

      debugPrint('CHECKOUT 4: Respons Supabase = $response');

      // Fungsi SQL harus mengembalikan ID pesanan.
      if (response is! List || response.isEmpty) {
        throw Exception(
          'Pesanan belum dapat dikonfirmasi. '
          'Periksa fungsi SQL buat_pesanan di Supabase.',
        );
      }

      final orderIds = response.map((id) => id.toString()).toList();

      debugPrint(
        'CHECKOUT 5: Pesanan berhasil disimpan. '
        'ID pesanan = $orderIds',
      );

      if (!mounted) return;

      // Buka halaman sukses hanya setelah RPC berhasil.
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(orderIds: orderIds),
        ),
      );
    } on PostgrestException catch (error) {
      debugPrint('CHECKOUT ERROR SUPABASE: ${error.message}');
      debugPrint('CHECKOUT ERROR CODE: ${error.code}');
      debugPrint('CHECKOUT ERROR DETAILS: ${error.details}');
      debugPrint('CHECKOUT ERROR HINT: ${error.hint}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pesanan: ${error.message}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('CHECKOUT ERROR: $error');
      debugPrint('CHECKOUT STACKTRACE: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan gagal diproses: $error'),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // =========================================================
  // TAMPILAN CHECKOUT
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddressSection(),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Produk yang Dibeli',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ...widget.orderItems.map(_buildProductCard),
          const SizedBox(height: 6),
          _buildPaymentSummary(),
          const SizedBox(height: 110),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol WhatsApp baru.
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: (_isOpeningWhatsApp || _isProcessing)
                      ? null
                      : _openWhatsAppOrders,
                  icon: _isOpeningWhatsApp
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chat),
                  label: Text(
                    _isOpeningWhatsApp
                        ? 'Menyiapkan WhatsApp...'
                        : 'Pesan via WhatsApp',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Bagian total dan tombol lama tetap ada.
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah(widget.totalPrice),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _buatPesanan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Buat Pesanan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
