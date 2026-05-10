import '../core/api/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await ApiClient.post('/auth/login', {'email': email, 'password': password}, auth: false);
    await ApiClient.saveToken(data['token']);
    return data;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final data = await ApiClient.post('/auth/register', body, auth: false);
    await ApiClient.saveToken(data['token']);
    return data;
  }

  static Future<void> logout() => ApiClient.clearToken();

  static Future<Map<String, dynamic>> getMe() async {
    return ApiClient.get('/auth/me');
  }
}
