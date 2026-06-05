import React from 'react';
import { Paper, Box, Typography } from '@mui/material';

export interface ElvanSettingsSectionProps {
  title?: string;
  action?: React.ReactNode;
  children: React.ReactNode;
  sx?: any;
}

export default function ElvanSettingsSection({ title, action, children, sx }: ElvanSettingsSectionProps) {
  return (
    <Paper 
      className="s2-group" 
      elevation={2} 
      sx={{ 
        p: { xs: 2, md: 3 }, 
        mb: { xs: 2, md: 3 }, 
        borderRadius: { xs: 0, sm: 2 }, 
        borderX: { xs: 0, sm: undefined },
        ...sx
      }}
    >
      {(title || action) && (
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
          {title && (
            <Typography variant="h6" style={{ fontWeight: 600 }} sx={{ m: 0 }}>
              {title}
            </Typography>
          )}
          {action && (
            <Box sx={{ display: 'flex', gap: 1 }}>
              {action}
            </Box>
          )}
        </Box>
      )}
      {children}
    </Paper>
  );
}
