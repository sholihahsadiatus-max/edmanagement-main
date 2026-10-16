import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahProdukScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const TambahProdukScreen({super.key, this.product});

  @override
  State<TambahProdukScreen> createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  static const Color hijau = Color(0xFF006B42);
  static const Color latar = Color(0xFFF5F7F6);

  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _varianController = TextEditingController();

  final List<String> _kategoriList = [
    'Makanan',
    'Minuman',
    'Kerajinan',
    'Fashion',
    'Lainnya',
  ];

  String? _kategori;
  XFile? _fotoFile;
  Uint8List? _fotoBytes;
  String? _fotoLama;

  bool _loading = false;

  bool get _modeEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    final p = widget.product;

    if (p != null) {
      _namaController.text = p['nama_produk']?.toString() ?? '';

      _hargaController.text = p['harga']?.toString() ?? '';

      _stokController.text = p['stok']?.toString() ?? '';

      _deskripsiController.text = p['deskripsi']?.toString() ?? '';

      final kategoriLama = p['kategori']?.toString();

      if (_kategoriList.contains(kategoriLama)) {
        _kategori = kategoriLama;
      }

      _fotoLama = p['foto_url']?.toString();

      final dataVarian = p['varian'];

      if (dataVarian is List) {
        _varianController.text = dataVarian.map((v) => v.toString()).join(', ');
      } else if (dataVarian is String) {
        _varianController.text = dataVarian;
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    _varianController.dispose();

    super.dispose();
  }

  // ==================================================
  // PESAN APLIKASI
  // ==================================================

  void _pesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(pesan), duration: const Duration(seconds: 5)),
      );
  }

  // ==================================================
  // PILIH FOTO
  // ==================================================

  Future<void> _pilihFoto() async {
    try {
      final hasil = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (hasil == null) return;

      final bytes = await hasil.readAsBytes();

      if (!mounted) return;

      setState(() {
        _fotoFile = hasil;
        _fotoBytes = bytes;
      });

      debugPrint('FOTO DIPILIH: ${hasil.name}');
    } catch (e, stackTrace) {
      debugPrint('ERROR PILIH FOTO: $e');
      debugPrintStack(stackTrace: stackTrace);

      _pesan('Gagal memilih foto: $e');
    }
  }

  // ==================================================
  // UPLOAD FOTO KE SUPABASE STORAGE
  // ==================================================

  Future<String?> _uploadFoto(String userId) async {
    // Jika tidak memilih foto baru, gunakan foto lama.
    if (_fotoFile == null || _fotoBytes == null) {
      return _fotoLama;
    }

    final namaFile = _fotoFile!.name;

    final ekstensi = namaFile.contains('.')
        ? namaFile.split('.').last.toLowerCase()
        : 'jpg';

    final contentType = switch (ekstensi) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };

    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ekstensi';

    debugPrint('MULAI UPLOAD FOTO: $path');

    await supabase.storage
        .from('product-images')
        .uploadBinary(
          path,
          _fotoBytes!,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

    final fotoUrl = supabase.storage.from('product-images').getPublicUrl(path);

    debugPrint('UPLOAD FOTO BERHASIL: $fotoUrl');

    return fotoUrl;
  }

  // ==================================================
  // FORMAT VARIAN
  // ==================================================

  List<String> _ambilVarian() {
    return _varianController.text
        .split(',')
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList();
  }

  // ==================================================
  // SIMPAN PRODUK
  // ==================================================

  Future<void> _simpanProduk() async {
    debugPrint('================================');
    debugPrint('TOMBOL SIMPAN PRODUK DITEKAN');
    debugPrint('MODE EDIT: $_modeEdit');

    // Periksa validasi formulir.
    if (!_formKey.currentState!.validate()) {
      debugPrint('VALIDASI FORMULIR GAGAL');
      _pesan('Periksa kembali data produk yang wajib diisi.');
      return;
    }

    final user = supabase.auth.currentUser;

    debugPrint('USER ID: ${user?.id}');
    debugPrint('NAMA PRODUK: ${_namaController.text}');
    debugPrint('KATEGORI: $_kategori');
    debugPrint('HARGA: ${_hargaController.text}');
    debugPrint('STOK: ${_stokController.text}');
    debugPrint('VARIAN: ${_ambilVarian()}');

    if (user == null) {
      debugPrint('ERROR: USER BELUM LOGIN');
      _pesan('Sesi login tidak ditemukan. Silakan login kembali.');
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {
      // 1. Upload foto jika dipilih.
      final fotoUrl = await _uploadFoto(user.id);

      // 2. Siapkan data untuk database.
      final harga = double.parse(
        _hargaController.text.trim().replaceAll(',', '.'),
      );

      final stok = int.parse(_stokController.text.trim());

      final Map<String, dynamic> data = {
        'nama_produk': _namaController.text.trim(),
        'kategori': _kategori,
        'harga': harga,
        'stok': stok,
        'deskripsi': _deskripsiController.text.trim(),
        'varian': _ambilVarian(),
        'foto_url': fotoUrl,
      };

      debugPrint('DATA YANG AKAN DISIMPAN: $data');

      // 3. Tambah atau edit produk.
      if (_modeEdit) {
        debugPrint('MULAI MEMPERBARUI PRODUK');

        final hasil = await supabase
            .from('products')
            .update(data)
            .eq('id', widget.product!['id'])
            .eq('seller_id', user.id)
            .select();

        debugPrint('HASIL UPDATE PRODUK: $hasil');

        if (hasil.isEmpty) {
          throw Exception(
            'Tidak ada produk yang diperbarui. '
            'Periksa ID produk dan izin akses penjual.',
          );
        }
      } else {
        debugPrint('MULAI MENAMBAHKAN PRODUK');

        data['seller_id'] = user.id;

        // SELECT digunakan untuk memastikan hasil insert
        // dikembalikan oleh Supabase.
        final hasil = await supabase.from('products').insert(data).select();

        debugPrint('HASIL INSERT PRODUK: $hasil');

        if (hasil.isEmpty) {
          throw Exception(
            'Supabase tidak mengembalikan data produk '
            'setelah penyimpanan.',
          );
        }
      }

      if (!mounted) return;

      debugPrint('SIMPAN PRODUK BERHASIL');

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _modeEdit
                  ? 'Produk berhasil diperbarui.'
                  : 'Produk berhasil ditambahkan.',
            ),
            backgroundColor: hijau,
          ),
        );

      // Kirim true agar Kelola Produk memuat ulang daftar.
      Navigator.pop(context, true);
    } on StorageException catch (e, stackTrace) {
      debugPrint('ERROR STORAGE: ${e.message}');
      debugPrint('DETAIL STORAGE: ${e.error}');
      debugPrintStack(stackTrace: stackTrace);

      _pesan('Gagal mengunggah foto: ${e.message}');
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('ERROR DATABASE: ${e.message}');
      debugPrint('KODE DATABASE: ${e.code}');
      debugPrint('DETAIL DATABASE: ${e.details}');
      debugPrint('HINT DATABASE: ${e.hint}');
      debugPrintStack(stackTrace: stackTrace);

      _pesan('Gagal menyimpan produk: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('ERROR LAINNYA: $e');
      debugPrintStack(stackTrace: stackTrace);

      _pesan('Gagal menyimpan produk: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }

      debugPrint('PROSES SIMPAN PRODUK SELESAI');
      debugPrint('================================');
    }
  }

  // ==================================================
  // KOMPONEN INPUT
  // ==================================================

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: hijau),
            ),
          ),
        ),
      ],
    );
  }

  // ==================================================
  // TAMPILAN FORM TAMBAH / EDIT PRODUK
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Produk' : 'Tambah Produk'),
        backgroundColor: hijau,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // FOTO PRODUK
            const Text(
              'Foto Produk',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: _loading ? null : _pilihFoto,
              child: Container(
                height: 190,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _fotoBytes != null
                    ? Image.memory(
                        _fotoBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : (_fotoLama != null && _fotoLama!.isNotEmpty)
                    ? Image.network(
                        _fotoLama!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _placeholderFoto();
                        },
                      )
                    : _placeholderFoto(),
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: _loading ? null : _pilihFoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Pilih Foto dari Galeri'),
              style: OutlinedButton.styleFrom(
                foregroundColor: hijau,
                padding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 22),

            // NAMA PRODUK
            _field(
              label: 'Nama Produk',
              controller: _namaController,
              hint: 'Contoh: Keripik Pisang',
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nama produk wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            // KATEGORI
            const Text(
              'Kategori',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: InputDecoration(
                hintText: 'Pilih kategori produk',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _kategoriList.map((kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: _loading
                  ? null
                  : (value) {
                      setState(() {
                        _kategori = value;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return 'Pilih kategori produk';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            // HARGA
            _field(
              label: 'Harga (Rp)',
              controller: _hargaController,
              hint: 'Contoh: 17000',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final harga = double.tryParse(
                  (v ?? '').trim().replaceAll(',', '.'),
                );

                if (harga == null || harga <= 0) {
                  return 'Masukkan harga yang valid';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // STOK
            _field(
              label: 'Stok Produk',
              controller: _stokController,
              hint: 'Contoh: 50',
              keyboardType: TextInputType.number,
              validator: (v) {
                final stok = int.tryParse((v ?? '').trim());

                if (stok == null || stok < 0) {
                  return 'Stok harus berupa angka 0 atau lebih';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // VARIAN
            _field(
              label: 'Varian Produk (Opsional)',
              controller: _varianController,
              hint: 'Contoh: 250 gram, 500 gram, 1 kg',
              maxLines: 2,
            ),

            const SizedBox(height: 6),

            const Text(
              'Pisahkan setiap varian dengan tanda koma (,). '
              'Contoh: Hitam, Cokelat, Putih.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 18),

            // DESKRIPSI
            _field(
              label: 'Deskripsi Produk',
              controller: _deskripsiController,
              hint: 'Jelaskan detail dan keunggulan produk...',
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Deskripsi produk wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            // TOMBOL SIMPAN
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () {
                        debugPrint('TOMBOL SIMPAN DIKLIK');
                        _simpanProduk();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: hijau,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: hijau.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _modeEdit ? 'Simpan Perubahan' : 'Simpan Produk',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // FOTO PENGGANTI
  // ==================================================

  Widget _placeholderFoto() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan foto produk',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
