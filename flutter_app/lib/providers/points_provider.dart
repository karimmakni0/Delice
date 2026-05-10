import 'package:flutter/material.dart';
import '../models/points_transaction_model.dart';
import '../services/points_service.dart';

class PointsProvider extends ChangeNotifier {
  int _balance = 0;
  List<PointsTransaction> _history = [];
  bool _isLoading = false;

  int get balance => _balance;
  List<PointsTransaction> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _balance = await PointsService.getBalance();
      _history = await PointsService.getHistory();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}
