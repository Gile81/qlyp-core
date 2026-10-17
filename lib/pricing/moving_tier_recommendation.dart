// Zone ZRS settings for client-side moving tier recommendation (lot B2).
// Does not affect pricing or dispatch.

class MovingTierCrewServiceMap {
  const MovingTierCrewServiceMap({
    required this.crew1,
    required this.crew2,
    required this.crew2HeavyOrHighFloor,
    required this.crew3Plus,
  });

  final String crew1;
  final String crew2;
  final String crew2HeavyOrHighFloor;
  final String crew3Plus;

  MovingTierCrewServiceMap copyWith({
    String? crew1,
    String? crew2,
    String? crew2HeavyOrHighFloor,
    String? crew3Plus,
  }) {
    return MovingTierCrewServiceMap(
      crew1: crew1 ?? this.crew1,
      crew2: crew2 ?? this.crew2,
      crew2HeavyOrHighFloor:
          crew2HeavyOrHighFloor ?? this.crew2HeavyOrHighFloor,
      crew3Plus: crew3Plus ?? this.crew3Plus,
    );
  }
}

class MovingTierRecommendationConfig {
  const MovingTierRecommendationConfig({
    required this.noElevatorFloorThreshold,
    required this.crewToServiceId,
  });

  final int noElevatorFloorThreshold;
  final MovingTierCrewServiceMap crewToServiceId;
}

/// Inputs from the demenagement booking wizard (existing fields only).
class MovingWizardRecommendationInputs {
  const MovingWizardRecommendationInputs({
    required this.moversCount,
    required this.floorDeparture,
    required this.floorArrival,
    required this.elevatorDeparture,
    required this.elevatorArrival,
    required this.heavyItems,
  });

  final int moversCount;
  final String floorDeparture;
  final String floorArrival;
  final bool elevatorDeparture;
  final bool elevatorArrival;
  final bool heavyItems;
}

int movingFloorLevel(String floor) {
  switch (floor.trim().toLowerCase()) {
    case 'ground':
      return 0;
    case '1':
      return 1;
    case '2':
      return 2;
    case '3':
      return 3;
    case '4plus':
      return 4;
    default:
      return 0;
  }
}

bool movingHasHighFloorWithoutElevator({
  required int threshold,
  required String floorDeparture,
  required String floorArrival,
  required bool elevatorDeparture,
  required bool elevatorArrival,
}) {
  final dep = movingFloorLevel(floorDeparture);
  if (dep >= threshold && !elevatorDeparture) return true;
  final arr = movingFloorLevel(floorArrival);
  if (arr >= threshold && !elevatorArrival) return true;
  return false;
}

/// Returns a service document id to highlight, or null when nothing applies.
String? resolveMovingTierRecommendedServiceId({
  required MovingTierRecommendationConfig config,
  required MovingWizardRecommendationInputs inputs,
}) {
  final map = config.crewToServiceId;
  final count = inputs.moversCount;
  if (count >= 3) {
    return _nonEmpty(map.crew3Plus);
  }
  if (count == 1) {
    return _nonEmpty(map.crew1);
  }
  if (count == 2) {
    final heavyOrHigh = inputs.heavyItems ||
        movingHasHighFloorWithoutElevator(
          threshold: config.noElevatorFloorThreshold,
          floorDeparture: inputs.floorDeparture,
          floorArrival: inputs.floorArrival,
          elevatorDeparture: inputs.elevatorDeparture,
          elevatorArrival: inputs.elevatorArrival,
        );
    if (heavyOrHigh) {
      return _nonEmpty(map.crew2HeavyOrHighFloor);
    }
    return _nonEmpty(map.crew2);
  }
  return null;
}

String? _nonEmpty(String value) {
  final v = value.trim();
  return v.isEmpty ? null : v;
}

int _asInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is double && value.isFinite) return value.toInt();
  if (value is String && value.trim().isNotEmpty) {
    final p = int.tryParse(value.trim());
    if (p != null) return p;
  }
  return fallback;
}

MovingTierCrewServiceMap _readCrewMap(Object? raw) {
  const empty = MovingTierCrewServiceMap(
    crew1: '',
    crew2: '',
    crew2HeavyOrHighFloor: '',
    crew3Plus: '',
  );
  if (raw is! Map) return empty;
  final m = Map<String, dynamic>.from(raw);
  String pick(String snake, String camel) {
    final v = m[snake] ?? m[camel];
    return v is String ? v.trim() : '';
  }

  return MovingTierCrewServiceMap(
    crew1: pick('crew_1', 'crew1'),
    crew2: pick('crew_2', 'crew2'),
    crew2HeavyOrHighFloor:
        pick('crew_2_heavy_or_high_floor', 'crew2HeavyOrHighFloor'),
    crew3Plus: pick('crew_3_plus', 'crew3Plus'),
  );
}

/// Reads top-level `moving_tier_recommendation` on a zone document.
MovingTierRecommendationConfig parseMovingTierRecommendationFromZone(
  Map<String, dynamic>? zoneDoc,
) {
  const defaultThreshold = 3;
  if (zoneDoc == null) {
    return const MovingTierRecommendationConfig(
      noElevatorFloorThreshold: defaultThreshold,
      crewToServiceId: MovingTierCrewServiceMap(
        crew1: '',
        crew2: '',
        crew2HeavyOrHighFloor: '',
        crew3Plus: '',
      ),
    );
  }
  final raw = zoneDoc['moving_tier_recommendation'] ??
      zoneDoc['movingTierRecommendation'];
  if (raw is! Map) {
    return const MovingTierRecommendationConfig(
      noElevatorFloorThreshold: defaultThreshold,
      crewToServiceId: MovingTierCrewServiceMap(
        crew1: '',
        crew2: '',
        crew2HeavyOrHighFloor: '',
        crew3Plus: '',
      ),
    );
  }
  final obj = Map<String, dynamic>.from(raw);
  return MovingTierRecommendationConfig(
    noElevatorFloorThreshold: _asInt(
      obj['no_elevator_floor_threshold'] ?? obj['noElevatorFloorThreshold'],
      defaultThreshold,
    ),
    crewToServiceId: _readCrewMap(
      obj['crew_to_service_id'] ?? obj['crewToServiceId'],
    ),
  );
}
