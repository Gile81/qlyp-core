import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/cancellation_contract.dart';

class CancellationTaxLineView {
  const CancellationTaxLineView({
    required this.key,
    required this.labelFr,
    required this.labelEn,
    required this.rate,
    required this.amount,
  });

  final String key;
  final String labelFr;
  final String labelEn;
  final double rate;
  final double amount;

  factory CancellationTaxLineView.fromMap(Map<String, dynamic> raw) {
    return CancellationTaxLineView(
      key: raw[CancellationContract.taxKey]?.toString() ?? '',
      labelFr: raw[CancellationContract.taxLabelFr]?.toString() ?? '',
      labelEn: raw[CancellationContract.taxLabelEn]?.toString() ?? '',
      rate: _asDouble(raw[CancellationContract.taxRate]) ?? 0,
      amount: _asDouble(raw[CancellationContract.taxAmount]) ?? 0,
    );
  }

  String labelForLanguage(String languageCode) {
    final lang = languageCode.toLowerCase();
    if (lang.startsWith('fr')) {
      return labelFr.isNotEmpty ? labelFr : labelEn;
    }
    return labelEn.isNotEmpty ? labelEn : labelFr;
  }
}

class CancellationRecordView {
  const CancellationRecordView({
    this.by,
    this.reasonCode,
    this.reasonText,
    this.at,
    this.feeHt,
    this.feeTaxes = const [],
    this.feeTtc,
    this.driverShare,
    this.platformShare,
    this.adminCompensation,
  });

  final String? by;
  final String? reasonCode;
  final String? reasonText;
  final DateTime? at;
  final double? feeHt;
  final List<CancellationTaxLineView> feeTaxes;
  final double? feeTtc;
  final double? driverShare;
  final double? platformShare;
  final double? adminCompensation;

  bool get isNotNull => by != null || reasonCode != null || feeTtc != null;

  bool get hasFee => (feeTtc ?? 0) > 0;

  factory CancellationRecordView.fromMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const CancellationRecordView();
    }
    final taxesRaw = raw[CancellationContract.cancelFeeTaxes];
    final taxes = <CancellationTaxLineView>[];
    if (taxesRaw is List) {
      for (final item in taxesRaw) {
        if (item is Map) {
          taxes.add(
            CancellationTaxLineView.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return CancellationRecordView(
      by: _optionalString(raw[CancellationContract.cancelBy]),
      reasonCode: _optionalString(raw[CancellationContract.cancelReasonCode]),
      reasonText: _optionalString(raw[CancellationContract.cancelReasonText]),
      at: _parseAt(raw[CancellationContract.cancelAt]),
      feeHt: _asDouble(raw[CancellationContract.cancelFeeHt]),
      feeTaxes: taxes,
      feeTtc: _asDouble(raw[CancellationContract.cancelFeeTtc]),
      driverShare: _asDouble(raw[CancellationContract.cancelDriverShare]),
      platformShare: _asDouble(raw[CancellationContract.cancelPlatformShare]),
      adminCompensation:
          _asDouble(raw[CancellationContract.cancelAdminCompensation]),
    );
  }
}

class CancelRideResultView {
  const CancelRideResultView({
    required this.orderId,
    required this.status,
    this.alreadyCancelled = false,
    this.driverRedispatch = false,
    this.cancellation,
    this.cancellationChargeStatus,
  });

  final String orderId;
  final String status;
  final bool alreadyCancelled;
  final bool driverRedispatch;
  final CancellationRecordView? cancellation;
  final String? cancellationChargeStatus;

  factory CancelRideResultView.fromCallableMap(Map<String, dynamic> raw) {
    final cancellationRaw = raw[CancellationContract.fieldCancellation];
    CancellationRecordView? cancellation;
    if (cancellationRaw is Map) {
      cancellation = CancellationRecordView.fromMap(
        Map<String, dynamic>.from(cancellationRaw),
      );
    }
    return CancelRideResultView(
      orderId: raw['orderId']?.toString() ?? '',
      status: raw['status']?.toString() ?? '',
      alreadyCancelled: raw['alreadyCancelled'] == true,
      driverRedispatch: raw['driverRedispatch'] == true,
      cancellation: cancellation?.isNotNull == true ? cancellation : null,
      cancellationChargeStatus: _optionalString(
        raw[CancellationContract.fieldCancellationChargeStatus],
      ),
    );
  }
}

/// Detects driver voluntary cancel + redispatch from order snapshot deltas.
bool didDriverCancelAndRedispatch({
  required int previousDriverCancellationsCount,
  required int nextDriverCancellationsCount,
  required String? previousDriverId,
  required String? nextDriverId,
}) {
  if (nextDriverCancellationsCount <= previousDriverCancellationsCount) {
    return false;
  }
  final hadDriver = (previousDriverId ?? '').trim().isNotEmpty;
  final driverCleared = (nextDriverId ?? '').trim().isEmpty;
  return hadDriver && driverCleared;
}

int driverCancellationsCount(Map<String, dynamic>? orderData) {
  if (orderData == null) return 0;
  final raw = orderData[CancellationContract.fieldDriverCancellations];
  if (raw is List) return raw.length;
  return 0;
}

String? _optionalString(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

DateTime? _parseAt(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is Map) {
    final seconds = value['_seconds'] ?? value['seconds'];
    if (seconds is num) {
      final nanos = value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        (seconds * 1000).toInt() + (nanos is num ? nanos ~/ 1000000 : 0),
        isUtc: true,
      ).toLocal();
    }
  }
  return null;
}
