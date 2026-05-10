import '../core/api/api_client.dart';
import '../models/product_model.dart';

class ProductService {
  static Future<List<ProductModel>> getProducts({String? category, String? search}) async {
    var path = '/products?';
    if (category != null) path += 'category=${Uri.encodeComponent(category)}&';
    if (search != null) path += 'search=${Uri.encodeComponent(search)}';
    final data = await ApiClient.get(path);
    return (data['products'] as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  static Future<List<ProductModel>> adminGetProducts() async {
    final data = await ApiClient.get('/admin/products');
    return (data['products'] as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  static Future<ProductModel> createProduct(Map<String, dynamic> body) async {
    final data = await ApiClient.post('/admin/products', body);
    return ProductModel.fromJson(data['product']);
  }

  static Future<ProductModel> updateProduct(int id, Map<String, dynamic> body) async {
    final data = await ApiClient.put('/admin/products/$id', body);
    return ProductModel.fromJson(data['product']);
  }
}
