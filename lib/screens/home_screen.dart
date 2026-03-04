import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/vehicle_card.dart';
import '../services/api_service.dart';
import '../utils/nav_helper.dart';
import 'search_screen.dart';
import 'chats_list_screen.dart';
import 'my_ads_screen.dart';
import 'profile_screen.dart';
import 'sell/sell_category_screen.dart';



final List<Map<String, dynamic>> _categories = [
  {'label': 'Cars', 'icon': Icons.directions_car_outlined},
  {'label': 'Bikes', 'icon': Icons.two_wheeler_outlined},
  {'label': 'Scooters', 'icon': Icons.electric_moped_outlined},
  {'label': 'Bicycles', 'icon': Icons.pedal_bike_outlined},
  {'label': 'Rickshaw', 'icon': Icons.airport_shuttle_outlined},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NavTab _currentTab = NavTab.home;
  String _selectedCity = 'Kerala';

  List<dynamic> _listings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiService.getListings();
      if (mounted) setState(() { _listings = data['listings'] ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load listings.'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildLocationRow(),
                    const SizedBox(height: 12),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildCategoriesSection(),
                    const SizedBox(height: 20),
                    _buildRecommendationsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // EVAHAN Logo
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

          // Hamburger
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
    );
  }

  Widget _buildLocationRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.green, size: 18),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  _selectedCity,
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.grey, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search here',
                  style: GoogleFonts.poppins(
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(Icons.favorite_border, color: AppColors.grey, size: 20),
              const SizedBox(width: 12),
              const Icon(Icons.notifications_none_rounded, color: AppColors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Categories',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(initialQuery: cat['label'] as String),
                  ),
                ),
                child: Container(
                  width: 78,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderColor, width: 1),
                        ),
                        child: Icon(cat['icon'] as IconData, color: AppColors.white, size: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['label'] as String,
                        style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Fresh Recommendation',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppColors.green)),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.wifi_off, color: AppColors.grey, size: 40),
                  const SizedBox(height: 10),
                  Text(_error!, style: GoogleFonts.poppins(color: AppColors.grey)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _fetchListings,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        side: const BorderSide(color: AppColors.green)),
                    child: Text('Retry', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),
          )
        else if (_listings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('No listings yet. Be the first to sell!',
                  style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13)),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
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
                );
              },
            ),
          ),
      ],
    );
  }
}
