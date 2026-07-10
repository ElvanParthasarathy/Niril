// @ts-nocheck
// ReceiptView — thin wrapper that uses PrintableViewWrapper for PDF/print/zoom
// and passes ReceiptPreview as the visual theme
import { INVOICE_TYPES } from '../../../Payanpadu';
import { PrintableViewWrapper } from '../../PrintableViewWrapper';
import ReceiptPreview from './ReceiptPreview';

export default function ReceiptView({ receipt, profile, onBack, onEdit, onDuplicate }) {
  if (!receipt) return null;

  const data = receipt.data || {};
  const typeConfig = INVOICE_TYPES[data.invoiceType || 'receipt'] || INVOICE_TYPES['receipt'] || INVOICE_TYPES['tax-invoice'];

  return (
    <PrintableViewWrapper
      data={data}
      typeConfig={typeConfig}
      onBack={onBack}
      onEdit={() => onEdit && onEdit(receipt)}
    >
      {(printRef, mergedOptions) => (
        <ReceiptPreview
          ref={printRef}
          profile={profile}
          client={data.client}
          details={data.details}
          items={data.items}
          totals={data.totals}
          invoiceType={data.invoiceType || 'receipt'}
          customTerms={data.customTerms}
          options={mergedOptions}
        />
      )}
    </PrintableViewWrapper>
  );
}
