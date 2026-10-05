import 'package:qlyp_core/constants/ride_tracking_contract.dart';

enum RidePhase {
  driverEnRoute,
  driverArrived,
  inProgress,
  completed,
  canceled,
}

extension RidePhaseWire on RidePhase {
  String get wireValue {
    switch (this) {
      case RidePhase.driverEnRoute:
        return RideTrackingContract.phaseDriverEnRoute;
      case RidePhase.driverArrived:
        return RideTrackingContract.phaseDriverArrived;
      case RidePhase.inProgress:
        return RideTrackingContract.phaseInProgress;
      case RidePhase.completed:
        return RideTrackingContract.phaseCompleted;
      case RidePhase.canceled:
        return RideTrackingContract.phaseCanceled;
    }
  }
}

RidePhase? ridePhaseFromWire(Object? raw) {
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty) return null;
  switch (value) {
    case RideTrackingContract.phaseDriverEnRoute:
      return RidePhase.driverEnRoute;
    case RideTrackingContract.phaseDriverArrived:
      return RidePhase.driverArrived;
    case RideTrackingContract.phaseInProgress:
      return RidePhase.inProgress;
    case RideTrackingContract.phaseCompleted:
      return RidePhase.completed;
    case RideTrackingContract.phaseCanceled:
      return RidePhase.canceled;
    default:
      return null;
  }
}
