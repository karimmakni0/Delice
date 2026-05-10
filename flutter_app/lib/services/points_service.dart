import '../core/api/api_client.dart';
import '../models/points_transaction_model.dart';

class PointsService {
  static Future<int> getBalance() async {
    final data = await ApiClient.get('/points/balance');
    return data['points_balance'] ?? 0;
  }

  static Future<List<PointsTransaction>> getHistory() async {
    final data = await ApiClient.get('/points/history');
    return (data['transactions'] as List).map((e) => PointsTransaction.fromJson(e)).toList();
  }
}
