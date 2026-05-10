import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  CartItem({required this.product, required this.quantity});
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (s, i) => s + i.quantity);

  double get totalAmount =>
      _items.values.fold(0, (s, i) => s + i.product.price * i.quantity);

  void add(ProductModel product, int qty) {
    if (_items.containsKey(product.id)) {
      final newQty = _items[product.id]!.quantity + qty;
      _items[product.id]!.quantity = newQty > product.stock ? product.stock : newQty;
    } else {
      _items[product.id] = CartItem(product: product, quantity: qty > product.stock ? product.stock : qty);
    }
    notifyListeners();
  }

  void updateQty(int productId, int qty) {
    if (qty <= 0) {
      _items.remove(productId);
    } else if (_items.containsKey(productId)) {
      final stock = _items[productId]!.product.stock;
      _items[productId]!.quantity = qty > stock ? stock : qty;
    }
    notifyListeners();
  }

  void remove(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int getQty(int productId) => _items[productId]?.quantity ?? 0;
}
