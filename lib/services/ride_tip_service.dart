import 'package:cloud_functions/cloud_functions.dart';

import '../billing/ride_tip_errors.dart';
import '../constants/billing_contract.dart';
import 'qlyp_firebase_functions.dart';

class RideTipException implements Exception {
  RideTipException({
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
  String toString() => 'RideTipException($code)';
}

class SetRideTipResult {
  const SetRideTipResult({required this.tipAmount});

  final double tipAmount;

  factory SetRideTipResult.fromMap(Map<String, dynamic> map) {
    final amount = map[BillingContract.outputTipAmount];
    if (amount is! num) {
      throw FormatException('missing tip_amount', map);
    }
    return SetRideTipResult(tipAmount: amount.toDouble());
  }
}

class SetTipPromptStateResult {
  const SetTipPromptStateResult({required this.tipPromptState});

  final String tipPromptState;

  factory SetTipPromptStateResult.fromMap(Map<String, dynamic> map) {
    final state = map[BillingContract.outputTipPromptState]?.toString() ?? '';
    if (state.isEmpty) {
      throw FormatException('missing tip_prompt_state', map);
    }
    return SetTipPromptStateResult(tipPromptState: state);
  }
}

class RideTipService {
  RideTipService({FirebaseFunctions? functions})
      : _functions = functions ?? getQlypFunctions();

  final FirebaseFunctions _functions;

  Future<SetRideTipResult> setTip({
    required String orderId,
    required double amount,
  }) =>
      setRideTip(orderId: orderId, amount: amount);

  Future<SetRideTipResult> setRideTip({
    required String orderId,
    required double amount,
  }) async {
    return _invokeSetRideTip({
      BillingContract.inputOrderId: orderId,
      BillingContract.inputTipAmount: amount,
    });
  }

  Future<SetTipPromptStateResult> setPromptState({
    required String orderId,
    required String state,
  }) =>
      setTipPromptState(orderId: orderId, state: state);

  Future<SetTipPromptStateResult> setTipPromptState({
    required String orderId,
    required String state,
  }) async {
    return _invokeSetTipPromptState({
      BillingContract.inputOrderId: orderId,
      BillingContract.inputTipPromptState: state,
    });
  }

  Future<SetRideTipResult> _invokeSetRideTip(
    Map<String, dynamic> payload,
  ) async {
    try {
      final callable = _functions.httpsCallable(BillingContract.callableSetRideTip);
      final result = await callable.call<Map<String, dynamic>>(payload);
      return SetRideTipResult.fromMap(Map<String, dynamic>.from(result.data));
    } on FirebaseFunctionsException catch (e) {
      throw parseRideTipException(e);
    }
  }

  Future<SetTipPromptStateResult> _invokeSetTipPromptState(
    Map<String, dynamic> payload,
  ) async {
    try {
      final callable =
          _functions.httpsCallable(BillingContract.callableSetTipPromptState);
      final result = await callable.call<Map<String, dynamic>>(payload);
      return SetTipPromptStateResult.fromMap(
        Map<String, dynamic>.from(result.data),
      );
    } on FirebaseFunctionsException catch (e) {
      throw parseRideTipException(e);
    }
  }

  static RideTipException parseRideTipException(FirebaseFunctionsException e) {
    final details = e.details;
    if (details is Map) {
      final map = Map<String, dynamic>.from(details);
      final code = map['code']?.toString() ?? e.message ?? e.code;
      final messageFr = map['message_fr']?.toString() ?? '';
      final messageEn = map['message_en']?.toString() ?? e.message ?? '';
      return RideTipException(
        code: code,
        messageFr: messageFr,
        messageEn: messageEn,
      );
    }
    final fallbackCode = e.message?.trim().isNotEmpty == true
        ? e.message!.trim()
        : e.code;
    return RideTipException(
      code: fallbackCode,
      messageFr: '',
      messageEn: e.message ?? e.code,
    );
  }

  static String localizedErrorMessage({
    required RideTipException error,
    required String languageCode,
  }) {
    final localized = error.localizedMessage(languageCode);
    if (localized.isNotEmpty) return localized;
    return rideTipErrorFallback(error.code, languageCode);
  }
}
