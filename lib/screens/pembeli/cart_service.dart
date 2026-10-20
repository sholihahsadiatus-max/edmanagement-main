import 'package:flutter/foundation.dart';

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  final List<Map<String, dynamic>> items = [];

  // Mengubah harga menjadi angka.
  int _convertPrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  // Menambahkan produk ke keranjang.
  // Produk yang sama akan menambah jumlah, bukan membuat duplikat.
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

    final productId = product['id']?.toString();

    final existingIndex = items.indexWhere((item) {
      final sameId =
          productId != null &&
          productId.isNotEmpty &&
          item['id']?.toString() == productId;

      final sameNameAndVariant =
          item['name'].toString() == name &&
          item['variant'].toString() == variant;

      return sameId || sameNameAndVariant;
    });

    if (existingIndex != -1) {
      final currentQuantity = items[existingIndex]['quantity'] as int;

      items[existingIndex]['quantity'] = currentQuantity + quantity;

      items[existingIndex]['isSelected'] = true;
    } else {
      final newItem = Map<String, dynamic>.from(product);

      newItem['name'] = name;
      newItem['variant'] = variant;
      newItem['price'] = price;
      newItem['quantity'] = quantity < 1 ? 1 : quantity;
      newItem['image'] = image;
      newItem['isSelected'] = true;

      items.add(newItem);
    }

    notifyListeners();
  }

  // Mengubah status pilihan produk.
  void toggleSelected(int index, bool selected) {
    items[index]['isSelected'] = selected;
    notifyListeners();
  }

  // Menambah jumlah produk.
  void increaseQuantity(int index) {
    items[index]['quantity'] = (items[index]['quantity'] as int) + 1;

    notifyListeners();
  }

  // Mengurangi jumlah produk, minimal 1.
  void decreaseQuantity(int index) {
    final quantity = items[index]['quantity'] as int;

    if (quantity > 1) {
      items[index]['quantity'] = quantity - 1;
      notifyListeners();
    }
  }

  // Menghapus produk.
  void removeProduct(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  // Menghapus produk yang sudah berhasil dipesan.
  void removeSelectedItems(List<Map<String, dynamic>> selectedItems) {
    items.removeWhere((item) => selectedItems.contains(item));
    notifyListeners();
  }
}
