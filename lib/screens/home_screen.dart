import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/vehicle_card.dart';
import 'search_screen.dart';
import 'chats_list_screen.dart';
import 'sell/sell_category_screen.dart';

// Sample dummy data
final List<Map<String, String>> _dummyListings = [
  {'name': 'Car Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1552519507-da3b142148bb?w=400'},
  {'name': 'Scooter Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=400'},
  {'name': 'Bike Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'},
  {'name': 'Car Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400'},
  {'name': 'Car Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1617886903355-9354bb57751f?w=400'},
  {'name': 'Rickshaw Model', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1622185135505-2d795003994a?w=400'},
  {'name': 'Scooter Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=400'},
  {'name': 'Bike Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'},
];

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
  int _visibleCount = 8;

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
        onTap: (tab) {
          if (tab == NavTab.chats) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChatsListScreen()));
          } else if (tab == NavTab.sell) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SellCategoryScreen()));
          } else {
            setState(() => _currentTab = tab);
          }
        },
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
            itemCount: _visibleCount.clamp(0, _dummyListings.length),
            itemBuilder: (context, index) {
              final item = _dummyListings[index];
              return VehicleCard(
                name: item['name']!,
                price: item['price']!,
                km: item['km']!,
                location: item['location']!,
                imageUrl: item['image']!,
              );
            },
          ),
        ),
        if (_visibleCount < _dummyListings.length) ...[
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: () => setState(() => _visibleCount += 4),
              child: Text(
                'Load More',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
