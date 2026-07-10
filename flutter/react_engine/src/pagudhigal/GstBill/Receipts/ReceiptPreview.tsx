import React from 'react';
import ReceiptTheme from './ReceiptTheme';

const ReceiptPreview = React.forwardRef(({ profile = {}, client = {}, details = {}, items = [], totals = {}, invoiceType = 'tax-invoice', customTerms, options = {} }, ref) => {
  return <ReceiptTheme ref={ref} profile={profile} client={client} details={details} items={items} totals={totals} invoiceType={invoiceType} customTerms={customTerms} options={options} />;
});

export default ReceiptPreview;
