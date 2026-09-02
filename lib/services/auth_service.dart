import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Callbacks for phone OTP flow — apps provide UI/navigation.
typedef PhoneOtpCodeSent = void Function({
  required String verificationId,
  int? resendToken,
});

typedef PhoneOtpFailed = void Function(FirebaseAuthException exception);

typedef PhoneOtpError = void Function(Object error);

/// Shared Firebase Auth logic extracted from both login controllers.
class QlypAuthService {
  const QlypAuthService._();

  static Future<void> sendPhoneOtp({
    required String fullPhoneNumber,
    required PhoneOtpCodeSent onCodeSent,
    required PhoneOtpFailed onVerificationFailed,
    required PhoneOtpError onError,
    void Function(PhoneAuthCredential credential)? onVerificationCompleted,
    void Function(String verificationId)? onCodeAutoRetrievalTimeout,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      verificationCompleted: onVerificationCompleted ?? (_) {},
      verificationFailed: onVerificationFailed,
      codeSent: (verificationId, resendToken) {
        onCodeSent(verificationId: verificationId, resendToken: resendToken);
      },
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout ?? (_) {},
    ).catchError(onError);
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      if (googleUser.id.isEmpty) return null;
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return {
        'appleCredential': appleCredential,
        'userCredential': userCredential,
      };
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
