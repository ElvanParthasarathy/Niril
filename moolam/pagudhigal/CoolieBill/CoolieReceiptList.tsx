import React from 'react';
import { Box, Typography } from '@mui/material';

export default function CoolieReceiptList() {
  return (
    <Box sx={{ maxWidth: '800px', margin: '0 auto', p: 4, textAlign: 'center' }}>
      <Typography variant="h4" sx={{ fontWeight: 800, mb: 2 }}>Coolie Receipts</Typography>
      <Typography variant="body1" color="text.secondary">
        Coolie receipt management is currently under development. 
        Please use the main generic Receipts section for now.
      </Typography>
    </Box>
  );
}
