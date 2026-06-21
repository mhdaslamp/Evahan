import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/api_service.dart';
import '../utils/nav_helper.dart';
import 'vehicle_detail_screen.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  List<dynamic> _listings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyListings();
  }

  Future<void> _fetchMyListings() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiService.getMyListings();
      if (mounted) setState(() { _listings = data['listings'] ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load your ads.'; _isLoading = false; });
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await ApiService.updateListingStatus(id, status);
      _fetchMyListings();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status', style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent),
      );
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: EvBottomNavBar(
        currentTab: NavTab.myAds,
        onTap: (tab) => handleNavTap(context, tab, NavTab.myAds),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Text('My Ads',
              style: GoogleFonts.poppins(
                  color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.green));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: AppColors.grey, size: 40),
            const SizedBox(height: 10),
            Text(_error!, style: GoogleFonts.poppins(color: AppColors.grey)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _fetchMyListings,
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green)),
              child: Text('Retry', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    }
    if (_listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article_outlined, color: AppColors.grey, size: 60),
            const SizedBox(height: 16),
            Text("You haven't listed anything yet",
                style: GoogleFonts.poppins(
                    color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text("Let go of what you don't use anymore",
                style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: _fetchMyListings,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _listings.length,
        itemBuilder: (context, i) {
          final item = _listings[i] as Map<String, dynamic>;
          final photos = item['photoUrls'] as List? ?? [];
          final status = item['status'] as String? ?? 'active';
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VehicleDetailScreen(listingId: item['_id'] as String),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor, width: 0.8),
              ),
              child: Row(
                children: [
                // Photo
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                  child: (photos.isNotEmpty && (photos[0] as String).isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: photos[0] as String,
                          width: 110,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 110,
                            height: 90,
                            color: const Color(0xFF1A2F3D),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.green,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 110,
                            height: 90,
                            color: const Color(0xFF1A2F3D),
                            child: const Icon(Icons.electric_car_outlined,
                                color: AppColors.green, size: 36),
                          ),
                        )
                      : Container(
                          width: 110,
                          height: 90,
                          color: const Color(0xFF1A2F3D),
                          child: const Icon(Icons.electric_car_outlined,
                              color: AppColors.green, size: 36),
                        ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['adTitle'] ?? '${item['brand']} ${item['model']}'.trim(),
                          style: GoogleFonts.poppins(
                              color: AppColors.white, fontSize: 13,
                              fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text('₹ ${item['price'] ?? '--'}',
                            style: GoogleFonts.poppins(
                                color: AppColors.green, fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: status == 'active'
                                ? AppColors.green.withValues(alpha: 0.15)
                                : Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(status.toUpperCase(),
                              style: GoogleFonts.poppins(
                                  color: status == 'active' ? AppColors.green : Colors.orange,
                                  fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.grey, size: 20),
                  color: AppColors.cardBg,
                  onSelected: (val) => _updateStatus(item['_id'] as String, val),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'sold',
                        child: Text('Mark as Sold',
                            style: GoogleFonts.poppins(color: AppColors.white))),
                    PopupMenuItem(value: 'deleted',
                        child: Text('Delete Ad',
                            style: GoogleFonts.poppins(color: Colors.redAccent))),
                  ],
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}
