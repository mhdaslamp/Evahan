// ignore_for_file: constant_identifier_names

/// Charger speed classification based on charging power.
enum ChargerType {
  /// < 50 kW
  normal,

  /// 50 – 149 kW
  fast,

  /// >= 150 kW
  ultraFast,

  /// Power data unavailable — cannot classify
  unknown,
}

/// Sorting options for the station list.
enum SortOption { nearest, highestPower, highestRating }

/// A normalised EV charging station.
/// Fields sourced from Google Places API (New) — Nearby Search.
/// Fields that Google does not reliably return for Indian stations are nullable.
class ChargingStation {
  /// Google Places place_id — used as unique key.
  final String id;

  /// Display name of the station (e.g. "Tata Power EV Charging Station").
  final String name;

  final double latitude;
  final double longitude;

  /// Formatted address — may be null if Places API omits it.
  final String? address;

  /// Straight-line distance from the search origin in kilometres.
  /// Calculated client-side after fetching.
  final double? distanceKm;

  /// Google Maps rating (1.0 – 5.0).
  final double? rating;

  /// Total number of Google ratings.
  final int? reviewCount;

  /// International phone number — shown on details screen only when non-null.
  final String? phoneNumber;

  /// Official website URL — shown on details screen only when non-null.
  final String? website;

  /// Human-readable opening hours lines (e.g. ["Monday: 8:00 AM - 10:00 PM"]).
  final List<String>? openingHours;

  /// Whether the station is currently open.
  /// Sourced from currentOpeningHours.openNow. Null if unavailable.
  final bool? isOpenNow;

  /// Maximum charging power in kW.
  /// Sourced from evChargeOptions — often null for Indian stations.
  final double? chargingPowerKw;

  /// Connector type strings (e.g. ["CCS", "TYPE_2"]).
  /// WILL BE NULL for most stations in India — display "Unavailable" in UI.
  final List<String>? connectorTypes;

  /// Derived charger type classification.
  final ChargerType chargerType;

  /// Total charger port count from evChargeOptions.connectorCount.
  final int? totalConnectors;

  /// Data source identifier — "google_places" for this implementation.
  final String source;

  const ChargingStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.distanceKm,
    this.rating,
    this.reviewCount,
    this.phoneNumber,
    this.website,
    this.openingHours,
    this.isOpenNow,
    this.chargingPowerKw,
    this.connectorTypes,
    required this.chargerType,
    this.totalConnectors,
    this.source = 'google_places',
  });

  /// Classify charger type from power in kW.
  static ChargerType classifyPower(double? kw) {
    if (kw == null) return ChargerType.unknown;
    if (kw >= 150) return ChargerType.ultraFast;
    if (kw >= 50) return ChargerType.fast;
    return ChargerType.normal;
  }

  /// Human-readable charger type label.
  String get chargerTypeLabel {
    switch (chargerType) {
      case ChargerType.ultraFast:
        return 'Ultra Fast';
      case ChargerType.fast:
        return 'Fast';
      case ChargerType.normal:
        return 'Normal';
      case ChargerType.unknown:
        return 'Unknown';
    }
  }

  /// Formatted distance string.
  String get distanceLabel {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).toStringAsFixed(0)} m';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  ChargingStation copyWith({double? distanceKm}) {
    return ChargingStation(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating,
      reviewCount: reviewCount,
      phoneNumber: phoneNumber,
      website: website,
      openingHours: openingHours,
      isOpenNow: isOpenNow,
      chargingPowerKw: chargingPowerKw,
      connectorTypes: connectorTypes,
      chargerType: chargerType,
      totalConnectors: totalConnectors,
      source: source,
    );
  }
}

/// Active filter state for the charging station list.
class ChargingFilter {
  /// Search radius in kilometres.
  final double radiusKm;

  /// Speed filter — null means "All".
  final ChargerType? speed;

  /// Connector filter — null means "All".
  final String? connector;

  /// Show only stations that are currently open.
  final bool openNowOnly;

  /// Sort order.
  final SortOption sort;

  const ChargingFilter({
    this.radiusKm = 10.0,
    this.speed,
    this.connector,
    this.openNowOnly = false,
    this.sort = SortOption.nearest,
  });

  ChargingFilter copyWith({
    double? radiusKm,
    ChargerType? speed,
    bool clearSpeed = false,
    String? connector,
    bool clearConnector = false,
    bool? openNowOnly,
    SortOption? sort,
  }) {
    return ChargingFilter(
      radiusKm: radiusKm ?? this.radiusKm,
      speed: clearSpeed ? null : (speed ?? this.speed),
      connector: clearConnector ? null : (connector ?? this.connector),
      openNowOnly: openNowOnly ?? this.openNowOnly,
      sort: sort ?? this.sort,
    );
  }
}
