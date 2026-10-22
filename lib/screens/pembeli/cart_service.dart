import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  final List<Map<String, dynamic>> items = [];

  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? get _buyerId => _supabase.auth.currentUser?.id;

  Future<void> _saveQueue = Future<void>.value();

  // ==================================================
  // KONVERSI HARGA
  // ==================================================

  int _convertPrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  // ==================================================
  // MEMASTIKAN ID PRODUK
  // ==================================================

  String _getProductId(Map<String, dynamic> item) {
    final id = item['product_id'] ?? item['id'];

    if (id != null && id.toString().trim().isNotEmpty) {
      return id.toString();
    }

    // Cadangan jika produk tidak mempunyai ID.
    return (item['name'] ?? item['nama_produk'] ?? item['nama'] ?? 'Produk')
        .toString();
  }

  // ==================================================
  // MENYIMPAN PROSES SECARA BERURUTAN
  // ==================================================

  Future<void> _queueSave(Future<void> Function() action) {
    _saveQueue = _saveQueue.then((_) => action()).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      debugPrint('Gagal menyimpan keranjang: $error');
    });

    return _saveQueue;
  }

  Future<void> waitForPendingSaves() async {
    await _saveQueue;
  }

  // ==================================================
  // MEMUAT KERANJANG DARI SUPABASE
  // ==================================================

  Future<void> loadCart() async {
    final buyerId = _buyerId;

    if (buyerId == null) {
      items.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('cart_items')
          .select()
          .eq('buyer_id', buyerId);

      final loadedItems = <Map<String, dynamic>>[];

      for (final row in response) {
        final data = Map<String, dynamic>.from(row);

        final dynamic rawProductData = data['product_data'];

        final productData = rawProductData is Map
            ? Map<String, dynamic>.from(rawProductData)
            : <String, dynamic>{};

        final productId = data['product_id']?.toString() ?? '';
        final variant = data['variant']?.toString() ?? 'Default';

        // Pertahankan data produk dan isi dengan data terbaru
        // dari kolom keranjang.
        productData['id'] ??= productId;
        productData['name'] ??=
            productData['nama_produk'] ?? productData['nama'] ?? 'Produk';
        productData['variant'] = variant;
        productData['price'] = _convertPrice(
          productData['price'] ?? productData['harga'],
        );
        productData['quantity'] = data['quantity'] ?? 1;
        productData['isSelected'] = data['is_selected'] ?? true;
        productData['image'] ??=
            productData['foto_url'] ?? productData['gambar'] ?? '';

        loadedItems.add(productData);
      }

      items
        ..clear()
        ..addAll(loadedItems);
    } catch (error) {
      debugPrint('Gagal memuat keranjang: $error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================================================
  // MENYIMPAN SATU PRODUK KE SUPABASE
  // ==================================================

  Future<void> _persistItem(Map<String, dynamic> item) async {
    final buyerId = _buyerId;

    if (buyerId == null) {
      debugPrint('Keranjang belum disimpan: pembeli belum login.');
      return;
    }

    final productId = _getProductId(item);
    final variant = (item['variant'] ?? 'Default').toString();

    // Jangan ikut menyimpan data internal keranjang ke JSON produk.
    final productData = Map<String, dynamic>.from(item)
      ..remove('quantity')
      ..remove('isSelected');

    await _supabase.from('cart_items').upsert({
      'buyer_id': buyerId,
      'product_id': productId,
      'variant': variant,
      'quantity': _convertPrice(item['quantity']) < 1
          ? 1
          : _convertPrice(item['quantity']),
      'is_selected': item['isSelected'] ?? true,
      'product_data': productData,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'buyer_id,product_id,variant');
  }

  // ==================================================
  // MENGHAPUS PRODUK DARI SUPABASE
  // ==================================================

  Future<void> _deletePersistedItem(Map<String, dynamic> item) async {
    final buyerId = _buyerId;

    if (buyerId == null) return;

    await _supabase
        .from('cart_items')
        .delete()
        .eq('buyer_id', buyerId)
        .eq('product_id', _getProductId(item))
        .eq('variant', (item['variant'] ?? 'Default').toString());
  }

  // ==================================================
  // MENAMBAHKAN PRODUK KE KERANJANG
  // ==================================================

  void addProduct(Map<String, dynamic> product, {int quantity = 1}) {
    final name =
        (product['name'] ??
                product['nama_produk'] ??
                product['nama'] ??
                'Produk')
            .toString();

    final variant = (product['variant'] ?? product['varian'] ?? 'Default')
        .toString();

    final image =
        (product['image'] ?? product['foto_url'] ?? product['gambar'] ?? '')
            .toString();

    final price = _convertPrice(product['price'] ?? product['harga']);

    final productId = _getProductId(product);

    final existingIndex = items.indexWhere((item) {
      final sameId = _getProductId(item) == productId;

      final sameVariant = (item['variant'] ?? 'Default').toString() == variant;

      return sameId && sameVariant;
    });

    if (existingIndex != -1) {
      final currentQuantity = _convertPrice(items[existingIndex]['quantity']);

      items[existingIndex]['quantity'] =
          currentQuantity + (quantity < 1 ? 1 : quantity);

      items[existingIndex]['isSelected'] = true;
    } else {
      final newItem = Map<String, dynamic>.from(product);

      newItem['id'] = product['id'] ?? productId;
      newItem['name'] = name;
      newItem['variant'] = variant;
      newItem['price'] = price;
      newItem['quantity'] = quantity < 1 ? 1 : quantity;
      newItem['image'] = image;
      newItem['isSelected'] = true;

      items.add(newItem);
    }

    notifyListeners();

    final savedItem = Map<String, dynamic>.from(
      items.firstWhere(
        (item) =>
            _getProductId(item) == productId &&
            (item['variant'] ?? 'Default').toString() == variant,
      ),
    );

    unawaited(_queueSave(() => _persistItem(savedItem)));
  }

  // ==================================================
  // MEMPERBARUI JUMLAH PRODUK
  // ==================================================

  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= items.length) return;
    if (quantity < 1) return;

    items[index]['quantity'] = quantity;

    notifyListeners();

    final savedItem = Map<String, dynamic>.from(items[index]);

    unawaited(_queueSave(() => _persistItem(savedItem)));
  }

  // ==================================================
  // MENAMBAH JUMLAH
  // ==================================================

  void increaseQuantity(int index) {
    if (index < 0 || index >= items.length) return;

    final quantity = _convertPrice(items[index]['quantity']);

    updateQuantity(index, quantity + 1);
  }

  // ==================================================
  // MENGURANGI JUMLAH
  // ==================================================

  void decreaseQuantity(int index) {
    if (index < 0 || index >= items.length) return;

    final quantity = _convertPrice(items[index]['quantity']);

    if (quantity > 1) {
      updateQuantity(index, quantity - 1);
    }
  }

  // ==================================================
  // MEMILIH / MEMBATALKAN PILIHAN PRODUK
  // ==================================================

  void toggleSelected(int index, bool selected) {
    if (index < 0 || index >= items.length) return;

    items[index]['isSelected'] = selected;

    notifyListeners();

    final savedItem = Map<String, dynamic>.from(items[index]);

    unawaited(_queueSave(() => _persistItem(savedItem)));
  }

  // ==================================================
  // MENGHAPUS SATU PRODUK
  // ==================================================

  void removeProduct(int index) {
    if (index < 0 || index >= items.length) return;

    final removedItem = Map<String, dynamic>.from(items[index]);

    items.removeAt(index);

    notifyListeners();

    unawaited(_queueSave(() => _deletePersistedItem(removedItem)));
  }

  // ==================================================
  // MENGHAPUS BEBERAPA PRODUK TERPILIH
  // ==================================================

  void removeSelectedItems(List<Map<String, dynamic>> selectedItems) {
    if (selectedItems.isEmpty) return;

    final removedItems = selectedItems
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    items.removeWhere((item) => selectedItems.contains(item));

    notifyListeners();

    unawaited(
      _queueSave(() async {
        for (final item in removedItems) {
          await _deletePersistedItem(item);
        }
      }),
    );
  }
}
