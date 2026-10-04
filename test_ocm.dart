import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final url = "https://api.openchargemap.io/v3/poi?latitude=10.8505&longitude=76.2711&distance=10&distanceunit=KM&maxresults=10&key=0b0ceee7-d425-4ce0-907d-0a775ae8665c";
  
  try {
    final response = await dio.get(url, options: Options(headers: {'User-Agent': 'EvahanApp/1.0'}));
    final data = response.data as List;
    print("Fetched ${data.length} items");
    
    for (var item in data) {
      final place = item as Map<String, dynamic>;
      
      final addressInfo = place['AddressInfo'] as Map<String, dynamic>? ?? {};
      final connections = place['Connections'] as List? ?? [];
      
      final id = place['ID']?.toString() ?? '';
      final name = addressInfo['Title']?.toString() ?? 'Charging Station';
      final lat = (addressInfo['Latitude'] as num?)?.toDouble() ?? 10.0;
      final lng = (addressInfo['Longitude'] as num?)?.toDouble() ?? 76.0;
      final address = addressInfo['AddressLine1']?.toString();
      
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

      print("Parsed station: \$name / \$operatorName");
    }
  } catch (e, stack) {
    print("Error: $e");
    print(stack);
  }
}

