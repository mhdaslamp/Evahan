import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  bool _isLoading = false;
  int _secondsRemaining = 20;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 20;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _resendOtp() async {
    setState(() => _canResend = false);
    await AuthService.sendOtp(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (_) => _startCountdown(),
      onError: (e) {
        _showError(e);
        setState(() => _canResend = true);
      },
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _pinController.text.trim();
    if (otp.length != 6) {
      _showError('Please enter all 6 digits.');
      return;
    }

    setState(() => _isLoading = true);

    // Step 1: Verify OTP with Firebase
    final result = await AuthService.verifyOtp(otp);
    if (!mounted) return;

    if (!result.success) {
      setState(() => _isLoading = false);
      _showError(result.error ?? 'OTP verification failed.');
      return;
    }

    // Step 2: Get Firebase ID token
    try {
      final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
      if (!mounted) return;

      // Step 3: Exchange Firebase token for backend JWT
      await ApiService.loginWithFirebaseToken(idToken!);
      if (!mounted) return;

      // Step 4: Go to home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        _showError('Cannot reach server. Check your network or backend IP.');
      } else {
        _showError('Server error (${e.response?.statusCode ?? 'unknown'}). Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Login failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pinput theme
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.green, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.green.withOpacity(0.5), width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              /// LOGO
              Center(
                child: Image.asset(
                  'assets/images/evahan_logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 48),

              /// TITLE
              Text(
                'Enter the OTP',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              /// DESCRIPTION
              Text(
                "We'll send you a verification code on the same number",
                style: GoogleFonts.poppins(
                  color: AppColors.grey,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              /// OTP INPUT BOXES
              Center(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  autofocus: true,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) => _verifyOtp(),
                ),
              ),

              const SizedBox(height: 24),

              /// RESEND TIMER
              Row(
                children: [
                  Text(
                    'Resend OTP ',
                    style: GoogleFonts.poppins(
                      color: AppColors.grey,
                      fontSize: 13,
                    ),
                  ),
                  if (!_canResend)
                    Text(
                      'in ${_secondsRemaining}s',
                      style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _resendOtp,
                      child: Text(
                        'Resend now',
                        style: GoogleFonts.poppins(
                          color: AppColors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.green,
                        ),
                      ),
                    ),
                ],
              ),

              const Spacer(),

              /// NEXT BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Next',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
