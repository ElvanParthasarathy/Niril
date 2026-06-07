import React from 'react';
import { Box, Typography } from '@mui/material';

export default function CoolieDashboard(props) {
  return (
    <Box sx={{ p: 4, height: '80vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <Typography variant="h5" color="text.secondary" sx={{ opacity: 0.5 }}>
        Dashboard coming soon...
      </Typography>
    </Box>
  );
}
