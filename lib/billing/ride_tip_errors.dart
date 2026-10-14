import '../constants/billing_contract.dart';

/// Fallback copy when callable details omit message_fr / message_en.
String rideTipErrorFallback(String code, String languageCode) {
  final lang = languageCode.toLowerCase();
  final fr = lang.startsWith('fr');
  switch (code) {
    case BillingContract.errorTipNotAllowedCash:
      return fr
          ? 'Le pourboire dans l’app n’est pas disponible pour une course payée comptant.'
          : 'In-app tips are not available for cash-paid rides.';
    case BillingContract.errorTipOrderNotCompleted:
      return fr
          ? 'La course n’est pas terminée ou la facturation n’est pas prête.'
          : 'The ride is not completed or billing is not ready.';
    case BillingContract.errorTipOrderNotPaid:
      return fr
          ? 'Le pourboire est disponible après le paiement de la course.'
          : 'Tips are available after the ride has been paid.';
    case BillingContract.errorTipWindowExpired:
      return fr
          ? 'Le délai pour laisser un pourboire est expiré.'
          : 'The tip window has expired.';
    case BillingContract.errorTipAlreadySet:
      return fr
          ? 'Un pourboire a déjà été enregistré pour cette course.'
          : 'A tip has already been set for this ride.';
    case BillingContract.errorTipInvalidAmount:
      return fr ? 'Montant de pourboire invalide.' : 'Invalid tip amount.';
    case BillingContract.errorTipPromptInvalidTransition:
      return fr
          ? 'Transition de rappel pourboire invalide.'
          : 'Invalid tip reminder transition.';
    case BillingContract.errorOrderNotFound:
      return fr ? 'Course introuvable.' : 'Order not found.';
    case BillingContract.errorPermissionDenied:
      return fr ? 'Action non autorisée.' : 'Not allowed.';
    default:
      return code;
  }
}
