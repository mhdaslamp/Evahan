import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EVahan Privacy Policy',
                      style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Last Updated: 21-06-2026',
                      style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.borderColor),
                    const SizedBox(height: 16),
                    _buildSection(
                      '1. Information We Collect',
                      'We collect information you provide directly to us (e.g. phone number during registration, name, profile details, advertisements details, and listing photos) and basic device identifiers to operate the EVahan service.',
                    ),
                    _buildSection(
                      '2. How We Use Your Information',
                      'We use the gathered information to:\n• Verify your credentials via Firebase Authentication\n• Store profile details and showcase listings\n• Enable real-time chat via our WebSocket messaging service\n• Host listing photos securely using Cloudinary\n• Keep the platform secure and prevent fraudulent activity',
                    ),
                    _buildSection(
                      '3. Sharing and Disclosures',
                      'EVahan does not sell or distribute your private contact details to third parties. We share upload streams and authentication metadata with verified service providers (Firebase and Cloudinary) solely to facilitate storage and OTP processes.',
                    ),
                    _buildSection(
                      '4. Security of Data',
                      'We employ standard network safety practices to prevent unauthorized access or modification to your personal database objects. However, please remember that no system over the internet is completely immune to cyber risks.',
                    ),
                    _buildSection(
                      '5. User Controls and Data Deletion',
                      'You can update your personal profile records at any time. When you mark a listing as "deleted", it is immediately hidden from the public feed. For account removal or database wipe requests, you can contact our support team.',
                    ),
                    _buildSection(
                      '6. Contact Information',
                      'If you have questions regarding this Privacy Policy or data handling, reach out to us:\nEmail: evahanapp@gmail.com',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'By using EVahan, you acknowledge and agree to this Privacy Policy.',
                      style: GoogleFonts.poppins(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Text(
            'Privacy Policy',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              color: AppColors.grey,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
