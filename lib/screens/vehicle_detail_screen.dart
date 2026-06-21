import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'chat_window_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String listingId;

  const VehicleDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  Map<String, dynamic>? _listing;
  bool _isLoading = true;
  String? _error;
  List<dynamic> _similarListings = [];
  bool _isFavorited = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isChatLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCachedDetails();
    _loadDetails();
  }

  Future<void> _loadCachedDetails() async {
    final cached = await ApiService.getCachedListing(widget.listingId);
    final listing = cached?['listing'] as Map<String, dynamic>?;
    if (mounted && listing != null && _listing == null) {
      setState(() {
        _listing = listing;
        _isLoading = false;
      });
      _loadSimilarListings(listing['category'] as String);
    }
  }

  Future<void> _loadDetails() async {
    if (_listing == null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final res = await ApiService.getListing(widget.listingId);
      final listing = res['listing'] as Map<String, dynamic>?;
      if (mounted && listing != null) {
        setState(() {
          _listing = listing;
          _isLoading = false;
          _error = null;
        });
        _loadSimilarListings(listing['category'] as String);
      } else {
        if (mounted && _listing == null) {
          setState(() {
            _error = 'Listing not found.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted && _listing == null) {
        setState(() {
          _error = 'Could not load details.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSimilarListings(String category) async {
    try {
      final res = await ApiService.getListings(category: category);
      final list = res['listings'] as List? ?? [];
      if (mounted) {
        setState(() {
          _similarListings = list.where((item) => item['_id'] != widget.listingId).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _startChat() async {
    if (_listing == null || _isChatLoading) return;

    setState(() => _isChatLoading = true);

    try {
      final res = await ApiService.getOrCreateChat(widget.listingId);
      final chat = res['chat'] as Map<String, dynamic>?;

      if (!mounted) return;
      setState(() => _isChatLoading = false);

      if (chat != null) {
        final seller = _listing!['seller'] as Map<String, dynamic>?;
        final sellerName = seller?['name'] as String? ?? 'Seller';
        final photoUrls = _listing!['photoUrls'] as List? ?? [];
        final vehicleImageUrl = photoUrls.isNotEmpty ? photoUrls[0] as String : '';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatWindowScreen(
              chatId: chat['_id'] as String,
              otherUserName: sellerName,
              vehicleName: _listing!['adTitle'] ?? '${_listing!['brand']} ${_listing!['model']}'.trim(),
              vehiclePrice: '₹ ${_listing!['price'] ?? '--'}',
              vehicleImageUrl: vehicleImageUrl,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate chat.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChatLoading = false);
        String errMsg = 'Could not start chat.';
        if (e.toString().contains('400')) {
          errMsg = 'You cannot chat about your own listing.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg, style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.green),
        ),
      );
    }

    if (_error != null || _listing == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.grey, size: 48),
              const SizedBox(height: 16),
              Text(
                _error ?? 'An error occurred',
                style: GoogleFonts.poppins(color: AppColors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDetails,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                child: Text('Retry', style: GoogleFonts.poppins(color: Colors.black)),
              )
            ],
          ),
        ),
      );
    }

    final photos = _listing!['photoUrls'] as List? ?? [];
    final brand = _listing!['brand'] ?? '';
    final model = _listing!['model'] ?? '';
    final title = _listing!['adTitle'] ?? '$brand $model'.trim();
    final price = _listing!['price'] ?? '--';
    final location = _listing!['location'] ?? 'No Location';
    final transmission = _listing!['transmission'] ?? 'Automatic';
    final year = _listing!['year'] ?? '--';
    final km = _listing!['kmDriven'] ?? '--';
    final owners = _listing!['noOfOwners'] ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Carousel with Dot Indicators
                    _buildImageCarousel(photos),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Favorite Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _isFavorited = !_isFavorited),
                                child: Icon(
                                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                                  color: _isFavorited ? Colors.red : AppColors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Price
                          Text(
                            '₹ $price',
                            style: GoogleFonts.poppins(
                              color: AppColors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Condition and Location
                          Text(
                            'Condition : Good',
                            style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
                          ),
                          Text(
                            'Location : $location',
                            style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 24),

                          // Vehicle Details Grid (4 boxes)
                          Text(
                            'Vehicle Details',
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailsGrid(year, km, transmission, owners),

                          const SizedBox(height: 24),

                          // Action Buttons
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isChatLoading ? null : _startChat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isChatLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      'Chat Now',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Similar Options
                          if (_similarListings.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Similar Options',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // See more listings in this category
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'See More',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward, color: AppColors.grey, size: 14),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSimilarOptionsList(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
          ),
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
            child: const Icon(Icons.more_vert, color: AppColors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<dynamic> photos) {
    if (photos.isEmpty) {
      return Container(
        height: 240,
        width: double.infinity,
        color: AppColors.cardBg,
        child: const Icon(Icons.electric_car_outlined, color: AppColors.green, size: 64),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photoUrl = photos[index] as String;
              return photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppColors.cardBg,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.green),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.cardBg,
                        child: const Icon(Icons.electric_car_outlined, color: AppColors.green, size: 64),
                      ),
                    )
                  : Container(
                      color: AppColors.cardBg,
                      child: const Icon(Icons.electric_car_outlined, color: AppColors.green, size: 64),
                    );
            },
          ),
        ),

        // Dot indicators
        Positioned(
          bottom: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              photos.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? AppColors.green : AppColors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(dynamic year, dynamic km, dynamic transmission, dynamic owners) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildDetailBox(Icons.calendar_today_outlined, 'Year', '$year'),
        _buildDetailBox(Icons.speed_outlined, 'KM Driven', '$km km'),
        _buildDetailBox(Icons.settings_suggest_outlined, 'Transmission', '$transmission'),
        _buildDetailBox(Icons.person_outline_rounded, 'Owners', '$owners Owner'),
      ],
    );
  }

  Widget _buildDetailBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.borderColor, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppColors.grey,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarOptionsList() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _similarListings.length,
        itemBuilder: (context, index) {
          final item = _similarListings[index] as Map<String, dynamic>;
          final photos = item['photoUrls'] as List? ?? [];
          final name = '${item['brand'] ?? ''} ${item['model'] ?? ''}'.trim();
          final price = item['price'] ?? '--';
          final km = item['kmDriven'] ?? '--';
          final imgUrl = photos.isNotEmpty ? photos[0] as String : '';

          return GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => VehicleDetailScreen(listingId: item['_id'] as String),
                ),
              );
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderColor, width: 0.8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: imgUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFF1A2F3D),
                              child: const Icon(Icons.electric_car_outlined, color: AppColors.green, size: 28),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF1A2F3D),
                            child: const Icon(Icons.electric_car_outlined, color: AppColors.green, size: 28),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹ $price',
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$km km',
                          style: GoogleFonts.poppins(
                            color: AppColors.grey,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
