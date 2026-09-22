import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:qlyp_core/constants/qlyp_vehicle_category_assets.dart';

/// Result of GET /api/vehicle-image/resolve (defensive parsing).
class QlypVehicleImageResolveResult {
  const QlypVehicleImageResolveResult({
    this.imageUrl,
    this.categoryKey,
    this.resolution,
    this.networkError = false,
  });

  final String? imageUrl;
  final String? categoryKey;
  final String? resolution;
  final bool networkError;

  bool get hasRemoteImage => (imageUrl ?? '').trim().isNotEmpty;

  String effectiveCategoryKey(String fallback) {
    return QlypVehicleCategoryAssets.resolvePreviewCategoryKey(
      apiCategory: categoryKey,
      serviceTierFallback: fallback,
    );
  }
}

/// Authenticated client for the vehicle preview resolve endpoint.
class QlypVehicleImageApi {
  QlypVehicleImageApi._();

  static Future<QlypVehicleImageResolveResult> resolve({
    required String apiBaseUrl,
    required Future<String?> Function() idToken,
    String? makeId,
    String? modelId,
    String? colorId,
    String? year,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final token = await idToken();
      if (token == null || token.isEmpty) {
        return const QlypVehicleImageResolveResult(networkError: true);
      }

      final query = <String, String>{};
      final resolvedMakeId = QlypVehicleCategoryAssets.numericIdOrNull(makeId);
      final resolvedModelId = QlypVehicleCategoryAssets.numericIdOrNull(modelId);
      final resolvedColorId = QlypVehicleCategoryAssets.numericIdOrNull(colorId);
      final resolvedYear = (year ?? '').trim();

      if (resolvedMakeId != null) query['make_id'] = resolvedMakeId;
      if (resolvedModelId != null) query['model_id'] = resolvedModelId;
      if (resolvedColorId != null) query['color_id'] = resolvedColorId;
      if (resolvedYear.isNotEmpty) query['year'] = resolvedYear;

      if (query.length < 4) {
        return const QlypVehicleImageResolveResult(networkError: true);
      }

      final uri = Uri.parse('${apiBaseUrl}api/vehicle-image/resolve')
          .replace(queryParameters: query);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(timeout);

      if (response.statusCode != 200) {
        return const QlypVehicleImageResolveResult(networkError: true);
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const QlypVehicleImageResolveResult(networkError: true);
      }

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      final resolution = _readString(data, ['resolution']);
      final imageUrl = _readString(data, ['image_url', 'imageUrl', 'url']);

      if (imageUrl != null && imageUrl.isNotEmpty) {
        return QlypVehicleImageResolveResult(
          imageUrl: imageUrl,
          resolution: resolution,
        );
      }

      final fallbackCategory = _readString(data, [
        'fallback_category',
        'fallbackCategory',
        'category_key',
        'categoryKey',
        'category',
      ]);

      if (resolution == 'category_fallback' ||
          (fallbackCategory ?? '').isNotEmpty) {
        return QlypVehicleImageResolveResult(
          categoryKey: fallbackCategory ?? 'sedan',
          resolution: resolution ?? 'category_fallback',
        );
      }

      return const QlypVehicleImageResolveResult(networkError: true);
    } catch (_) {
      return const QlypVehicleImageResolveResult(networkError: true);
    }
  }

  static String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
