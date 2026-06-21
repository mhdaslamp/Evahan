import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
                      'EVahan Terms & Conditions',
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
                      '1. Acceptance of Terms',
                      'By accessing or using EVahan, you agree to be bound by these Terms and Conditions. If you do not agree, you must not use the platform.',
                    ),
                    _buildSection(
                      '2. Platform Role',
                      'EVahan is an online marketplace that connects buyers and sellers of electric vehicles. EVahan does not own, buy, sell, inspect, certify, guarantee, endorse, or broker any vehicle listed on the platform. All transactions occur directly between users.',
                    ),
                    _buildSection(
                      '3. Eligibility',
                      'Users must:\n• Be at least 18 years old\n• Have legal capacity to enter contracts\n• Provide accurate registration information',
                    ),
                    _buildSection(
                      '4. User Responsibilities',
                      'Users agree to:\n• Provide truthful information\n• Maintain account security\n• Comply with applicable laws\n• Avoid fraudulent or deceptive conduct\n• Respect other users\n\nUsers are solely responsible for activity conducted through their accounts.',
                    ),
                    _buildSection(
                      '5. Vehicle Listings',
                      'Sellers must:\n• Provide accurate vehicle information\n• Upload genuine photographs\n• Disclose known defects\n• Accurately represent battery condition\n• Possess legal ownership or authority to sell the vehicle\n\nProhibited listings include: stolen vehicles, duplicate listings, misleading ads, and illegal goods. EVahan may remove listings at its sole discretion.',
                    ),
                    _buildSection(
                      '6. Ownership Declaration',
                      'By posting a listing, sellers represent and warrant that:\n• They are the lawful owner of the vehicle or authorized to sell it.\n• Information provided is accurate to the best of their knowledge.\n• The sale does not violate any law or third-party rights.\n\nEVahan may request supporting ownership documents at any time. Failure to provide documentation may result in listing removal or account suspension.',
                    ),
                    _buildSection(
                      '7. Buyer Responsibilities',
                      'Buyers are solely responsible for independently verifying:\n• Vehicle ownership & registration documents\n• Insurance status & battery health\n• Vehicle condition & service history\n• Warranty status & loan/lien status\n\nBuyers should inspect vehicles before completing transactions.',
                    ),
                    _buildSection(
                      '8. EV-Specific Disclaimer',
                      'EVahan does not verify:\n• Battery health reports\n• Charging cycle counts\n• Vehicle range claims\n• Manufacturer warranty status\n• Service history accuracy\n\nUsers must independently verify all such information.',
                    ),
                    _buildSection(
                      '9. Prohibited Conduct',
                      'Users shall not:\n• Impersonate others or upload false info\n• Use automated scraping tools\n• Upload malicious software\n• Harass users or conduct unlawful activities\n• Circumvent platform security measures',
                    ),
                    _buildSection(
                      '10. Fraud Prevention',
                      'EVahan reserves the right to:\n• Investigate suspicious activity\n• Request identity verification or ownership docs\n• Suspend or terminate accounts\n• Remove listings without notice',
                    ),
                    _buildSection(
                      '11. Intellectual Property',
                      'All platform software, branding, trademarks, logos, designs, and content owned by EVahan remain the exclusive property of EVahan. Users may not copy, modify, distribute, or exploit platform content without permission.',
                    ),
                    _buildSection(
                      '12. Account Suspension',
                      'EVahan may suspend, restrict, or terminate access if a user violates these Terms, engages in fraud, misuses the platform, or creates risk to users or EVahan.',
                    ),
                    _buildSection(
                      '13. Limitation of Liability',
                      'To the maximum extent permitted by law, EVahan shall not be liable for transactions between users, vehicle defects, misrepresentations, ownership disputes, financial losses, or data loss. Users assume all risks associated with vehicle transactions.',
                    ),
                    _buildSection(
                      '14. Indemnification',
                      'Users agree to indemnify and hold harmless EVahan, its owners, employees, and affiliates from claims, losses, liabilities, damages, and expenses arising from user content, vehicle listings, transactions, violations of law, or breach of these Terms.',
                    ),
                    _buildSection(
                      '15. Governing Law',
                      'These Terms shall be governed by the laws of India. Any disputes arising from these Terms shall be subject to the exclusive jurisdiction of the courts located in Kerala, India.',
                    ),
                    _buildSection(
                      '16. Changes to Terms',
                      'EVahan may modify these Terms at any time. Continued use of the platform after changes become effective constitutes acceptance of the revised Terms.',
                    ),
                    _buildSection(
                      '17. Contact Information',
                      'For support or legal inquiries:\nEmail: evahanapp@gmail.com',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'By using EVahan, you acknowledge and agree to these Terms and Conditions.',
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
            'Terms & Conditions',
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
