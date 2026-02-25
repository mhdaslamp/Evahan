import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/vehicle_card.dart';

// Dummy data for search results
final List<Map<String, String>> _allListings = [
  {'name': 'Car Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1552519507-da3b142148bb?w=400'},
  {'name': 'Scooter Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=400'},
  {'name': 'Bike Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'},
  {'name': 'Car Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400'},
  {'name': 'Car Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1617886903355-9354bb57751f?w=400'},
  {'name': 'Rickshaw Model', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1622185135505-2d795003994a?w=400'},
  {'name': 'Scooter Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=400'},
  {'name': 'Bike Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'},
  {'name': 'Rickshaw Model', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1622185135505-2d795003994a?w=400'},
  {'name': 'Car Name', 'price': '₹ 12,00,000', 'km': 'Total km', 'location': 'location', 'image': 'https://images.unsplash.com/photo-1552519507-da3b142148bb?w=400'},
];

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  bool _hasSearched = false;
  String _query = '';
  final String _city = 'Kerala';
  NavTab _currentTab = NavTab.home;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _query = widget.initialQuery!;
      _hasSearched = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _doSearch(String value) {
    if (value.trim().isEmpty) return;
    setState(() {
      _query = value.trim();
      _hasSearched = true;
    });
    FocusScope.of(context).unfocus();
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
              child: _hasSearched ? _buildResults() : _buildEmpty(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EvBottomNavBar(
        currentTab: _currentTab,
        onTap: (tab) => setState(() => _currentTab = tab),
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
                            hintText: _hasSearched
                                ? '"$_query" in $_city'
                                : 'Find cars, bikes, cycles...',
                            hintStyle: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _doSearch,
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _doSearch(_searchController.text),
                        child: const Icon(Icons.search, color: AppColors.grey, size: 20),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter button
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: const Icon(Icons.tune_rounded, color: AppColors.white, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmpty() {
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

  Widget _buildResults() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Showing results for "$_query"',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
              itemCount: _allListings.length,
              itemBuilder: (context, index) {
                final item = _allListings[index];
                return VehicleCard(
                  name: item['name']!,
                  price: item['price']!,
                  km: item['km']!,
                  location: item['location']!,
                  imageUrl: item['image']!,
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
