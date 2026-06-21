import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/vehicle_card.dart';
import '../services/api_service.dart';
import '../utils/nav_helper.dart';
import 'vehicle_detail_screen.dart';


class SearchScreen extends StatefulWidget {
  /// If not null, the screen opens with a pre-filled text search.
  final String? initialQuery;

  /// If not null, the screen opens filtered by this category (exact match).
  final String? initialCategory;

  const SearchScreen({super.key, this.initialQuery, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  NavTab _currentTab = NavTab.home;

  List<dynamic> _listings = [];
  bool _isLoading = false;
  bool _hasFetched = false;
  String? _error;

  /// Current active keyword query
  String _query = '';

  /// Current active category filter (null = no filter)
  String? _activeCategory;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');

    if (widget.initialCategory != null) {
      // Category tap: immediately filter by category
      _activeCategory = widget.initialCategory;
      _fetch();
    } else if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      // Search from home
      _query = widget.initialQuery!;
      _fetch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Calls the backend with current _query and/or _activeCategory
  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _hasFetched = true;
    });
    try {
      final data = await ApiService.getListings(
        search: _query.isNotEmpty ? _query : null,
        category: _activeCategory,
      );
      if (mounted) {
        setState(() {
          _listings = data['listings'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load results. Check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchSubmit(String value) {
    final trimmed = value.trim();
    if (trimmed == _query) return;
    setState(() {
      _query = trimmed;
      _activeCategory = null; // clear category filter when typing a search
    });
    if (trimmed.isNotEmpty) _fetch();
  }

  /// Label shown in the top bar / subtitle
  String get _displayLabel {
    if (_activeCategory != null && _query.isEmpty) return _activeCategory!;
    if (_query.isNotEmpty && _activeCategory != null) return '$_query in $_activeCategory';
    if (_query.isNotEmpty) return _query;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            // Active category chip
            if (_activeCategory != null) _buildCategoryChip(),
            Expanded(
              child: _hasFetched ? _buildBody() : _buildHint(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EvBottomNavBar(
        currentTab: _currentTab,
        onTap: (tab) => handleNavTap(context, tab, _currentTab),
      ),
    );
  }

  Widget _buildTopBar() {
    return Column(
      children: [
        // Logo row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'EV',
                      style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    TextSpan(
                      text: 'AHAN',
                      style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 22,
                      height: 2.5,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search bar row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: const Icon(Icons.arrow_back, color: AppColors.white, size: 18),
                ),
              ),

              // Search input
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: _activeCategory != null
                                ? 'Search in ${_activeCategory!}...'
                                : 'Find cars, bikes, scooters...',
                            hintStyle: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _onSearchSubmit,
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _onSearchSubmit(_searchController.text),
                        child: const Icon(Icons.search, color: AppColors.grey, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCategoryChip() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _activeCategory!,
                  style: GoogleFonts.poppins(
                    color: AppColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeCategory = null;
                      _hasFetched = false;
                      _listings = [];
                    });
                  },
                  child: const Icon(Icons.close, color: AppColors.green, size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_rounded, color: AppColors.grey, size: 60),
          const SizedBox(height: 16),
          Text(
            'Search for EV vehicles',
            style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Cars, Bikes, Scooters, Bicycles...',
            style: GoogleFonts.poppins(color: AppColors.borderColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: AppColors.grey, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: GoogleFonts.poppins(color: AppColors.grey)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _fetch,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.green,
                side: const BorderSide(color: AppColors.green),
              ),
              child: Text('Retry', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    }

    if (_listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, color: AppColors.grey, size: 56),
            const SizedBox(height: 12),
            Text(
              'No listings found',
              style: GoogleFonts.poppins(color: AppColors.white, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              _displayLabel.isNotEmpty
                  ? 'for "$_displayLabel"'
                  : 'Try a different keyword',
              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                '${_listings.length} result${_listings.length == 1 ? '' : 's'}'
                '${_displayLabel.isNotEmpty ? ' for "$_displayLabel"' : ''}',
                style: GoogleFonts.poppins(
                  color: AppColors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.68,
              ),
              itemCount: _listings.length,
              itemBuilder: (context, index) {
                final item = _listings[index] as Map<String, dynamic>;
                final photos = item['photoUrls'] as List? ?? [];
                return VehicleCard(
                  name: '${item['brand'] ?? ''} ${item['model'] ?? ''}'.trim(),
                  price: '₹ ${item['price'] ?? ''}',
                  km: '${item['kmDriven'] ?? '--'} km',
                  location: item['location'] ?? '',
                  imageUrl: photos.isNotEmpty ? photos[0] as String : '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VehicleDetailScreen(listingId: item['_id'] as String),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
