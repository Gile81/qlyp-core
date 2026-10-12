import 'package:cloud_functions/cloud_functions.dart';

import '../constants/cancellation_contract.dart';
import '../models/cancellation_view.dart';
import 'qlyp_firebase_functions.dart';

class RideCancellationException implements Exception {
  RideCancellationException({
    required this.code,
    required this.messageFr,
    required this.messageEn,
  });

  final String code;
  final String messageFr;
  final String messageEn;

  String localizedMessage(String languageCode) {
    final lang = languageCode.toLowerCase();
    if (lang.startsWith('fr')) {
      return messageFr.isNotEmpty ? messageFr : messageEn;
    }
    return messageEn.isNotEmpty ? messageEn : messageFr;
  }

  @override
  String toString() => 'RideCancellationException($code)';
}

class RideCancellationService {
  RideCancellationService({FirebaseFunctions? functions})
      : _functions = functions ?? getQlypFunctions();

  final FirebaseFunctions _functions;

  Future<CancelRideResultView> previewCancelRide(String orderId) async {
    return _invoke(
      CancellationContract.callablePreviewCancelRide,
      {'orderId': orderId},
    );
  }

  Future<CancelRideResultView> cancelRide({
    required String orderId,
    String? reason,
  }) async {
    return _invoke(
      CancellationContract.callableCancelRide,
      {
        'orderId': orderId,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<CancelRideResultView> markPassengerNoShow(String orderId) async {
    return _invoke(
      CancellationContract.callableMarkPassengerNoShow,
      {'orderId': orderId},
    );
  }

  Future<CancelRideResultView> _invoke(
    String name,
    Map<String, dynamic> payload,
  ) async {
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call<Map<String, dynamic>>(payload);
      final data = result.data;
      if (data is! Map) {
        throw RideCancellationException(
          code: 'invalid_response',
          messageFr: 'Réponse serveur invalide.',
          messageEn: 'Invalid server response.',
        );
      }
      return CancelRideResultView.fromCallableMap(
        Map<String, dynamic>.from(data),
      );
    } on FirebaseFunctionsException catch (e) {
      throw parseFunctionsException(e);
    }
  }

  static RideCancellationException parseFunctionsException(
    FirebaseFunctionsException e,
  ) {
    final details = e.details;
    if (details is Map) {
      final map = Map<String, dynamic>.from(details);
      final code = map['code']?.toString() ?? e.message ?? e.code;
      final messageFr = map['message_fr']?.toString() ?? '';
      final messageEn = map['message_en']?.toString() ?? e.message ?? '';
      return RideCancellationException(
        code: code,
        messageFr: messageFr,
        messageEn: messageEn,
      );
    }
    final fallbackCode = e.message?.trim().isNotEmpty == true
        ? e.message!.trim()
        : e.code;
    return RideCancellationException(
      code: fallbackCode,
      messageFr: '',
      messageEn: e.message ?? e.code,
    );
  }

  static String localizedErrorMessage({
    required RideCancellationException error,
    required String languageCode,
    required String Function(String key) fallbackForCode,
  }) {
    final localized = error.localizedMessage(languageCode);
    if (localized.isNotEmpty) return localized;
    return fallbackForCode(error.code);
  }
}
