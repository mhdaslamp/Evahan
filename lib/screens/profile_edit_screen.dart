import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/api_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final String _countryCode = '+91';
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiService.getMe();
      final user = data['user'] as Map<String, dynamic>?;
      if (mounted && user != null) {
        setState(() {
          _nameController.text = user['name'] as String? ?? '';
          _bioController.text = user['about'] as String? ?? '';
          _emailController.text = user['email'] as String? ?? '';
          _phoneController.text = user['phone'] as String? ?? '';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        about: _bioController.text.trim(),
      );
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile saved!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save. Please try again.',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildActionBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _sectionTitle('Basic information'),
                          const SizedBox(height: 20),
                          _buildBasicInfoSection(),
                          const SizedBox(height: 8),
                          const Divider(color: AppColors.borderColor),
                          const SizedBox(height: 20),
                          _sectionTitle('Contact information'),
                          const SizedBox(height: 20),
                          _buildContactInfoSection(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EvBottomNavBar(
        currentTab: NavTab.profile,
        onTap: (_) {},
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
            child: const Icon(Icons.close, color: AppColors.white, size: 22),
          ),
          GestureDetector(
            onTap: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.green,
                    ),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with Edit
            Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFFD9D9D9),
                  child: Icon(Icons.person, color: Colors.white, size: 38),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    // TODO: image picker
                  },
                  child: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Name field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your name',
                    style: GoogleFonts.poppins(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                  TextField(
                    controller: _nameController,
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.borderColor, width: 1.2),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.green, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Bio field
        TextField(
          controller: _bioController,
          style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Something about you',
            hintStyle: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor, width: 1),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.green, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country + Phone label row
        Row(
          children: [
            Text(
              'Country',
              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
            ),
            const SizedBox(width: 60),
            Text(
              'Phone Number',
              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Country code + Phone number
        Row(
          children: [
            // Country code
            SizedBox(
              width: 72,
              child: GestureDetector(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _countryCode,
                      style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(
                      color: AppColors.borderColor,
                      thickness: 1.2,
                      height: 8,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Phone number field
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.poppins(color: AppColors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '1234567890',
                  hintStyle: GoogleFonts.poppins(color: AppColors.grey, fontSize: 16),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.borderColor, width: 1.2),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.green, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Yay! Your number is verified.',
          style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12),
        ),
        const SizedBox(height: 24),
        // Email field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Email',
            hintStyle: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor, width: 1),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.green, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "You have verified your email. It's important to allow us to securely communicate with you.",
          style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }
}
