/// Firestore / callable wire names for ride cancellation (S7-C2 contract).
///
/// Mirror of `functions/src/contracts/cancellation_contract.json`.
/// SHA-256: 8078CE502B38046A44B7A000BF44A1A5FD0B6CC174485E8D899518C534794123
abstract final class CancellationContract {
  static const int contractVersion = 1;

  static const String contractSha256 =
      '8078CE502B38046A44B7A000BF44A1A5FD0B6CC174485E8D899518C534794123';

  static const String callablePreviewCancelRide = 'previewCancelRide';
  static const String callableCancelRide = 'cancelRide';
  static const String callableMarkPassengerNoShow = 'markPassengerNoShow';

  static const String fieldCancellation = 'cancellation';
  static const String fieldCancellationChargeStatus =
      'cancellation_charge_status';
  static const String fieldDriverAssignedAt = 'driver_assigned_at';
  static const String fieldDriverCancellations = 'driver_cancellations';
  static const String fieldNoShowAvailableAt = 'noShowAvailableAt';
  static const String fieldDriverArrivedAt = 'driverArrivedAt';
  static const String fieldDispatchExcludedDriverIds =
      'dispatch_excluded_driver_ids';
  static const String fieldRedispatchRequestedAt = 'redispatch_requested_at';

  static const String cancelBy = 'by';
  static const String cancelReasonCode = 'reason_code';
  static const String cancelReasonText = 'reason_text';
  static const String cancelAt = 'at';
  static const String cancelFeeHt = 'fee_ht';
  static const String cancelFeeTaxes = 'fee_taxes';
  static const String cancelFeeTtc = 'fee_ttc';
  static const String cancelDriverShare = 'driver_share';
  static const String cancelPlatformShare = 'platform_share';
  static const String cancelAdminCompensation = 'admin_compensation';
  static const String cancelParamsVersion = 'params_version';

  static const String taxKey = 'key';
  static const String taxLabelFr = 'label_fr';
  static const String taxLabelEn = 'label_en';
  static const String taxRate = 'rate';
  static const String taxAmount = 'amount';

  static const String byPassenger = 'passenger';
  static const String byDriver = 'driver';
  static const String byAdmin = 'admin';
  static const String bySystem = 'system';

  static const String reasonFreeWindow = 'free_window';
  static const String reasonAfterAccept = 'after_accept';
  static const String reasonAfterArrival = 'after_arrival';
  static const String reasonNoShow = 'no_show';
  static const String reasonScheduledFree = 'scheduled_free';
  static const String reasonScheduledMid = 'scheduled_mid';
  static const String reasonScheduledLate = 'scheduled_late';
  static const String reasonDriver = 'driver';
  static const String reasonAdmin = 'admin';
  static const String reasonSystem = 'system';

  static const String chargeStatusNone = 'none';
  static const String chargeStatusPending = 'pending';
  static const String chargeStatusCharged = 'charged';
  static const String chargeStatusFailed = 'failed';

  static const String errorCannotCancelNow = 'cannot_cancel_now';
  static const String errorNoShowTooEarly = 'no_show_too_early';
  static const String errorNotAssignedDriver = 'not_assigned_driver';
  static const String errorForbidden = 'forbidden';
  static const String errorOrderNotFound = 'order_not_found';
  static const String errorReasonRequired = 'reason_required';

  static const List<String> callableNames = [
    callablePreviewCancelRide,
    callableCancelRide,
    callableMarkPassengerNoShow,
  ];

  static const List<String> errorCodes = [
    errorCannotCancelNow,
    errorNoShowTooEarly,
    errorNotAssignedDriver,
    errorForbidden,
    errorOrderNotFound,
    errorReasonRequired,
  ];
}
