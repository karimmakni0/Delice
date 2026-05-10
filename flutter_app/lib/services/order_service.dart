import '../core/api/api_client.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class OrderService {
  static Future<OrderModel> createOrder(List<Map<String, dynamic>> items, int pointsUsed) async {
    final data = await ApiClient.post('/orders', {'items': items, 'points_used': pointsUsed});
    return OrderModel.fromJson(data['order']);
  }

  static Future<List<OrderModel>> myOrders() async {
    final data = await ApiClient.get('/orders/my');
    return (data['orders'] as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> getOrderDetail(int id) async {
    final data = await ApiClient.get('/orders/$id');
    return {
      'order': OrderModel.fromJson(data['order']),
      'items': (data['items'] as List).map((e) => OrderItemModel.fromJson(e)).toList(),
    };
  }

  static Future<List<OrderModel>> adminGetOrders({String? status, String? search}) async {
    var path = '/admin/orders?';
    if (status != null) path += 'status=${Uri.encodeComponent(status)}&';
    if (search != null) path += 'search=${Uri.encodeComponent(search)}';
    final data = await ApiClient.get(path);
    return (data['orders'] as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  static Future<void> updateStatus(int id, String status) async {
    await ApiClient.put('/admin/orders/$id/status', {'status': status});
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    return ApiClient.get('/admin/dashboard');
  }

  static Future<List<UserModel>> adminGetMagasins({String? search}) async {
    var path = '/admin/magasins?';
    if (search != null) path += 'search=${Uri.encodeComponent(search)}';
    final data = await ApiClient.get(path);
    return (data['magasins'] as List).map((e) => UserModel.fromJson(e)).toList();
  }
}
