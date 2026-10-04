import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/charging_station.dart';
import 'charging_repository.dart';

class OcmChargingRepository implements ChargingRepository {
  final Dio _dio;

  OcmChargingRepository()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          baseUrl: 'https://api.openchargemap.io/v3',
          headers: {
            'User-Agent': 'EvahanApp/1.0',
          },
        ));

  final Map<String, List<ChargingStation>> _cache = {};

  String _cacheKey(double lat, double lng, double radiusKm) {
    final latR = (lat * 100).round() / 100;
    final lngR = (lng * 100).round() / 100;
    return '${latR}_${lngR}_$radiusKm';
  }

  @override
  Future<List<ChargingStation>> getNearbyStations({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    final key = _cacheKey(lat, lng, radiusKm);
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final apiKey = dotenv.env['OCM_API_KEY'];
    
    try {
      final response = await _dio.get(
        '/poi',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'distance': radiusKm,
          'distanceunit': 'KM',
          'maxresults': 50, // limit to 50 for performance
          if (apiKey != null && apiKey.isNotEmpty) 'key': apiKey,
        },
      );

      final List data = response.data as List? ?? [];
      final stations = data.map((e) => _parseOcmPlace(e as Map<String, dynamic>, lat, lng)).toList();
      
      _cache[key] = stations;
      return stations;
    } catch (e, stack) {
      print('OCM REPO ERROR: $e');
      print(stack);
      throw Exception('Failed to fetch charging stations: $e');
    }
  }

  @override
  Future<List<ChargingStation>> searchStations({
    required String query,
    required double radiusKm,
  }) async {
    // OpenStreetMap Nominatim for Geocoding (Free, open-source)
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'EvahanApp/1.0',
          },
        ),
      );

      final List results = response.data;
      if (results.isEmpty) throw Exception('Location not found');

      final lat = double.parse(results[0]['lat'].toString());
      final lon = double.parse(results[0]['lon'].toString());

      return getNearbyStations(lat: lat, lng: lon, radiusKm: radiusKm);
    } catch (e) {
      throw Exception('Failed to search location: $e');
    }
  }

  @override
  Future<ChargingStation?> getStationDetails(String placeId) async {
    for (final list in _cache.values) {
      final match = list.where((s) => s.id == placeId).firstOrNull;
      if (match != null) return match;
    }
    return null;
  }

  void clearCache() => _cache.clear();

  ChargingStation _parseOcmPlace(Map<String, dynamic> place, double originLat, double originLng) {
    final addressInfo = place['AddressInfo'] as Map<String, dynamic>? ?? {};
    final connections = place['Connections'] as List? ?? [];
    
    final id = place['ID']?.toString() ?? '';
    final name = addressInfo['Title']?.toString() ?? 'Charging Station';
    final lat = (addressInfo['Latitude'] as num?)?.toDouble() ?? originLat;
    final lng = (addressInfo['Longitude'] as num?)?.toDouble() ?? originLng;
    final address = addressInfo['AddressLine1']?.toString();
    
    // Aggregate connections info
    double? maxPower;
    List<String> connectorTypes = [];
    for (final conn in connections) {
      final p = (conn['PowerKW'] as num?)?.toDouble();
      if (p != null && (maxPower == null || p > maxPower)) {
        maxPower = p;
      }
      
      final typeInfo = conn['ConnectionType'] as Map<String, dynamic>?;
      final typeTitle = typeInfo?['Title']?.toString();
      if (typeTitle != null && typeTitle.isNotEmpty && !connectorTypes.contains(typeTitle)) {
        connectorTypes.add(typeTitle);
      }
    }

    final operatorInfo = place['OperatorInfo'] as Map<String, dynamic>?;
    final operatorName = operatorInfo?['Title']?.toString();
    final website = operatorInfo?['WebsiteURL']?.toString();
    final phone = addressInfo['ContactTelephone1']?.toString();

    final status = place['StatusType'] as Map<String, dynamic>?;
    bool? isOpen = status?['IsOperational'] as bool?;

    final distance = _haversineKm(originLat, originLng, lat, lng);
    final chargerType = ChargingStation.classifyPower(maxPower);

    return ChargingStation(
      id: id,
      name: operatorName != null ? '$operatorName - $name' : name,
      latitude: lat,
      longitude: lng,
      address: address,
      distanceKm: distance,
      phoneNumber: phone,
      website: website,
      isOpenNow: isOpen,
      chargingPowerKw: maxPower,
      connectorTypes: connectorTypes.isNotEmpty ? connectorTypes : null,
      chargerType: chargerType,
      totalConnectors: connections.length,
      source: 'openchargemap',
    );
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);
}
