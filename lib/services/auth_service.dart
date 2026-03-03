import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? _verificationId;
  static int? _resendToken;

  /// Send OTP to the given phone number (e.g. "+919876543210")
  static Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(PhoneAuthCredential credential)? onAutoVerify,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (onAutoVerify != null) onAutoVerify(credential);
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        String message = 'Verification failed. Please try again.';
        if (e.code == 'invalid-phone-number') {
          message = 'Invalid phone number. Please check and retry.';
        } else if (e.code == 'too-many-requests') {
          message = 'Too many requests. Please wait and try again.';
        } else if (e.code == 'billing-not-enabled') {
          message = 'SMS not available. Please use a test phone number.';
        }
        onError(message);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Verify the OTP entered by the user
  static Future<AuthResult> verifyOtp(String otp) async {
    if (_verificationId == null) {
      return AuthResult(
          success: false,
          error: 'Session expired. Please request a new OTP.');
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        return AuthResult(
            success: false, error: 'Login failed. Please try again.');
      }
      // User record is created by the Node.js backend (/api/auth/login)
      // No Firestore writes needed here.
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      String message = 'Invalid OTP. Please try again.';
      if (e.code == 'invalid-verification-code') {
        message = 'Incorrect OTP. Please check and retry.';
      } else if (e.code == 'session-expired') {
        message = 'OTP expired. Please request a new one.';
      }
      return AuthResult(success: false, error: message);
    } catch (_) {
      return AuthResult(
          success: false,
          error: 'Something went wrong. Please try again.');
    }
  }

  static User? get currentUser => _auth.currentUser;

  static Future<void> signOut() async => _auth.signOut();
}

class AuthResult {
  final bool success;
  final String? error;

  AuthResult({required this.success, this.error});
}
