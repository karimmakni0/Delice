import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  String? _statusFilter;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get statusFilter => _statusFilter;

  Future<void> loadMyOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await OrderService.myOrders();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAdminOrders({String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await OrderService.adminGetOrders(status: _statusFilter, search: search);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadAdminOrders();
  }

  Future<bool> updateStatus(int orderId, String status) async {
    try {
      await OrderService.updateStatus(orderId, status);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        _orders[idx] = OrderModel(
          id: _orders[idx].id,
          userId: _orders[idx].userId,
          totalAmount: _orders[idx].totalAmount,
          pointsUsed: _orders[idx].pointsUsed,
          discountAmount: _orders[idx].discountAmount,
          finalTotal: _orders[idx].finalTotal,
          pointsEarned: _orders[idx].pointsEarned,
          status: status,
          createdAt: _orders[idx].createdAt,
          magasinName: _orders[idx].magasinName,
          userName: _orders[idx].userName,
          phone: _orders[idx].phone,
          address: _orders[idx].address,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
