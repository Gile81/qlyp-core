/// Firestore / callable wire names for billing (S7-D contract).
///
/// Mirror of `functions/src/contracts/billing_contract.json`.
/// SHA-256: b33ee67527d497d74f47b6239a56b63abb3d662b9fbe65ee39113adc97dab8d3
abstract final class BillingContract {
  static const String contractSha256 =
      'B33EE67527D497D74F47B6239A56B63ABB3D662B9FBE65EE39113ADC97DAB8D3';

  static const String callableGetBillingDocumentUrl = 'getBillingDocumentUrl';
  static const String callableSetRideTip = 'setRideTip';
  static const String callableSetTipPromptState = 'setTipPromptState';

  static const String inputDocumentType = 'documentType';
  static const String inputDocumentId = 'documentId';
  static const String documentTypeInvoice = 'invoice';
  static const String documentTypeStatement = 'statement';

  static const String outputUrl = 'url';
  static const String outputExpiresAt = 'expiresAt';

  static const String collectionInvoices = 'invoices';
  static const String collectionDriverStatements = 'driver_statements';

  static const String fieldFinancials = 'financials';
  static const String fieldFinancialsStatus = 'financials_status';
  static const String fieldFinancialsErrorCode = 'financials_error_code';
  static const String fieldFinancialsAttempts = 'financials_attempts';
  static const String fieldBillingDocumentsStatus = 'billing_documents_status';
  static const String fieldBillingDocumentsBlockReason =
      'billing_documents_block_reason';
  static const String fieldQuoteRefreshStatus = 'quote_refresh_status';
  static const String fieldInvoiceId = 'invoice_id';
  static const String fieldStatementId = 'statement_id';
  static const String fieldPriceBreakdown = 'price_breakdown';
  static const String fieldPriceBreakdownQuoteOriginal =
      'price_breakdown_quote_original';
  static const String fieldQuoteRideTotal = 'quote_ride_total';
  static const String fieldDriverPayoutEstimate = 'driver_payout_estimate';
  static const String fieldDriverPayoutToll = 'driver_payout_toll';
  static const String fieldDriverCourseTaxesToRemit =
      'driver_course_taxes_to_remit';
  static const String fieldDriverNetEstimate = 'driver_net_estimate';
  static const String fieldTipAmount = 'tip_amount';
  static const String fieldTipStatus = 'tip_status';
  static const String fieldTipSetAt = 'tip_set_at';
  static const String fieldTipOptions = 'tip_options';
  static const String fieldTipDeadlineAt = 'tip_deadline_at';
  static const String fieldTipPromptState = 'tip_prompt_state';
  static const String fieldFinancialsHistory = 'financials_history';

  static const List<String> orderFieldKeys = [
    fieldFinancials,
    fieldFinancialsStatus,
    fieldFinancialsErrorCode,
    fieldFinancialsAttempts,
    fieldBillingDocumentsStatus,
    fieldBillingDocumentsBlockReason,
    fieldQuoteRefreshStatus,
    fieldInvoiceId,
    fieldStatementId,
    fieldPriceBreakdown,
    fieldPriceBreakdownQuoteOriginal,
    fieldQuoteRideTotal,
    fieldDriverPayoutEstimate,
    fieldDriverPayoutToll,
    fieldDriverCourseTaxesToRemit,
    fieldDriverNetEstimate,
    fieldTipAmount,
    fieldTipStatus,
    fieldTipSetAt,
    fieldTipOptions,
    fieldTipDeadlineAt,
    fieldTipPromptState,
    fieldFinancialsHistory,
  ];

  static const String inputOrderId = 'orderId';
  static const String inputTipAmount = 'amount';
  static const String inputTipPromptState = 'state';

  static const String outputOk = 'ok';
  static const String outputTipAmount = 'tip_amount';
  static const String outputTipPromptState = 'tip_prompt_state';

  static const String tipPromptStatePending = 'pending';
  static const String tipPromptStateLater = 'later';
  static const String tipPromptStateReminded = 'reminded';
  static const String tipPromptStateDeclined = 'declined';
  static const String tipPromptStateCompleted = 'completed';

  static const List<String> tipPromptStates = [
    tipPromptStatePending,
    tipPromptStateLater,
    tipPromptStateReminded,
    tipPromptStateDeclined,
    tipPromptStateCompleted,
  ];

  static const List<String> clientTipPromptStates = [
    tipPromptStateLater,
    tipPromptStateReminded,
    tipPromptStateDeclined,
  ];

  static const List<String> tipReminderQueryPromptStates = [
    tipPromptStatePending,
    tipPromptStateLater,
  ];

  static const String tipOptionPct = 'pct';
  static const String tipOptionAmount = 'amount';

  static const List<String> marketplaceBidPayoutFieldKeys = [
    fieldDriverPayoutEstimate,
    fieldDriverPayoutToll,
    fieldDriverCourseTaxesToRemit,
    fieldDriverNetEstimate,
  ];

  static const String rideFinancialsType = 'type';
  static const String rideFinancialsPassengerTotalTtc = 'passenger_total_ttc';
  static const String rideFinancialsToll = 'toll';
  static const String rideFinancialsTip = 'tip';
  static const String rideFinancialsCommissionRateApplied =
      'commission_rate_applied';
  static const String rideFinancialsCommissionHt = 'commission_ht';
  static const String rideFinancialsCommissionTaxes = 'commission_taxes';
  static const String rideFinancialsRetainedByQlyp = 'retained_by_qlyp';
  static const String rideFinancialsPaidToDriver = 'paid_to_driver';
  static const String rideFinancialsDriverCourseTaxesToRemit =
      'driver_course_taxes_to_remit';
  static const String rideFinancialsDriverCourseTaxesToRemitTotal =
      'driver_course_taxes_to_remit_total';
  static const String rideFinancialsDriverRevenue = 'driver_revenue';
  static const String rideFinancialsDriverPayoutEstimate =
      'driver_payout_estimate';
  static const String rideFinancialsDriverPayoutToll = 'driver_payout_toll';
  static const String rideFinancialsDriverNetEstimate = 'driver_net_estimate';
  static const String rideFinancialsCashCollectedByDriver =
      'cash_collected_by_driver';
  static const String rideFinancialsCashDueToQlyp = 'cash_due_to_qlyp';
  static const String rideFinancialsQlypPromoSubsidy = 'qlyp_promo_subsidy';
  static const String rideFinancialsRoundingAdjustment = 'rounding_adjustment';
  static const String rideFinancialsSnapshot = 'snapshot';
  static const String rideFinancialsRetainedBreakdown = 'retained_breakdown';
  static const String rideFinancialsControls = 'controls';

  static const List<String> rideFinancialsKeys = [
    rideFinancialsType,
    rideFinancialsPassengerTotalTtc,
    rideFinancialsToll,
    rideFinancialsTip,
    rideFinancialsCommissionRateApplied,
    rideFinancialsCommissionHt,
    rideFinancialsCommissionTaxes,
    rideFinancialsRetainedByQlyp,
    rideFinancialsPaidToDriver,
    rideFinancialsDriverCourseTaxesToRemit,
    rideFinancialsDriverCourseTaxesToRemitTotal,
    rideFinancialsDriverRevenue,
    rideFinancialsDriverPayoutEstimate,
    rideFinancialsDriverPayoutToll,
    rideFinancialsDriverNetEstimate,
    rideFinancialsCashCollectedByDriver,
    rideFinancialsCashDueToQlyp,
    rideFinancialsQlypPromoSubsidy,
    rideFinancialsRoundingAdjustment,
    rideFinancialsSnapshot,
    rideFinancialsRetainedBreakdown,
    rideFinancialsControls,
  ];

  static const String invoiceFieldVersion = 'version';
  static const String invoiceFieldType = 'type';
  static const String invoiceFieldDocumentNumber = 'document_number';
  static const String invoiceFieldPreviousVersionId = 'previous_version_id';
  static const String invoiceFieldReplacesPreviousIssuedAt =
      'replaces_previous_issued_at';
  static const String invoiceFieldOrderId = 'order_id';
  static const String invoiceFieldUserId = 'user_id';
  static const String invoiceFieldDriverId = 'driver_id';
  static const String invoiceFieldZoneId = 'zone_id';
  static const String invoiceFieldPillar = 'pillar';
  static const String invoiceFieldLanguage = 'language';
  static const String invoiceFieldIssuedAt = 'issued_at';
  static const String invoiceFieldHeader = 'header';
  static const String invoiceFieldDisplayLines = 'display_lines';
  static const String invoiceFieldRideSubtotalTaxableHt =
      'ride_subtotal_taxable_ht';
  static const String invoiceFieldRideTaxes = 'ride_taxes';
  static const String invoiceFieldRideTotalTtc = 'ride_total_ttc';
  static const String invoiceFieldToll = 'toll';
  static const String invoiceFieldTip = 'tip';
  static const String invoiceFieldPassengerTotalTtc = 'passenger_total_ttc';
  static const String invoiceFieldPayment = 'payment';
  static const String invoiceFieldLegal = 'legal';
  static const String invoiceFieldRetainUntil = 'retain_until';
  static const String invoiceFieldRetentionYears = 'retention_years';
  static const String invoiceFieldPdfPath = 'pdf_path';
  static const String invoiceFieldPdfStatus = 'pdf_status';
  static const String invoiceFieldPdfError = 'pdf_error';
  static const String invoiceFieldPdfErrorCode = 'pdf_error_code';

  static const List<String> invoiceDocumentKeys = [
    invoiceFieldVersion,
    invoiceFieldType,
    invoiceFieldDocumentNumber,
    invoiceFieldOrderId,
    invoiceFieldUserId,
    invoiceFieldDriverId,
    invoiceFieldZoneId,
    invoiceFieldPillar,
    invoiceFieldLanguage,
    invoiceFieldIssuedAt,
    invoiceFieldHeader,
    invoiceFieldDisplayLines,
    invoiceFieldRideSubtotalTaxableHt,
    invoiceFieldRideTaxes,
    invoiceFieldRideTotalTtc,
    invoiceFieldToll,
    invoiceFieldTip,
    invoiceFieldPassengerTotalTtc,
    invoiceFieldPayment,
    invoiceFieldLegal,
    invoiceFieldPreviousVersionId,
    invoiceFieldReplacesPreviousIssuedAt,
    invoiceFieldRetainUntil,
    invoiceFieldRetentionYears,
    invoiceFieldPdfPath,
    invoiceFieldPdfStatus,
    invoiceFieldPdfError,
    invoiceFieldPdfErrorCode,
  ];

  static const String statementFieldCommission = 'commission';
  static const String statementFieldStatementLines = 'statement_lines';
  static const String statementFieldYourRideLines = 'your_ride_lines';
  static const String statementFieldYourRideSubtotalHt = 'your_ride_subtotal_ht';
  static const String statementFieldPassengerPaidTotalTtc =
      'passenger_paid_total_ttc';
  static const String statementFieldRetainedTotal = 'retained_total';
  static const String statementFieldPaidToDriver = 'paid_to_driver';
  static const String statementFieldDriverTaxesToRemit = 'driver_taxes_to_remit';
  static const String statementFieldDriverTaxesToRemitTotal =
      'driver_taxes_to_remit_total';
  static const String statementFieldQlypPromoSubsidy = 'qlyp_promo_subsidy';
  static const String statementFieldCashCollectedByDriver =
      'cash_collected_by_driver';
  static const String statementFieldCashDueToQlyp = 'cash_due_to_qlyp';
  static const String statementFieldCashCollectedLabelFr =
      'cash_collected_label_fr';
  static const String statementFieldCashCollectedLabelEn =
      'cash_collected_label_en';
  static const String statementFieldCashDueLabelFr = 'cash_due_label_fr';
  static const String statementFieldCashDueLabelEn = 'cash_due_label_en';

  static const List<String> driverStatementDocumentKeys = [
    invoiceFieldVersion,
    invoiceFieldType,
    invoiceFieldDocumentNumber,
    invoiceFieldOrderId,
    invoiceFieldUserId,
    invoiceFieldDriverId,
    invoiceFieldZoneId,
    invoiceFieldPillar,
    invoiceFieldLanguage,
    invoiceFieldIssuedAt,
    invoiceFieldHeader,
    statementFieldCommission,
    statementFieldStatementLines,
    statementFieldYourRideLines,
    statementFieldYourRideSubtotalHt,
    statementFieldPassengerPaidTotalTtc,
    statementFieldRetainedTotal,
    invoiceFieldToll,
    invoiceFieldTip,
    statementFieldPaidToDriver,
    statementFieldDriverTaxesToRemit,
    statementFieldDriverTaxesToRemitTotal,
    rideFinancialsDriverRevenue,
    statementFieldQlypPromoSubsidy,
    statementFieldCashCollectedByDriver,
    statementFieldCashDueToQlyp,
    statementFieldCashCollectedLabelFr,
    statementFieldCashCollectedLabelEn,
    statementFieldCashDueLabelFr,
    statementFieldCashDueLabelEn,
    invoiceFieldPayment,
    invoiceFieldLegal,
    invoiceFieldPreviousVersionId,
    invoiceFieldReplacesPreviousIssuedAt,
    invoiceFieldRetainUntil,
    invoiceFieldRetentionYears,
    invoiceFieldPdfPath,
    invoiceFieldPdfStatus,
    invoiceFieldPdfError,
    invoiceFieldPdfErrorCode,
  ];

  static const String lineKey = 'key';
  static const String lineLabelFr = 'label_fr';
  static const String lineLabelEn = 'label_en';
  static const String lineAmount = 'amount';
  static const String lineAmountHt = 'amount_ht';
  static const String lineSection = 'section';
  static const String lineNotYoursFr = 'not_yours_fr';
  static const String lineNotYoursEn = 'not_yours_en';
  static const String lineTextOnly = 'text_only';

  static const String errorInvalidRequest = 'invalid_request';
  static const String errorNotFound = 'not_found';
  static const String errorPermissionDenied = 'permission_denied';
  static const String errorPdfNotReady = 'pdf_not_ready';
  static const String errorFirmBidMissingQuoteBreakdown =
      'firm_bid_missing_quote_breakdown';
  static const String errorMaxAttemptsExceeded = 'max_attempts_exceeded';
  static const String errorBlockedQuoteRefresh = 'blocked_quote_refresh';
  static const String errorQuoteRefreshPending = 'quote_refresh_pending';
  static const String errorQuoteRefreshError = 'quote_refresh_error';
  static const String errorTipNotAllowedCash = 'tip_not_allowed_cash';
  static const String errorTipOrderNotCompleted = 'tip_order_not_completed';
  static const String errorTipOrderNotPaid = 'tip_order_not_paid';
  static const String errorTipWindowExpired = 'tip_window_expired';
  static const String errorTipAlreadySet = 'tip_already_set';
  static const String errorTipInvalidAmount = 'tip_invalid_amount';
  static const String errorTipPromptInvalidTransition =
      'tip_prompt_invalid_transition';
  static const String errorOrderNotFound = 'order_not_found';

  static const List<String> getBillingDocumentUrlErrorCodes = [
    errorInvalidRequest,
    errorNotFound,
    errorPermissionDenied,
    errorPdfNotReady,
  ];

  static const List<String> setRideTipErrorCodes = [
    errorTipNotAllowedCash,
    errorTipOrderNotPaid,
    errorTipOrderNotCompleted,
    errorTipWindowExpired,
    errorTipAlreadySet,
    errorTipInvalidAmount,
    errorOrderNotFound,
    errorPermissionDenied,
  ];

  static const List<String> setTipPromptStateErrorCodes = [
    errorTipPromptInvalidTransition,
    errorTipNotAllowedCash,
    errorTipOrderNotPaid,
    errorTipOrderNotCompleted,
    errorTipWindowExpired,
    errorTipAlreadySet,
    errorOrderNotFound,
    errorPermissionDenied,
  ];

  static const List<String> billingErrorCodes = [
    errorBlockedQuoteRefresh,
    errorFirmBidMissingQuoteBreakdown,
    errorInvalidRequest,
    errorMaxAttemptsExceeded,
    errorNotFound,
    errorPdfNotReady,
    errorPermissionDenied,
    errorQuoteRefreshError,
    errorQuoteRefreshPending,
    errorTipAlreadySet,
    errorTipInvalidAmount,
    errorTipNotAllowedCash,
    errorTipOrderNotCompleted,
    errorTipOrderNotPaid,
    errorTipPromptInvalidTransition,
    errorTipWindowExpired,
  ];

  static const List<String> internalAdminBillingActions = [
    'get_settings',
    'save_settings',
    'retry_document',
    'retry_all_blocked',
    'get_document_url',
    'regenerate_pdf',
    'freeze_commission_rate',
  ];
}
