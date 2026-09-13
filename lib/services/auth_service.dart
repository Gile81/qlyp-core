import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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

  /// Web client ID from Firebase / google-services.json (type 3 OAuth client).
  /// Required on Android for a non-null Google [idToken].
  static const String googleWebClientId =
      '839437715220-614afgfqpfric05nf6peit1ckan23cfd.apps.googleusercontent.com';

  /// Strips formatting and returns E.164 (`+15145550100`).
  static String normalizeToE164(String countryCode, String localNumber) {
    final ccDigits = countryCode.replaceAll(RegExp(r'\D'), '');
    var localDigits = localNumber.replaceAll(RegExp(r'\D'), '');
    if (ccDigits.isNotEmpty &&
        localDigits.startsWith(ccDigits) &&
        localDigits.length > ccDigits.length) {
      return '+$localDigits';
    }
    return '+$ccDigits$localDigits';
  }

  /// Debug-only: skip Play Integrity / reCAPTCHA so Firebase test numbers work.
  /// Must be called after [Firebase.initializeApp]. Never enable in release.
  static Future<void> configurePhoneAuthForDebugIfNeeded() async {
    if (!kDebugMode) return;
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
    debugPrint(
      'QlypAuthService: appVerificationDisabledForTesting=true (debug builds only)',
    );
  }

  /// Debug-only App Check provider. Register the debug token printed in logcat
  /// under Firebase Console → App Check → Apps → Manage debug tokens.
  static Future<void> configureAppCheckForDebugIfNeeded() async {
    if (!kDebugMode) return;
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      debugPrint(
        'QlypAuthService: App Check debug provider active — '
        'register the debug token in Firebase Console if Firestore denies writes',
      );
    } catch (e, st) {
      debugPrint('QlypAuthService: App Check debug setup failed: $e\n$st');
    }
  }

  static Future<void> sendPhoneOtp({
    required String fullPhoneNumber,
    required PhoneOtpCodeSent onCodeSent,
    required PhoneOtpFailed onVerificationFailed,
    required PhoneOtpError onError,
    void Function(PhoneAuthCredential credential)? onVerificationCompleted,
    void Function(String verificationId)? onCodeAutoRetrievalTimeout,
  }) async {
    final digits = fullPhoneNumber.replaceAll(RegExp(r'\D'), '');
    final phone = digits.isEmpty ? fullPhoneNumber : '+$digits';
    if (kDebugMode) {
      debugPrint('QlypAuthService.sendPhoneOtp → $phone');
    }
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
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
      await googleSignIn.initialize(serverClientId: googleWebClientId);
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      if (googleUser.id.isEmpty) return null;
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        debugPrint(
          'Google Sign-In: idToken null — verify SHA-1 in Firebase and '
          'googleWebClientId',
        );
        return null;
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e, st) {
      debugPrint('Google Sign-In Error: $e\n$st');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final hashedNonce = sha256ofString(rawNonce);
      debugPrint(
        'Apple Sign-In: nonce generated (len=${rawNonce.length}), '
        'hashed nonce sent to Apple (len=${hashedNonce.length})',
      );
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      debugPrint(
        'Apple Sign-In: Firebase credential created with rawNonce '
        '(replay protection active)',
      );
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
