import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/nav_helper.dart';
import '../services/api_service.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiService.getMe();
      if (mounted) setState(() { _user = data['user'] as Map<String, dynamic>?; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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
            _buildCompletionBanner(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildProfileInfo(),
                          const Divider(height: 1, color: AppColors.borderColor),
                          _buildEmptyListings(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EvBottomNavBar(
        currentTab: NavTab.profile,
        onTap: (tab) => handleNavTap(context, tab, NavTab.profile),
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
                  ),
                ),
                TextSpan(
                  text: 'AHAN',
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          // Hamburger
          Column(
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
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.white, size: 22),
          ),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.share_outlined, color: AppColors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
      ),
      child: Container(
        width: double.infinity,
        color: AppColors.green,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'You have 3 steps left. Complete your profile!',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    final name = _user?['name'] as String? ?? 'Name';
    final emailVerified = _user?['emailVerified'] as bool? ?? false;
    final phoneVerified = _user?['phoneVerified'] as bool? ?? false;
    final memberSince = _user?['createdAt'] != null
        ? _formatDate(_user!['createdAt'] as String)
        : 'Recently';
    final followers = _user?['followers'] ?? 0;
    final following = _user?['following'] ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back and share row
          _buildActionBar(),
          const SizedBox(height: 8),
          // Avatar + Name + Phone
          Row(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: const Color(0xFFD9D9D9),
                child: const Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'No Name',
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if ((_user?['phone'] as String? ?? '').isNotEmpty)
                    Text(
                      _user!['phone'] as String,
                      style: GoogleFonts.poppins(
                        color: AppColors.grey,
                        fontSize: 13,
                      ),
                    ),
                  if ((_user?['email'] as String? ?? '').isNotEmpty)
                    Text(
                      _user!['email'] as String,
                      style: GoogleFonts.poppins(
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Member since
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: AppColors.grey, size: 20),
              const SizedBox(width: 10),
              Text(
                'Member since',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                memberSince,
                style: GoogleFonts.poppins(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Followers / Following
          Row(
            children: [
              Icon(Icons.people_outline, color: AppColors.grey, size: 20),
              const SizedBox(width: 10),
              Text(
                '$followers Followers',
                style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('|', style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14)),
              ),
              Text(
                '$following Following',
                style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Verified with
          Text(
            'User verified with',
            style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (emailVerified)
                _verifiedIcon(Icons.mail_outline),
              if (emailVerified) const SizedBox(width: 10),
              if (phoneVerified)
                _verifiedIcon(Icons.phone_outlined),
              // Show default icons if not loaded yet
              if (!emailVerified && !phoneVerified) ...[
                _verifiedIcon(Icons.mail_outline),
                const SizedBox(width: 10),
                _verifiedIcon(Icons.phone_outlined),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Edit Profile button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              ).then((_) => _loadProfile()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifiedIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: AppColors.white),
    );
  }

  Widget _buildEmptyListings() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          // Clipboard stack icon
          SizedBox(
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 80,
                  top: 5,
                  child: Transform.rotate(
                    angle: 0.15,
                    child: Icon(Icons.assignment_outlined,
                        size: 72, color: AppColors.grey),
                  ),
                ),
                Positioned(
                  left: 65,
                  top: 0,
                  child: Transform.rotate(
                    angle: -0.05,
                    child: Icon(Icons.assignment,
                        size: 72, color: AppColors.borderColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "You haven't listed anything yet",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Let go of what you don't use anymore",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 44,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Start Selling',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
