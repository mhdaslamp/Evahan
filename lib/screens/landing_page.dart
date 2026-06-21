import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await AuthService.signInWithGoogle();
      if (userCredential == null) {
        // User cancelled the sign-in flow
        setState(() => _isLoading = false);
        return;
      }

      // Get Firebase ID Token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception("Failed to retrieve ID Token");
      }

      // Exchange with backend for JWT
      await ApiService.loginWithFirebaseToken(idToken);

      if (!mounted) return;

      // Navigate to Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sign in failed. Check network/setup. Error: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),

              /// LOGO TEXT
              _buildLogoText(),

              const SizedBox(height: 40),

              /// TAGLINE
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Drive ',
                      style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: 'Smarter.\n',
                      style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: 'Buy & Sell ',
                      style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: 'Safer.',
                      style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// SUBTITLE
              Text(
                'Verified battery health, trusted resale, and everything '
                'you need to keep your EV running.',
                style: GoogleFonts.poppins(
                  color: AppColors.grey,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),

              const Spacer(flex: 2),

              /// CONTINUE WITH GOOGLE
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google.png',
                              height: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              /*
              const SizedBox(height: 14),

              /// CONTINUE WITH PHONE
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PhoneInputScreen(),
                    ),
                  ),
                  child: Text(
                    'Continue with Phone',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// LOGIN WITH EMAIL
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: Color(0xFF2A3F4D), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Email login
                  },
                  child: Text(
                    'Login with Email',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              */

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the "EVAHAN" text logo with green EV prefix
  Widget _buildLogoText() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'EV',
            style: GoogleFonts.poppins(
              color: AppColors.green,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          TextSpan(
            text: 'AHAN',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
