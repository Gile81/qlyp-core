import 'package:cloud_functions/cloud_functions.dart';

/// Cloud Functions region for qlyp-ca (Montreal).
const String kQlypFunctionsRegion = 'northamerica-northeast1';

/// Callable HTTPS functions deployed in [kQlypFunctionsRegion].
FirebaseFunctions getQlypFunctions() {
  return FirebaseFunctions.instanceFor(region: kQlypFunctionsRegion);
}
