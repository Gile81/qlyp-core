// Section titles aligned with server PDF maquettes (S7-D).

// Invoice header title (same rule as billing-pdf-render.ts).
String billingInvoiceDocumentTitle(String languageCode, String type) {
  final fr = languageCode.toLowerCase().startsWith('fr');
  if (type == 'cancellation') {
    return fr ? "Facture d'annulation" : 'Cancellation invoice';
  }
  return fr ? 'Facture' : 'Invoice';
}

String? invoiceSectionTitle(String languageCode, String section) {
  final fr = languageCode.toLowerCase().startsWith('fr');
  switch (section) {
    case 'ride_detail':
      return fr ? 'DÉTAIL DE LA COURSE' : 'RIDE DETAIL';
    case 'fee_detail':
      return fr ? 'DÉTAIL DES FRAIS' : 'FEE DETAIL';
    case 'toll':
      return fr ? 'PÉAGE' : 'TOLL';
    case 'tip':
      return fr ? 'POURBOIRE' : 'TIP';
    default:
      return null;
  }
}

String? statementSectionTitle(
  String languageCode,
  String section, {
  String? lineKey,
}) {
  final fr = languageCode.toLowerCase().startsWith('fr');
  if (section == 'your_ride') {
    return fr ? 'VOTRE COURSE' : 'YOUR RIDE';
  }
  if (section == 'driver_revenue') {
    return fr
        ? 'VOTRE REVENU POUR CETTE COURSE'
        : 'YOUR REVENUE FOR THIS RIDE';
  }
  if (section == 'payout_info') {
    return fr ? 'VERSEMENT' : 'PAYOUT';
  }
  switch (section) {
    case 'passenger_paid':
      return fr ? 'CE QUE LA PASSAGÈRE A PAYÉ' : 'WHAT THE PASSENGER PAID';
    case 'retained_by_qlyp':
      return fr ? 'RETENU PAR QLYP' : 'RETAINED BY QLYP';
    case 'paid_to_driver':
      return fr ? 'VERSÉ À VOUS' : 'PAID TO YOU';
    case 'cash_summary':
      return fr ? 'AJUSTEMENTS' : 'ADJUSTMENTS';
    case 'declarations':
      if (lineKey == 'decl_revenue') return null;
      return fr ? 'POUR VOS DÉCLARATIONS' : 'FOR YOUR TAX FILINGS';
    default:
      return null;
  }
}

const invoiceSectionOrder = [
  'ride_detail',
  'fee_detail',
  'promo',
  'taxable_subtotal',
  'tax',
  'ride_total',
  'toll',
  'tip',
  'grand_total',
];

const statementSectionOrder = [
  'your_ride',
  'passenger_paid',
  'retained_by_qlyp',
  'paid_to_driver',
  'driver_revenue',
  'cash_summary',
  'declarations',
  'payout_info',
];
