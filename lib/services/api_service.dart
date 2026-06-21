import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Change this to your machine's local IP when testing on a physical device.
/// Use http://10.0.2.2:5000 for Android emulator.
/// Use http://192.168.x.x:5000 for physical device (your PC's LAN IP).
const String _baseUrl = 'https://evahan.onrender.com/api';

class ApiService {
  static final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _listingsCacheKey = 'cached_listings';
  static String? _cachedUserId;

  // ── Cache Getters ────────────────────────────────────────

  static Future<Map<String, dynamic>?> getCachedListings() async {
    try {
      final jsonStr = await _storage.read(key: _listingsCacheKey);
      if (jsonStr != null) {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getCachedListing(String id) async {
    try {
      final jsonStr = await _storage.read(key: 'cached_listing_$id');
      if (jsonStr != null) {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getCachedUserChats(String role) async {
    try {
      final jsonStr = await _storage.read(key: 'cached_chats_$role');
      if (jsonStr != null) {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

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

  static Future<void> saveUserId(String userId) async {
    _cachedUserId = userId;
    await _storage.write(key: _userIdKey, value: userId);
  }

  static Future<String?> getUserId() => _storage.read(key: _userIdKey);

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    _cachedUserId = null;
  }

  static String? _decodeUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decodedJson = utf8.decode(base64Decode(normalized));
      final map = jsonDecode(decodedJson) as Map<String, dynamic>;
      return map['id']?.toString();
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getMyUserId() async {
    if (_cachedUserId != null) return _cachedUserId;

    // Try decoding from JWT token first for 100% offline reliability
    final token = await getToken();
    if (token != null) {
      final idFromToken = _decodeUserIdFromToken(token);
      if (idFromToken != null) {
        _cachedUserId = idFromToken;
        await saveUserId(idFromToken);
        return idFromToken;
      }
    }

    final cached = await getUserId();
    if (cached != null) {
      _cachedUserId = cached;
      return cached;
    }
    try {
      final data = await getMe();
      final id = data['user']?['_id'] ?? data['user']?['id'];
      if (id != null) {
        final idStr = id as String;
        await saveUserId(idStr);
        return idStr;
      }
    } catch (_) {}
    return null;
  }

  // ── Auth ─────────────────────────────────────────────────

  /// Exchange Firebase ID token for our backend JWT.
  /// Called once after OTP verification succeeds.
  static Future<Map<String, dynamic>> loginWithFirebaseToken(
      String firebaseIdToken) async {
    final dio = _buildDio(token: firebaseIdToken);
    final res = await dio.post('/auth/login');
    final jwt = res.data['token'] as String;
    await saveToken(jwt); // persist JWT
    try {
      final id = res.data['user']?['id'] ?? res.data['user']?['_id'];
      if (id != null) {
        await saveUserId(id as String);
      }
    } catch (_) {}
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();
    final dio = _buildDio(token: token);
    final res = await dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? about,
    String? profilePicPath,
  }) async {
    final token = await getToken();
    final dio = _buildDio(token: token);
    
    dynamic data;
    if (profilePicPath != null) {
      data = FormData.fromMap({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (about != null) 'about': about,
        'photo': await MultipartFile.fromFile(
          profilePicPath,
          filename: 'profile_pic.jpg',
        ),
      });
    } else {
      data = {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (about != null) 'about': about,
      };
    }

    final res = await dio.put('/auth/profile', data: data);
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
    
    // Cache the first page of the default feed locally
    if (category == null && search == null && page == 1) {
      try {
        await _storage.write(key: _listingsCacheKey, value: jsonEncode(res.data));
      } catch (_) {}
    }
    
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
    try {
      await _storage.write(key: 'cached_listing_$id', value: jsonEncode(res.data));
    } catch (_) {}
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
    try {
      await _storage.write(key: 'cached_chats_$role', value: jsonEncode(res.data));
    } catch (_) {}
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
