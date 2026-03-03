import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Change this to your machine's local IP when testing on a physical device.
/// Use http://10.0.2.2:5000 for Android emulator.
/// Use http://192.168.x.x:5000 for physical device (your PC's LAN IP).
const String _baseUrl = 'http://192.168.1.16:5000/api';

class ApiService {
  static final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  static Dio _buildDio({String? token}) {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    return dio;
  }

  // ── Token storage ────────────────────────────────────────

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  // ── Auth ─────────────────────────────────────────────────

  /// Exchange Firebase ID token for our backend JWT.
  /// Called once after OTP verification succeeds.
  static Future<Map<String, dynamic>> loginWithFirebaseToken(
      String firebaseIdToken) async {
    final dio = _buildDio(token: firebaseIdToken);
    final res = await dio.post('/auth/login');
    final jwt = res.data['token'] as String;
    await saveToken(jwt); // persist JWT
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();
    final dio = _buildDio(token: token);
    final res = await dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  // ── Listings ─────────────────────────────────────────────

  static Future<Map<String, dynamic>> getListings({
    String? category,
    String? search,
    int page = 1,
  }) async {
    final dio = _buildDio();
    final res = await dio.get('/listings', queryParameters: {
      if (category != null) 'category': category,
      if (search != null) 'search': search,
      'page': page,
    });
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getMyListings() async {
    final token = await getToken();
    final dio = _buildDio(token: token);
    final res = await dio.get('/listings/my');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getListing(String id) async {
    final dio = _buildDio();
    final res = await dio.get('/listings/$id');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> postListing(
      FormData formData) async {
    final token = await getToken();
    final dio = _buildDio(token: token);
    final res = await dio.post('/listings', data: formData);
    return res.data as Map<String, dynamic>;
  }

  static Future<void> updateListingStatus(String id, String status) async {
    final token = await getToken();
    final dio = _buildDio(token: token);
    await dio.patch('/listings/$id/status', data: {'status': status});
  }

  // ── Chats ────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getOrCreateChat(
      String listingId) async {
    final token = await getToken();
    final dio = _buildDio(token: token);
    final res = await dio.post('/chats', data: {'listingId': listingId});
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getUserChats(String role) async {
    final token = await getToken();
    final dio = _buildDio(token: token);
    final res = await dio.get('/chats', queryParameters: {'role': role});
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getMessages(String chatId,
      {int page = 1}) async {
    final token = await getToken();
    final dio = _buildDio(token: token);
    final res = await dio.get('/chats/$chatId/messages',
        queryParameters: {'page': page});
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> sendMessage(
      String chatId, String text) async {
    final token = await getToken();
    final dio = _buildDio(token: token);
    final res =
        await dio.post('/chats/$chatId/messages', data: {'text': text});
    return res.data as Map<String, dynamic>;
  }
}
