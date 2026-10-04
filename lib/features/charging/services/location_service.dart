import 'package:geolocator/geolocator.dart';

/// Typed result of a location request.
enum LocationErrorType {
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  unavailable,
}

class LocationResult {
  final Position? position;
  final LocationErrorType? error;

  const LocationResult.success(this.position) : error = null;
  const LocationResult.failure(this.error) : position = null;

  bool get isSuccess => position != null;
}

/// Thin wrapper around [Geolocator] for the charging feature.
/// Only performs one-shot location fetches — no continuous tracking.
class LocationService {
  /// Returns the user's current position (one-shot, not streaming).
  /// Handles all permission and service states gracefully.
  Future<LocationResult> getCurrentPosition() async {
    // 1. Check if location services are enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult.failure(LocationErrorType.serviceDisabled);
    }

    // 2. Check and request permissions.
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationResult.failure(LocationErrorType.permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationResult.failure(
          LocationErrorType.permissionPermanentlyDenied);
    }

    // 3. Fetch one-shot position.
    try {
      // Try to get last known position first for instant UI response.
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return LocationResult.success(lastKnown);
      }

      // Fall back to current position.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LocationResult.success(position);
    } catch (_) {
      return const LocationResult.failure(LocationErrorType.unavailable);
    }
  }

  /// Opens the device location settings (for permanently denied case).
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  /// Opens app-level permission settings (for permanently denied case).
  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
