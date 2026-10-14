import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/billing_contract.dart';
import 'qlyp_firebase_functions.dart';

class BillingDocumentException implements Exception {
  BillingDocumentException({
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
  String toString() => 'BillingDocumentException($code)';
}

class BillingDocumentUrlResult {
  const BillingDocumentUrlResult({required this.url, this.expiresAt});

  final String url;
  final String? expiresAt;
}

class BillingDocumentService {
  BillingDocumentService({FirebaseFunctions? functions})
      : _functions = functions ?? getQlypFunctions();

  final FirebaseFunctions _functions;

  Future<BillingDocumentUrlResult> fetchSignedUrl({
    required String documentType,
    required String documentId,
  }) async {
    try {
      final callable =
          _functions.httpsCallable(BillingContract.callableGetBillingDocumentUrl);
      final result = await callable.call<Map<String, dynamic>>({
        BillingContract.inputDocumentType: documentType,
        BillingContract.inputDocumentId: documentId,
      });
      final data = Map<String, dynamic>.from(result.data);
      final url = data[BillingContract.outputUrl]?.toString() ?? '';
      if (url.isEmpty) {
        throw BillingDocumentException(
          code: BillingContract.errorInvalidRequest,
          messageFr: 'Réponse invalide du serveur.',
          messageEn: 'Invalid server response.',
        );
      }
      return BillingDocumentUrlResult(
        url: url,
        expiresAt: data[BillingContract.outputExpiresAt]?.toString(),
      );
    } on FirebaseFunctionsException catch (e) {
      throw parseBillingFunctionsException(e);
    }
  }

  Future<void> openPdf({
    required String documentType,
    required String documentId,
  }) async {
    final signed = await fetchSignedUrl(
      documentType: documentType,
      documentId: documentId,
    );
    final uri = Uri.parse(signed.url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw BillingDocumentException(
        code: 'launch_failed',
        messageFr: 'Impossible d’ouvrir le PDF.',
        messageEn: 'Could not open the PDF.',
      );
    }
  }

  static BillingDocumentException parseBillingFunctionsException(
    FirebaseFunctionsException e,
  ) {
    final code = _mapFunctionsCode(e);
    switch (code) {
      case BillingContract.errorPdfNotReady:
        return BillingDocumentException(
          code: code,
          messageFr:
              'Le PDF est en préparation, réessayez dans un instant.',
          messageEn: 'The PDF is being prepared. Try again in a moment.',
        );
      case BillingContract.errorPermissionDenied:
        return BillingDocumentException(
          code: code,
          messageFr: 'Vous n’avez pas accès à ce document.',
          messageEn: 'You do not have access to this document.',
        );
      case BillingContract.errorNotFound:
        return BillingDocumentException(
          code: code,
          messageFr: 'Document introuvable.',
          messageEn: 'Document not found.',
        );
      case BillingContract.errorInvalidRequest:
        return BillingDocumentException(
          code: code,
          messageFr: 'Demande invalide.',
          messageEn: 'Invalid request.',
        );
      default:
        return BillingDocumentException(
          code: code,
          messageFr: 'Impossible d’obtenir le PDF pour le moment.',
          messageEn: 'Could not fetch the PDF right now.',
        );
    }
  }

  static String _mapFunctionsCode(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'failed-precondition':
        return BillingContract.errorPdfNotReady;
      case 'permission-denied':
        return BillingContract.errorPermissionDenied;
      case 'not-found':
        return BillingContract.errorNotFound;
      case 'invalid-argument':
        return BillingContract.errorInvalidRequest;
      default:
        final details = e.details?.toString() ?? '';
        if (details.contains(BillingContract.errorPdfNotReady)) {
          return BillingContract.errorPdfNotReady;
        }
        return e.code;
    }
  }
}
