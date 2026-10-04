import '../models/charging_station.dart';

/// Abstract repository interface for EV charging station data.
///
/// The UI depends ONLY on this interface.
/// The current implementation is [GoogleChargingRepository].
/// Future implementations can use OpenChargeMap, PlugShare, etc.
/// without changing any UI code.
abstract class ChargingRepository {
  /// Fetch EV charging stations near [lat]/[lng] within [radiusKm].
  /// Returns stations with [distanceKm] pre-calculated.
  Future<List<ChargingStation>> getNearbyStations({
    required double lat,
    required double lng,
    required double radiusKm,
  });

  /// Search stations near a named location string (city, address, etc).
  /// The repository is responsible for geocoding [query] to coordinates
  /// and then calling [getNearbyStations].
  Future<List<ChargingStation>> searchStations({
    required String query,
    required double radiusKm,
  });

  /// Fetch extended details for a single station by [placeId].
  /// May return enriched data not available in the list view.
  /// Returns null if the station cannot be found.
  Future<ChargingStation?> getStationDetails(String placeId);
}
