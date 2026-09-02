import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Minimal shared Firestore / Auth helpers.
/// Full [FireStoreUtils] monolith stays in each app.
class QlypFirestoreService {
  const QlypFirestoreService._();

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static String? getCurrentUid() => auth.currentUser?.uid;

  static bool get isAuthenticated => auth.currentUser != null;

  /// Returns true when Firebase Auth has a signed-in user.
  /// Apps may pass [userExistsCheck] for Firestore profile validation.
  static Future<bool> isLogin({
    Future<bool> Function(String uid)? userExistsCheck,
    String? cachedUserId,
  }) async {
    final uid = auth.currentUser?.uid ?? cachedUserId;
    if (uid == null || uid.isEmpty) {
      return false;
    }
    if (userExistsCheck != null) {
      return userExistsCheck(uid);
    }
    return auth.currentUser != null;
  }
}
