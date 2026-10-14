/**
 * Exports server billing documents for core tests/goldens.
 * Run from qlyp-core: npx tsx tool/export_billing_doc_fixtures.ts
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import {
  buildMaquetteAPricing,
  buildMaquetteEPricing,
  LAVAL_BILLING_ZONE,
  MAQUETTE_A_COMMISSION,
  MAQUETTE_E_TIP,
  MAQUETTE_E_TOLL_TTC,
} from '../../functions/src/billing/__tests__/maquette-fixtures.ts';
import { computeRideFinancials } from '../../functions/src/billing/compute-ride-financials.ts';
import {
  buildRideBillingDocuments,
  buildCancellationBillingDocuments,
} from '../../functions/src/billing/build-billing-documents.ts';
import { buildQuoteContext } from '../../functions/src/pricing/quote_context.ts';
import { step2LoadZoneZrsFromDocument } from '../../functions/src/pricing/waterfall.ts';
import { DEFAULT_BILLING_SETTINGS } from '../../functions/src/billing/billing-settings.ts';
import { driverTaxFromUserData } from '../../functions/src/billing/driver-tax-for-billing.ts';
import { computeCancellationFinancials } from '../../functions/src/billing/compute-cancellation-financials.ts';
import { formatBillingDocumentNumber } from '../../functions/src/billing/billing-document-number.ts';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const coreRoot = path.resolve(__dirname, '..');
const outDir = path.join(coreRoot, 'test/fixtures/billing_docs');
fs.mkdirSync(outDir, { recursive: true });

const zone = step2LoadZoneZrsFromDocument(LAVAL_BILLING_ZONE);
const quoteCtx = buildQuoteContext({ pricing_strategy: 'CTQ_METER' });
const commissionQuoteCtx = buildQuoteContext({
  pricing_strategy: 'CTQ_METER',
  taxes_exempt: false,
});
const settings = {
  ...DEFAULT_BILLING_SETTINGS,
  legal_name: 'Les Plateformes Qlyp Inc.',
  city: 'Montréal',
  gst_number: '123456789RT0001',
  qst_number: '1234567890TQ0001',
};
const driverTax = driverTaxFromUserData(
  {
    taxRegistrations: {
      gstHstNumber: '123456789RT0001',
      provinces: { QC: { qstNumber: '1234567890TQ0001' } },
    },
  },
  'QC',
);
const referenceAt = new Date('2026-01-13T15:30:00.000Z');

function writeJson(name: string, data: unknown) {
  fs.writeFileSync(
    path.join(outDir, name),
    `${JSON.stringify(data, null, 2)}\n`,
    'utf8',
  );
}

function rideFinancials(
  pricing: ReturnType<typeof buildMaquetteAPricing>,
  opts: { paymentType?: string; tip?: number; toll?: unknown } = {},
) {
  return computeRideFinancials({
    pricing,
    commissionRateApplied: MAQUETTE_A_COMMISSION,
    zone,
    quoteCtx,
    commissionQuoteCtx,
    paymentType: opts.paymentType ?? 'card',
    tip: opts.tip ?? 0,
    toll: opts.toll ?? null,
  });
}

function rideDocs(
  financials: ReturnType<typeof computeRideFinancials>,
  documentNumber: string,
  orderId: string,
) {
  return buildRideBillingDocuments({
    orderId,
    order: {
      userId: 'pass_1',
      driverId: 'drv_1',
      zoneId: 'zone_laval',
      paymentType: financials.cash_collected_by_driver ? 'cash' : 'card',
      destinationLocationName: 'Montréal, QC',
    },
    zoneDoc: LAVAL_BILLING_ZONE,
    financials,
    settings,
    driverTax,
    documentNumber,
    issuedAt: referenceAt,
    referenceAt,
  });
}

const aCard = rideDocs(
  rideFinancials(buildMaquetteAPricing(), { paymentType: 'card' }),
  'QLP-2026-000001',
  'ord_a_card',
);
writeJson('a_card_invoice.json', aCard.invoice);
writeJson('a_card_statement.json', aCard.statement);

const aCash = rideDocs(
  rideFinancials(buildMaquetteAPricing(), { paymentType: 'cash' }),
  'QLP-2026-000002',
  'ord_a_cash',
);
writeJson('a_cash_statement.json', aCash.statement);

const eToll = {
  items: [{ label_fr: 'Peage', label_en: 'Toll', amount_ht: MAQUETTE_E_TOLL_TTC }],
  subtotal_ht: MAQUETTE_E_TOLL_TTC,
  taxes: [],
  total_ttc: MAQUETTE_E_TOLL_TTC,
};
const eV1 = rideDocs(
  rideFinancials(buildMaquetteEPricing(), {
    paymentType: 'card',
    tip: 0,
    toll: eToll,
  }),
  'QLP-2026-000123',
  'ord_e',
);
writeJson('e_invoice_v1.json', eV1.invoice);
writeJson('e_statement_v1.json', eV1.statement);

const eV2Fin = rideFinancials(buildMaquetteEPricing(), {
  paymentType: 'card',
  tip: MAQUETTE_E_TIP,
  toll: eToll,
});
const eV2 = buildRideBillingDocuments({
  orderId: 'ord_e',
  order: {
    userId: 'pass_1',
    driverId: 'drv_1',
    zoneId: 'zone_laval',
    paymentType: 'card',
    destinationLocationName: 'Montréal, QC',
  },
  zoneDoc: LAVAL_BILLING_ZONE,
  financials: eV2Fin,
  settings,
  driverTax,
  documentNumber: 'QLP-2026-000124',
  issuedAt: referenceAt,
  referenceAt,
  documentVersion: 2,
  previousVersionId: 'e_v1_invoice_doc',
  previousStatementVersionId: 'e_v1_statement_doc',
});
writeJson('e_invoice.json', eV2.invoice);
writeJson('e_statement.json', eV2.statement);

const cancelFin = computeCancellationFinancials({
  fee_ht: 2.05,
  fee_taxes: [
    { id: 'gst', rate: 0.05, amount: 0.1, label_fr: 'TPS', label_en: 'GST' },
    { id: 'qst', rate: 0.09975, amount: 0.2, label_fr: 'TVQ', label_en: 'QST' },
  ],
  fee_ttc: 2.35,
  driver_share: 1.64,
  platform_share: 0.41,
});
const documentNumber = formatBillingDocumentNumber('QLP', 'cancellation', 2026, 45);
const dDocs = buildCancellationBillingDocuments({
  orderId: 'ord_cancel_d',
  order: {
    userId: 'pass_1',
    driverId: 'drv_1',
    zoneId: 'zone_laval',
    cancellation: { at: referenceAt, reason: 'driver_arrived' },
    sourceLocationName: 'Laval, QC',
    destinationLocationName: 'Montréal, QC',
  },
  zoneDoc: LAVAL_BILLING_ZONE,
  financials: cancelFin,
  settings,
  driverTax,
  documentNumber,
  issuedAt: new Date('2026-01-13T16:00:00.000Z'),
  referenceAt,
  passengerUser: { firstName: 'Marie', lastName: 'Tremblay' },
  driverUser: { firstName: 'Jean', lastName: 'Dupont' },
});
writeJson('d_invoice.json', dDocs.invoice);
writeJson('d_statement.json', dDocs.statement);

console.log('A card', aCard.invoice.passenger_total_ttc, aCard.statement.paid_to_driver);
console.log('E v1', eV1.invoice.passenger_total_ttc, eV1.statement.paid_to_driver);
console.log('E v2', eV2.invoice.passenger_total_ttc, eV2.statement.paid_to_driver);
console.log('D', dDocs.invoice.passenger_total_ttc, dDocs.statement.paid_to_driver);
