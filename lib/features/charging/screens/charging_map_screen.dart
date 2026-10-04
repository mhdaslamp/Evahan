import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/charging_station.dart';
import '../repositories/ocm_charging_repository.dart';
import '../services/location_service.dart';
import '../widgets/charging_station_card.dart';
import '../widgets/charging_filter_sheet.dart';
import 'charging_station_details_screen.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../utils/nav_helper.dart';

class ChargingMapScreen extends StatefulWidget {
  const ChargingMapScreen({super.key});

  @override
  State<ChargingMapScreen> createState() => _ChargingMapScreenState();
}

enum _ScreenState {
  permissionLoading,
  permissionDenied,
  permissionPermanentlyDenied,
  gpsDisabled,
  loading,
  loaded,
  empty,
  error,
}

class _ChargingMapScreenState extends State<ChargingMapScreen> {
  final _locationService = LocationService();
  final _repository = OcmChargingRepository();

  final MapController _mapController = MapController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  _ScreenState _screenState = _ScreenState.permissionLoading;
  String? _errorMessage;

  double _userLat = 0;
  double _userLng = 0;
  double _searchLat = 0;
  double _searchLng = 0;

  List<ChargingStation> _allStations = [];
  List<ChargingStation> _filteredStations = [];
  ChargingFilter _filter = const ChargingFilter();
  ChargingStation? _selectedStation;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() => _screenState = _ScreenState.permissionLoading);
    final result = await _locationService.getCurrentPosition();

    if (!mounted) return;

    if (!result.isSuccess) {
      switch (result.error!) {
        case LocationErrorType.permissionDenied:
          setState(() => _screenState = _ScreenState.permissionDenied);
          break;
        case LocationErrorType.permissionPermanentlyDenied:
          setState(() => _screenState = _ScreenState.permissionPermanentlyDenied);
          break;
        case LocationErrorType.serviceDisabled:
          setState(() => _screenState = _ScreenState.gpsDisabled);
          break;
        case LocationErrorType.unavailable:
          setState(() {
            _screenState = _ScreenState.error;
            _errorMessage = 'Unable to determine your location.';
          });
          break;
      }
      return;
    }

    _userLat = result.position!.latitude;
    _userLng = result.position!.longitude;
    _searchLat = _userLat;
    _searchLng = _userLng;

    await _fetchStations();
  }

  Future<void> _fetchStations({bool forceRefresh = false}) async {
    setState(() {
      _screenState = _ScreenState.loading;
      _errorMessage = null;
      _selectedStation = null;
    });

    if (forceRefresh) _repository.clearCache();

    try {
      final stations = await _repository.getNearbyStations(
        lat: _searchLat,
        lng: _searchLng,
        radiusKm: _filter.radiusKm,
      );

      if (!mounted) return;
      _allStations = stations;
      _applyFilters();

      _mapController.move(
        LatLng(_searchLat, _searchLng),
        _zoomForRadius(_filter.radiusKm),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _screenState = _ScreenState.error;
        _errorMessage = 'Unable to load charging stations.';
      });
    }
  }

  void _applyFilters() {
    var list = List<ChargingStation>.from(_allStations);

    if (_filter.speed != null) {
      if (_filter.speed == ChargerType.ultraFast) {
        list = list.where((s) => s.chargerType == ChargerType.ultraFast).toList();
      } else if (_filter.speed == ChargerType.fast) {
        list = list
            .where((s) =>
                s.chargerType == ChargerType.fast ||
                s.chargerType == ChargerType.ultraFast)
            .toList();
      }
    }

    if (_filter.connector != null) {
      list = list
          .where((s) =>
              s.connectorTypes != null &&
              s.connectorTypes!.contains(_filter.connector))
          .toList();
    }

    if (_filter.openNowOnly) {
      list = list.where((s) => s.isOpenNow == true).toList();
    }

    switch (_filter.sort) {
      case SortOption.nearest:
        list.sort((a, b) =>
            (a.distanceKm ?? double.infinity)
                .compareTo(b.distanceKm ?? double.infinity));
        break;
      case SortOption.highestPower:
        list.sort((b, a) =>
            (a.chargingPowerKw ?? 0).compareTo(b.chargingPowerKw ?? 0));
        break;
      case SortOption.highestRating:
        list.sort((b, a) => (a.rating ?? 0).compareTo(b.rating ?? 0));
        break;
    }

    _filteredStations = list;

    setState(() {
      _screenState = list.isEmpty ? _ScreenState.empty : _ScreenState.loaded;
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) return;

    _searchDebounce = Timer(const Duration(milliseconds: 600), () {
      _searchLocation(query.trim());
    });
  }

  Future<void> _searchLocation(String query) async {
    setState(() {
      _screenState = _ScreenState.loading;
      _selectedStation = null;
    });

    try {
      final stations = await _repository.searchStations(
        query: query,
        radiusKm: _filter.radiusKm,
      );

      if (!mounted) return;

      if (stations.isNotEmpty) {
        _searchLat = stations.first.latitude;
        _searchLng = stations.first.longitude;
      }

      _allStations = stations;
      _applyFilters();

      if (stations.isNotEmpty) {
        _mapController.move(
          LatLng(_searchLat, _searchLng),
          _zoomForRadius(_filter.radiusKm),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _screenState = _ScreenState.error;
        _errorMessage = 'Location not found. Try a different search.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: EvBottomNavBar(
        currentTab: NavTab.evMap,
        onTap: (tab) => handleNavTap(context, tab, NavTab.evMap),
      ),
    );
  }

  Widget _buildBody() {
    switch (_screenState) {
      case _ScreenState.permissionLoading:
        return _buildCenteredState(
          icon: Icons.location_searching,
          message: 'Getting your location...',
          showSpinner: true,
        );
      case _ScreenState.permissionDenied:
        return _buildCenteredState(
          icon: Icons.location_off_outlined,
          message:
              'Location permission is required to find nearby charging stations.',
          actionLabel: 'Enable Location',
          onAction: _initLocation,
        );
      case _ScreenState.permissionPermanentlyDenied:
        return _buildCenteredState(
          icon: Icons.location_disabled_outlined,
          message:
              'Location permission was denied. Please enable it in Settings.',
          actionLabel: 'Open Settings',
          onAction: _locationService.openAppSettings,
        );
      case _ScreenState.gpsDisabled:
        return _buildCenteredState(
          icon: Icons.gps_off_outlined,
          message: 'GPS is disabled. Please enable location services.',
          actionLabel: 'Enable GPS',
          onAction: () async {
            await _locationService.openLocationSettings();
            await _initLocation();
          },
        );
      case _ScreenState.loading:
      case _ScreenState.loaded:
      case _ScreenState.empty:
      case _ScreenState.error:
        return _buildMainLayout();
    }
  }

  Widget _buildMainLayout() {
    return Column(
      children: [
        _buildTopBar(),
        _buildSearchBar(),
        _buildQuickFilterChips(),
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.38,
                    child: _buildMap(),
                  ),
                  Expanded(child: _buildStationList()),
                ],
              ),
              if (_selectedStation != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildSelectedStationPreview(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child:
                const Icon(Icons.arrow_back, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.bolt, color: AppColors.green, size: 22),
          const SizedBox(width: 6),
          Text(
            'EV Charging',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _fetchStations(forceRefresh: true),
            child: const Icon(Icons.refresh, color: AppColors.grey, size: 22),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: _showFilterSheet,
            child: const Icon(Icons.tune_rounded,
                color: AppColors.grey, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: AppColors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: GoogleFonts.poppins(
                    color: AppColors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search city or location...',
                  hintStyle: GoogleFonts.poppins(
                      color: AppColors.grey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _searchLocation,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _searchLat = _userLat;
                  _searchLng = _userLng;
                  _fetchStations();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.close, color: AppColors.grey, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _QuickChip(
            label: 'Fast',
            selected: _filter.speed == ChargerType.fast,
            onTap: () {
              final newFilter = _filter.speed == ChargerType.fast
                  ? _filter.copyWith(clearSpeed: true)
                  : _filter.copyWith(speed: ChargerType.fast);
              setState(() => _filter = newFilter);
              _applyFilters();
            },
          ),
          _QuickChip(
            label: 'Ultra Fast',
            selected: _filter.speed == ChargerType.ultraFast,
            onTap: () {
              final newFilter = _filter.speed == ChargerType.ultraFast
                  ? _filter.copyWith(clearSpeed: true)
                  : _filter.copyWith(speed: ChargerType.ultraFast);
              setState(() => _filter = newFilter);
              _applyFilters();
            },
          ),
          _QuickChip(
            label: 'CCS',
            selected: _filter.connector == 'CCS',
            onTap: () {
              final newFilter = _filter.connector == 'CCS'
                  ? _filter.copyWith(clearConnector: true)
                  : _filter.copyWith(connector: 'CCS');
              setState(() => _filter = newFilter);
              _applyFilters();
            },
          ),
          _QuickChip(
            label: 'Type 2',
            selected: _filter.connector == 'Type 2',
            onTap: () {
              final newFilter = _filter.connector == 'Type 2'
                  ? _filter.copyWith(clearConnector: true)
                  : _filter.copyWith(connector: 'Type 2');
              setState(() => _filter = newFilter);
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(
              _userLat != 0 ? _userLat : 10.8505,
              _userLng != 0 ? _userLng : 76.2711,
            ),
            initialZoom: 12,
            onTap: (_, __) => setState(() => _selectedStation = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.evahan',
            ),
            MarkerLayer(
              markers: [
                if (_userLat != 0)
                  Marker(
                    point: LatLng(_userLat, _userLng),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                  ),
                ..._filteredStations.map((station) => Marker(
                  point: LatLng(station.latitude, station.longitude),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStation = station),
                    child: const Icon(Icons.ev_station, color: AppColors.green, size: 30),
                  ),
                )),
              ],
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                ),
                TextSourceAttribution(
                  'OpenChargeMap',
                  onTap: () => launchUrl(Uri.parse('https://openchargemap.org/')),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.cardBg,
            child: const Icon(Icons.my_location, color: AppColors.white),
            onPressed: () {
              _mapController.move(LatLng(_userLat, _userLng), 13);
              _searchLat = _userLat;
              _searchLng = _userLng;
              _fetchStations();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStationList() {
    if (_screenState == _ScreenState.loading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: 5,
        itemBuilder: (_, __) => const ChargingStationCardSkeleton(),
      );
    }

    if (_screenState == _ScreenState.error) {
      return _buildListState(
        icon: Icons.wifi_off_outlined,
        message: _errorMessage ?? 'Unable to load charging stations.',
        actionLabel: 'Retry',
        onAction: () => _fetchStations(forceRefresh: true),
      );
    }

    if (_screenState == _ScreenState.empty) {
      return _buildListState(
        icon: Icons.ev_station_outlined,
        message: 'No charging stations found nearby.',
        actionLabel: 'Search Larger Area',
        onAction: () {
          setState(
              () => _filter = _filter.copyWith(radiusKm: _filter.radiusKm * 2));
          _fetchStations();
        },
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Nearby Charging Stations',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_filteredStations.length}',
                  style: GoogleFonts.poppins(
                    color: AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.green,
            onRefresh: () => _fetchStations(forceRefresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _filteredStations.length,
              itemBuilder: (context, i) {
                final station = _filteredStations[i];
                return ChargingStationCard(
                  station: station,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChargingStationDetailsScreen(station: station),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedStationPreview() {
    final station = _selectedStation!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ChargingStationDetailsScreen(station: station)),
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.green, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withValues(alpha: 0.2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.bolt, color: AppColors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    station.name,
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (station.distanceLabel.isNotEmpty) station.distanceLabel,
                      if (station.chargingPowerKw != null)
                        '${station.chargingPowerKw!.toStringAsFixed(0)} kW',
                    ].join(' • '),
                    style: GoogleFonts.poppins(
                      color: AppColors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Details →',
              style: GoogleFonts.poppins(
                color: AppColors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenteredState({
    required IconData icon,
    required String message,
    bool showSpinner = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showSpinner)
                    const CircularProgressIndicator(color: AppColors.green)
                  else
                    Icon(icon, color: AppColors.grey, size: 56),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        actionLabel,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListState({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.grey, size: 48),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(actionLabel,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChargingFilterSheet(
        initialFilter: _filter,
        onApply: (newFilter) {
          final radiusChanged = newFilter.radiusKm != _filter.radiusKm;
          setState(() => _filter = newFilter);
          if (radiusChanged) {
            _fetchStations();
          } else {
            _applyFilters();
          }
        },
      ),
    );
  }

  double _zoomForRadius(double radiusKm) {
    if (radiusKm <= 5) return 13;
    if (radiusKm <= 10) return 12;
    if (radiusKm <= 25) return 11;
    return 10;
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.black : AppColors.white,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
