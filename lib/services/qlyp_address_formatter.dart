import 'places_service.dart';

/// Two-line address label for lists, search suggestions, and confirmation UI,
/// formatted the way Uber/Lyft show a resolved address:
///   primary   = civic number + street (+ unit, when known)
///   secondary = City, Province/State PostalCode
class QlypAddressDisplay {
  const QlypAddressDisplay({
    required this.primary,
    this.secondary,
  });

  /// Street line (civic number + street name, plus unit if present) or POI name.
  final String primary;

  /// "City, Province PostalCode" (province/postal code omitted if unknown;
  /// country appended only when the address is outside Canada).
  final String? secondary;

  bool get hasSecondary =>
      secondary != null && secondary!.trim().isNotEmpty;

  /// Single compact line for text fields (`primary, secondary` or primary alone).
  String get compactLine {
    if (hasSecondary) {
      return '${primary.trim()}, ${secondary!.trim()}';
    }
    return primary.trim();
  }
}

/// Builds short, Uber/Lyft-style Canadian address labels from API payloads or
/// stored fields: civic number + street (+ unit) on the primary line, and
/// city + province + postal code on the secondary line.
class QlypAddressFormatter {
  QlypAddressFormatter._();

  static const Map<String, String> _canadaProvinceCodes = {
    'alberta': 'AB',
    'british columbia': 'BC',
    'manitoba': 'MB',
    'new brunswick': 'NB',
    'newfoundland and labrador': 'NL',
    'northwest territories': 'NT',
    'nova scotia': 'NS',
    'nunavut': 'NU',
    'ontario': 'ON',
    'prince edward island': 'PE',
    'quebec': 'QC',
    'québec': 'QC',
    'saskatchewan': 'SK',
    'yukon': 'YT',
  };

  /// Autocomplete row, before the place is resolved to full details. Google's
  /// `secondary_text` is usually "City, Province, Country" — keep "City,
  /// Province" (no postal code yet, it isn't available at this stage).
  static QlypAddressDisplay fromPlaceSuggestion(PlaceSuggestion suggestion) {
    final main = suggestion.mainText?.trim();
    final secondary = suggestion.secondaryText?.trim();

    // Reject bare civic numbers (e.g. "982", "12B") as primary — Google's
    // structured_formatting.main_text can be just the house number when the
    // query is a partial address.  Fall through to fromFormattedAddress() in
    // that case so the full description string is parsed instead.
    final mainTrimmed = main?.trim() ?? '';
    final isUsableMain = mainTrimmed.length > 2 &&
        !RegExp(r'^\d+[a-zA-Z]?$').hasMatch(mainTrimmed);

    if (main != null && main.isNotEmpty && isUsableMain) {
      return QlypAddressDisplay(
        primary: main,
        secondary: _cityProvinceFromSecondary(secondary),
      );
    }

    return fromFormattedAddress(suggestion.description);
  }

  /// Fully resolved place (Place Details / Geocode) — has structured
  /// components, so this produces the complete "civic + street, City, PROV
  /// postal" label.
  static QlypAddressDisplay fromPlaceDetails(PlaceDetails details) {
    return fromParts(
      name: details.name,
      street: details.street,
      unit: details.unit,
      city: details.city,
      state: details.stateCode ?? details.state,
      postalCode: details.postalCode,
      formattedAddress: details.formattedAddress,
      country: details.country,
    );
  }

  static QlypAddressDisplay fromParts({
    String? name,
    String? street,
    String? unit,
    String? city,
    String? state,
    String? postalCode,
    String? formattedAddress,
    String? country,
  }) {
    final poi = name?.trim();
    final streetLine = street?.trim();
    final unitLine = unit?.trim();

    String primary;
    if (streetLine != null && streetLine.isNotEmpty) {
      primary = (unitLine != null && unitLine.isNotEmpty)
          ? '$streetLine, Unit $unitLine'
          : streetLine;
    } else if (poi != null && poi.isNotEmpty) {
      primary = poi;
    } else if (formattedAddress != null && formattedAddress.trim().isNotEmpty) {
      return fromFormattedAddress(
        formattedAddress,
        fallbackCity: city,
        fallbackState: state,
        fallbackPostalCode: postalCode,
      );
    } else {
      primary = 'Unknown location';
    }

    return QlypAddressDisplay(
      primary: primary,
      secondary: _buildSecondary(
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
      ),
    );
  }

  /// Last-resort fallback when no structured address components are
  /// available at all (only a single formatted-address string).
  static QlypAddressDisplay fromFormattedAddress(
    String formattedAddress, {
    String? fallbackCity,
    String? fallbackState,
    String? fallbackPostalCode,
  }) {
    final parts = formattedAddress
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return QlypAddressDisplay(primary: formattedAddress.trim());
    }

    if (parts.length == 1) {
      return QlypAddressDisplay(primary: parts.first);
    }

    final primary = parts.first;

    final hasFallback = _clean(fallbackCity) != null ||
        _clean(fallbackState) != null ||
        _clean(fallbackPostalCode) != null;

    if (hasFallback) {
      return QlypAddressDisplay(
        primary: primary,
        secondary: _buildSecondary(
          city: fallbackCity,
          state: fallbackState,
          postalCode: fallbackPostalCode,
          country: null,
        ),
      );
    }

    return QlypAddressDisplay(
      primary: primary,
      secondary: _guessCityFromParts(parts),
    );
  }

  /// Builds "City, PROV postal" from whatever parts are known, normalizing a
  /// full Canadian province name (Google long_name, or Nominatim's `state`)
  /// down to its two-letter code. Country is appended only outside Canada.
  static String? _buildSecondary({
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    final cityLine = _clean(city);
    final stateLine = _clean(state) != null ? _normalizeState(state!) : null;
    final postalLine = _clean(postalCode);

    String? cityState;
    if (cityLine != null && stateLine != null) {
      cityState = '$cityLine, $stateLine';
    } else {
      cityState = cityLine ?? stateLine;
    }

    String? line;
    if (cityState != null && postalLine != null) {
      line = '$cityState $postalLine';
    } else {
      line = cityState ?? postalLine;
    }

    if (line == null) {
      return null;
    }

    if (country != null && _clean(country) != null && !_isCanada(country)) {
      return '$line, ${country.trim()}';
    }
    return line;
  }

  /// "City, Province, Country" (Google suggestion secondary_text) → "City, Province".
  static String? _cityProvinceFromSecondary(String? secondary) {
    if (secondary == null || secondary.trim().isEmpty) {
      return null;
    }
    final parts = secondary
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return null;
    }
    if (parts.length == 1) {
      return parts.first;
    }

    final kept = parts.where((part) => !_looksLikeCountryName(part)).toList();
    if (kept.length >= 2) {
      return '${kept[0]}, ${_normalizeState(kept[1])}';
    }
    return kept.isNotEmpty ? kept.first : parts.first;
  }

  static String? _guessCityFromParts(List<String> parts) {
    if (parts.length < 2) {
      return null;
    }

    for (var i = 1; i < parts.length; i++) {
      final candidate = parts[i];
      if (_looksLikePostalOrCountry(candidate)) {
        continue;
      }
      return candidate;
    }

    return parts.length >= 2 ? parts[1] : null;
  }

  static String? _clean(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Google already gives 2-letter codes (short_name) most of the time; this
  /// only kicks in for longer strings (a full province name from Nominatim,
  /// or Google's long_name when short_name wasn't captured).
  static String _normalizeState(String state) {
    final trimmed = state.trim();
    if (trimmed.length <= 3) {
      return trimmed.toUpperCase();
    }
    final code = _canadaProvinceCodes[trimmed.toLowerCase()];
    return code ?? trimmed;
  }

  static bool _looksLikeCountryName(String value) {
    final v = value.trim().toLowerCase();
    return v == 'canada' || v == 'ca';
  }

  static bool _looksLikePostalOrCountry(String value) {
    final v = value.trim().toLowerCase();
    if (v == 'canada' || v == 'ca') {
      return true;
    }
    if (RegExp(r'^[A-Z]\d[A-Z]\s?\d[A-Z]\d$', caseSensitive: false)
        .hasMatch(value.trim())) {
      return true;
    }
    if (RegExp(r'^\d{5}(-\d{4})?$').hasMatch(value.trim())) {
      return true;
    }
    return false;
  }

  static bool _isCanada(String country) {
    final c = country.trim().toLowerCase();
    return c == 'ca' || c == 'canada';
  }
}
