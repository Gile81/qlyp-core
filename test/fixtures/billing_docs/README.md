# Billing document fixtures (S7-D2)

Server-shaped JSON exported from `buildRideBillingDocuments` and maquette fixtures in the Qlyp `functions` repo.

- **Functions git commit (Qlyp root):** `2fafcbc`
- **Regenerate (from `qlyp-core`):** `npx tsx tool/export_billing_doc_fixtures.ts`

Files:

| File | Maquette |
|------|----------|
| `a_card_invoice.json` / `a_card_statement.json` | A carte |
| `a_cash_statement.json` | A comptant |
| `e_invoice_v1.json` / `e_statement_v1.json` | E v1 (paid ride, no tip) |
| `e_invoice.json` / `e_statement.json` | E v2 (after tip, version 2) |
| `d_invoice.json` / `d_statement.json` | D annulation |

The export script writes only under `test/fixtures/billing_docs/`; it does not modify the Qlyp root repo.
