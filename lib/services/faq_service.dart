import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/faq_item.dart';

/// Loads and filters FAQ documents from the `faq` Firestore collection.
///
/// Usage:
///   final items = await FaqService.loadForAppType('customer');
///   final items = await FaqService.loadForAppType('driver');
class FaqService {
  const FaqService._();

  static const _collection = 'faq';

  /// Returns all enabled FAQ items visible for [appType] ('customer' or 'driver'),
  /// sorted by category then order field.
  static Future<List<FaqItem>> loadForAppType(String appType) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_collection)
          .where('enable', isEqualTo: true)
          .get();

      final items = <FaqItem>[];
      for (final doc in snap.docs) {
        final item = FaqItem.fromFirestore(doc.data());
        if (item.visibleFor(appType)) {
          items.add(item);
        }
      }

      items.sort(FaqItem.compare);
      return items;
    } catch (e) {
      debugPrint('FaqService.loadForAppType: $e');
      return const [];
    }
  }
}