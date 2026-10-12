import 'package:flutter_test/flutter_test.dart';

import 'package:qlyp_core/constants/cancellation_contract.dart';
import 'package:qlyp_core/models/cancellation_view.dart';

void main() {
  test('CancellationRecordView parses free cancellation', () {
    final view = CancellationRecordView.fromMap({
      CancellationContract.cancelBy: CancellationContract.byPassenger,
      CancellationContract.cancelReasonCode:
          CancellationContract.reasonFreeWindow,
      CancellationContract.cancelFeeHt: 0,
      CancellationContract.cancelFeeTtc: 0,
      CancellationContract.cancelFeeTaxes: [],
    });
    expect(view, isNotNull);
    expect(view.hasFee, isFalse);
  });

  test('CancellationRecordView parses taxes', () {
    final view = CancellationRecordView.fromMap({
      CancellationContract.cancelFeeHt: 10,
      CancellationContract.cancelFeeTtc: 11.5,
      CancellationContract.cancelFeeTaxes: [
        {
          CancellationContract.taxKey: 'gst',
          CancellationContract.taxLabelFr: 'TPS',
          CancellationContract.taxLabelEn: 'GST',
          CancellationContract.taxRate: 0.05,
          CancellationContract.taxAmount: 0.5,
        },
      ],
    });
    expect(view.feeTaxes.length, 1);
    expect(view.feeTtc, 11.5);
  });

  test('CancelRideResultView accepts serialized at map', () {
    final result = CancelRideResultView.fromCallableMap({
      'orderId': 'o1',
      'status': 'Ride Canceled',
      CancellationContract.fieldCancellation: {
        CancellationContract.cancelAt: {'_seconds': 1700000000},
        CancellationContract.cancelFeeTtc: 0,
        CancellationContract.cancelFeeHt: 0,
        CancellationContract.cancelFeeTaxes: [],
      },
      CancellationContract.fieldCancellationChargeStatus:
          CancellationContract.chargeStatusNone,
    });
    expect(result.cancellation?.at, isNotNull);
  });
}
