/// FAQ item as stored in the `faq` Firestore collection (S4-6b).
///
/// Fields added by the CMS in S4-6b-1:
///   app_type : 'customer' | 'driver' | 'all'  (absent -> 'customer')
///   category : one of [categoryOrder]           (absent -> 'general')
///   order    : int >= 0                         (absent -> placed at end)
class FaqItem {
  const FaqItem({
    required this.id,
    required this.titleFr,
    required this.titleEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.appType,
    required this.category,
    required this.order,
  });

  final String id;
  final String titleFr;
  final String titleEn;
  final String descriptionFr;
  final String descriptionEn;

  /// 'customer' | 'driver' | 'all'
  final String appType;

  /// 'general' | 'rides' | 'payment' | 'account' | 'safety' | 'earnings' | 'documents'
  final String category;

  final int order;

  /// Canonical category order for grouping/sorting.
  static const List<String> categoryOrder = [
    'general',
    'rides',
    'payment',
    'account',
    'safety',
    'earnings',
    'documents',
  ];

  String title({required bool french}) => french ? titleFr : titleEn;

  String description({required bool french}) =>
      french ? descriptionFr : descriptionEn;

  /// Whether this item is visible to [requestedAppType] ('customer' or 'driver').
  bool visibleFor(String requestedAppType) =>
      appType == requestedAppType || appType == 'all';

  // -----------------------------------------------------------------------
  // Factory
  // -----------------------------------------------------------------------

  factory FaqItem.fromFirestore(Map<String, dynamic> json) {
    return FaqItem(
      id: (json['id'] ?? '').toString(),
      titleFr: _resolveTitle(json['title'], 'fr'),
      titleEn: _resolveTitle(json['title'], 'en'),
      descriptionFr: _resolveDescription(json['description'], 'fr'),
      descriptionEn: _resolveDescription(json['description'], 'en'),
      appType: (json['app_type'] as String? ?? 'customer'),
      category: (json['category'] as String? ?? 'general'),
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 999,
    );
  }

  static String _resolveTitle(dynamic field, String lang) {
    if (field is! List) return '';
    for (final item in field) {
      if (item is Map && item['type'] == lang) {
        return (item['title'] ?? '').toString();
      }
    }
    return '';
  }

  static String _resolveDescription(dynamic field, String lang) {
    if (field is! List) return '';
    for (final item in field) {
      if (item is Map && item['type'] == lang) {
        return (item['description'] ?? '').toString();
      }
    }
    return '';
  }

  // -----------------------------------------------------------------------
  // Sorting
  // -----------------------------------------------------------------------

  /// Index of [category] in [categoryOrder]; unknown categories go last.
  int get categoryIndex {
    final i = categoryOrder.indexOf(category);
    return i < 0 ? categoryOrder.length : i;
  }

  /// Comparator: primary = category index, secondary = order field.
  static int compare(FaqItem a, FaqItem b) {
    final ci = a.categoryIndex.compareTo(b.categoryIndex);
    if (ci != 0) return ci;
    return a.order.compareTo(b.order);
  }
}