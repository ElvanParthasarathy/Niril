import React from 'react';
import { Box, Typography, Paper, Divider } from '@mui/material';

export interface SettingsSectionProps {
  title?: string;
  description?: React.ReactNode;
  children: React.ReactNode;
  sx?: any;
}

export function SettingsSection({ title, description, children, sx }: SettingsSectionProps) {
  return (
    <Box sx={{ mb: 4, ...sx }}>
      {title && (
        <Typography variant="subtitle2" sx={{ ml: 2, mb: 1, textTransform: 'uppercase', letterSpacing: 0.5, fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>
          {title}
        </Typography>
      )}
      <Paper 
        elevation={0} 
        sx={{ 
          borderRadius: 3, 
          overflow: 'hidden', 
          bgcolor: 'background.paper',
          border: '1px solid',
          borderColor: 'divider',
          '& > *:not(:last-child)': {
            borderBottom: '1px solid',
            borderColor: 'divider'
          }
        }}
      >
        {children}
      </Paper>
      {description && (
        <Typography variant="caption" sx={{ ml: 2, mt: 1, display: 'block', color: 'text.secondary' }}>
          {description}
        </Typography>
      )}
    </Box>
  );
}

export interface SettingsRowProps {
  icon?: React.ReactNode;
  title: string;
  description?: React.ReactNode;
  control?: React.ReactNode;
  onClick?: () => void;
  sx?: any;
}

export function SettingsRow({ icon, title, description, control, onClick, sx }: SettingsRowProps) {
  return (
    <Box 
      onClick={onClick}
      sx={{ 
        display: 'flex', 
        alignItems: 'center', 
        p: { xs: 2, md: 2.5 },
        cursor: onClick ? 'pointer' : 'default',
        '&:hover': onClick ? { bgcolor: 'action.hover' } : {},
        transition: 'background-color 0.2s',
        ...sx
      }}
    >
      {icon && (
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: 36, height: 36, borderRadius: 2, mr: 2, color: 'primary.main', bgcolor: 'primary.light', opacity: 0.8 }}>
          {icon}
        </Box>
      )}
      <Box sx={{ flexGrow: 1, minWidth: 0, pr: 2 }}>
        <Typography variant="body1" sx={{ fontWeight: 500 }}>
          {title}
        </Typography>
        {description && (
          <Typography variant="body2" color="text.secondary" sx={{ mt: 0.25, display: 'block' }}>
            {description}
          </Typography>
        )}
      </Box>
      {control && (
        <Box sx={{ flexShrink: 0, display: 'flex', alignItems: 'center' }}>
          {control}
        </Box>
      )}
    </Box>
  );
}

// Keep the old component for backward compatibility if it's used elsewhere
export interface ElvanSettingsSectionProps {
  title?: string;
  action?: React.ReactNode;
  children: React.ReactNode;
  sx?: any;
}

export default function ElvanSettingsSection({ title, action, children, sx }: ElvanSettingsSectionProps) {
  return (
    <SettingsSection title={title} sx={sx}>
      <Box sx={{ p: { xs: 2, md: 3 } }}>
        {action && (
          <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 2 }}>
            {action}
          </Box>
        )}
        {children}
      </Box>
    </SettingsSection>
  );
}
