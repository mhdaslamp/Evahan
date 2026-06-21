import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'socket_service.dart';
import 'api_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  /// Sign in with Google and link/sign-in with Firebase Auth
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    // Disconnect the socket BEFORE clearing tokens so the
    // singleton doesn't carry the old user's identity on next login.
    SocketService().disconnect();
    await ApiService.clearToken();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}

class AuthResult {
  final bool success;
  final String? error;

  AuthResult({required this.success, this.error});
}
