import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  String _search = '';

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _products.map((p) => p.category ?? '').where((c) => c.isNotEmpty).toSet().toList();
    cats.sort();
    return cats;
  }

  Future<void> load({bool admin = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = admin
          ? await ProductService.adminGetProducts()
          : await ProductService.getProducts(
              category: _selectedCategory,
              search: _search.isEmpty ? null : _search,
            );
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String? cat) {
    _selectedCategory = cat;
    load();
  }

  void setSearch(String q) {
    _search = q;
    load();
  }
}
