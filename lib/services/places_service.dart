import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// Canadian locale passed to Google Places.
enum PlacesLanguage {
  frCa('fr-CA'),
  enCa('en-CA');

  const PlacesLanguage(this.code);

  final String code;

  /// Maps app language codes (`fr`, `en`, `fr-CA`, `en-CA`, …) to Canadian locale.
  static PlacesLanguage fromAppLanguage(String languageCode) {
    final normalized = languageCode.trim().toLowerCase();
    if (normalized.startsWith('fr')) {
      return PlacesLanguage.frCa;
    }
    return PlacesLanguage.enCa;
  }
}

enum PlaceSuggestionSource {
  google,
}

/// Lat/lng pair usable by Mapbox or any map provider (no Google Maps types).
class PlaceCoordinates {
  const PlaceCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  String toString() => 'PlaceCoordinates($latitude, $longitude)';
}

/// Autocomplete row from Google Places.
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.source,
    this.title,
    this.mainText,
    this.secondaryText,
  });

  final String placeId;
  final String description;
  final String? title;
  final String? mainText;
  final String? secondaryText;
  final PlaceSuggestionSource source;

  factory PlaceSuggestion.google({
    required String placeId,
    required String description,
    String? mainText,
    String? secondaryText,
  }) {
    return PlaceSuggestion(
      placeId: placeId,
      description: description,
      title: mainText,
      mainText: mainText,
      secondaryText: secondaryText,
      source: PlaceSuggestionSource.google,
    );
  }
}

/// Resolved place with coordinates and structured address fields.
class PlaceDetails {
  const PlaceDetails({
    required this.placeId,
    required this.coordinates,
    required this.formattedAddress,
    this.name,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.street,
    this.source = PlaceSuggestionSource.google,
  });

  final String placeId;
  final PlaceCoordinates coordinates;
  final String formattedAddress;
  final String? name;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? street;
  final PlaceSuggestionSource source;
}

/// Pure address autocomplete + geocoding for Canada via Google Places.
///
/// Session tokens are cycled per Google billing session (generate on first
/// keystroke, invalidate after selection).
class PlacesService {
  PlacesService({
    String? googleApiKey,
    required String languageCode,
    http.Client? httpClient,
  })  : _googleApiKey = googleApiKey?.trim(),
        _language = PlacesLanguage.fromAppLanguage(languageCode),
        _client = httpClient ?? http.Client(),
        _ownsClient = httpClient == null;

  static const _uuid = Uuid();
  static const _googleAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const _googleDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const _googleGeocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  final String? _googleApiKey;
  final PlacesLanguage _language;
  final http.Client _client;
  final bool _ownsClient;

  String? _sessionToken;

  bool get hasGoogleApiKey {
    final key = _googleApiKey;
    return key != null && key.isNotEmpty;
  }

  /// Active session token, if any (read-only — use [ensureSessionToken] / [invalidateSession]).
  String? get sessionToken => _sessionToken;

  /// Call on each keystroke. Generates a session token on the first non-empty
  /// character and clears it when the query is emptied.
  void onQueryChanged(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      invalidateSession();
      return;
    }
    ensureSessionToken();
  }

  /// Starts a Google Places billing session if one is not already active.
  void ensureSessionToken() {
    _sessionToken ??= _uuid.v4();
  }

  /// Ends the current Google Places billing session (call after place selection).
  void invalidateSession() {
    _sessionToken = null;
  }

  /// Autocomplete search restricted to Canada (`components=country:ca`).
  ///
  /// When [originLat] / [originLng] are provided they bias Google results.
  Future<List<PlaceSuggestion>> search(
    String query, {
    double? originLat,
    double? originLng,
  }) async {
    final q = query.trim();
    if (q.isEmpty) {
      return const [];
    }

    onQueryChanged(q);

    if (!hasGoogleApiKey) {
      return const [];
    }

    try {
      return await _searchGoogle(
        q,
        originLat: originLat,
        originLng: originLng,
      );
    } catch (error, stack) {
      debugPrint('PlacesService Google autocomplete failed: $error\n$stack');
      return const [];
    }
  }

  /// Resolves a suggestion to full [PlaceDetails] with coordinates.
  ///
  /// Invalidates the session token after a successful Google resolution.
  Future<PlaceDetails?> resolveSuggestion(PlaceSuggestion suggestion) async {
    if (!hasGoogleApiKey) {
      return null;
    }

    var details = await _getGooglePlaceDetails(suggestion.placeId);
    if (details != null) {
      invalidateSession();
      return details;
    }

    // Geocode fallback when Place Details is blocked.
    details = await _geocodeGoogle(suggestion.description);
    if (details != null) {
      invalidateSession();
      return details;
    }

    return null;
  }

  /// Reverse-geocode coordinates to a structured address.
  Future<PlaceDetails?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (!hasGoogleApiKey) {
      return null;
    }

    try {
      return await _reverseGeocodeGoogle(latitude, longitude);
    } catch (error, stack) {
      debugPrint('PlacesService Google reverse geocode failed: $error\n$stack');
      return null;
    }
  }

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Future<List<PlaceSuggestion>> _searchGoogle(
    String query, {
    double? originLat,
    double? originLng,
  }) async {
    final params = <String, String>{
      'input': query,
      'key': _googleApiKey!,
      'components': 'country:ca',
      'language': _language.code,
    };

    if (_sessionToken != null) {
      params['sessiontoken'] = _sessionToken!;
    }

    if (originLat != null && originLng != null) {
      params['location'] = '$originLat,$originLng';
      params['radius'] = '50000';
    }

    final uri = Uri.parse(_googleAutocompleteUrl).replace(queryParameters: params);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Google autocomplete HTTP ${response.statusCode}');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final status = body['status'] as String? ?? '';
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception('Google autocomplete status: $status');
    }

    final predictions = body['predictions'] as List<dynamic>? ?? const [];
    return predictions
        .whereType<Map<String, dynamic>>()
        .map((prediction) {
          final structured = prediction['structured_formatting']
              as Map<String, dynamic>?;
          return PlaceSuggestion.google(
            placeId: prediction['place_id'] as String? ?? '',
            description: prediction['description'] as String? ?? '',
            mainText: structured?['main_text'] as String?,
            secondaryText: structured?['secondary_text'] as String?,
          );
        })
        .where((s) => s.placeId.isNotEmpty && s.description.isNotEmpty)
        .toList();
  }

  Future<PlaceDetails?> _getGooglePlaceDetails(String placeId) async {
    final params = <String, String>{
      'place_id': placeId,
      'key': _googleApiKey!,
      'language': _language.code,
      'fields':
          'place_id,name,formatted_address,geometry,address_components',
    };

    if (_sessionToken != null) {
      params['sessiontoken'] = _sessionToken!;
    }

    final uri = Uri.parse(_googleDetailsUrl).replace(queryParameters: params);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      return null;
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'OK') {
      return null;
    }

    final result = body['result'] as Map<String, dynamic>?;
    if (result == null) {
      return null;
    }

    return _placeDetailsFromGoogleResult(result);
  }

  Future<PlaceDetails?> _geocodeGoogle(String address) async {
    final uri = Uri.parse(_googleGeocodeUrl).replace(queryParameters: {
      'address': address,
      'key': _googleApiKey!,
      'language': _language.code,
      'components': 'country:CA',
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      return null;
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'OK') {
      return null;
    }

    final results = body['results'] as List<dynamic>? ?? const [];
    if (results.isEmpty) {
      return null;
    }

    final first = results.first as Map<String, dynamic>;
    return _placeDetailsFromGoogleResult(first, fallbackPlaceId: address);
  }

  Future<PlaceDetails?> _reverseGeocodeGoogle(
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.parse(_googleGeocodeUrl).replace(queryParameters: {
      'latlng': '$latitude,$longitude',
      'key': _googleApiKey!,
      'language': _language.code,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      return null;
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'OK') {
      return null;
    }

    final results = body['results'] as List<dynamic>? ?? const [];
    if (results.isEmpty) {
      return null;
    }

    final first = results.first as Map<String, dynamic>;
    return _placeDetailsFromGoogleResult(
      first,
      fallbackPlaceId: '$latitude,$longitude',
    );
  }

  PlaceDetails? _placeDetailsFromGoogleResult(
    Map<String, dynamic> result, {
    String? fallbackPlaceId,
  }) {
    final geometry = result['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final lat = (location?['lat'] as num?)?.toDouble();
    final lng = (location?['lng'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      return null;
    }

    final components =
        (result['address_components'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();

    String city = '';
    String? state;
    String? country;
    String? postalCode;
    String houseNumber = '';
    String route = '';

    for (final component in components) {
      final types = (component['types'] as List<dynamic>? ?? const [])
          .map((t) => t.toString())
          .toList();

      final longName = component['long_name'] as String? ?? '';

      if (types.contains('locality')) {
        city = longName;
      } else if (types.contains('administrative_area_level_1')) {
        state = longName;
      } else if (types.contains('country')) {
        country = longName;
      } else if (types.contains('postal_code')) {
        postalCode = longName;
      } else if (types.contains('street_number')) {
        houseNumber = longName;
      } else if (types.contains('route')) {
        route = longName;
      }
    }

    final street = [houseNumber, route]
        .where((part) => part.trim().isNotEmpty)
        .join(' ');

    return PlaceDetails(
      placeId: result['place_id'] as String? ?? fallbackPlaceId ?? '',
      coordinates: PlaceCoordinates(latitude: lat, longitude: lng),
      formattedAddress:
          result['formatted_address'] as String? ?? 'Unknown location',
      name: result['name'] as String?,
      city: city.isEmpty ? null : city,
      state: state,
      country: country,
      postalCode: postalCode,
      street: street.isEmpty ? null : street,
      source: PlaceSuggestionSource.google,
    );
  }
}
