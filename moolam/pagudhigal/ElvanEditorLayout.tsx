import React from 'react';
import { Box, Typography, Button } from '@mui/material';
import { FloppyDisk } from '@phosphor-icons/react';
import { FloatingBackButton } from './FloatingBackButton';
import { useLanguage } from '../mozhi/LanguageContext';

export interface ElvanEditorLayoutProps {
  title: string;
  onBack: () => void;
  onSave: () => void;
  saveButtonText: string;
  saveButtonIcon?: React.ReactNode;
  children: React.ReactNode;
}

export default function ElvanEditorLayout({
  title,
  onBack,
  onSave,
  saveButtonText,
  saveButtonIcon = <FloppyDisk size={20} weight="bold" />,
  children
}: ElvanEditorLayoutProps) {
  const { t } = useLanguage();

  return (
    <Box sx={{ py: { xs: 1.5, md: 4 }, px: { xs: 0, md: 4 }, maxWidth: 1200, mx: 'auto', position: 'relative' }}>
      <Box sx={{ px: { xs: 2, md: 0 }, mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h5" sx={{ ml: 2, fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary' }}>
          {title}
        </Typography>
        <FloatingBackButton onBack={onBack} label={(t('back') || 'Back') as string} className="back-pill" />
      </Box>

      <Box sx={{ px: { xs: 2, md: 0 } }}>
        {children}
      </Box>

      <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 2, mb: 6, mt: 5, px: { xs: 2, md: 0 } }}>
        <Button 
          variant="contained" 
          disableElevation 
          onClick={onBack} 
          sx={{ height: 40, minHeight: 40, maxHeight: 40, px: 3, borderRadius: '50px', bgcolor: 'background.paper', color: 'text.primary', '&:hover': { bgcolor: 'action.hover' } }}
        >
          {t('cancelModalBtn') || 'Cancel'}
        </Button>
        <Button 
          variant="contained" 
          color="primary" 
          disableElevation 
          onClick={onSave} 
          startIcon={saveButtonIcon} 
          sx={{ height: 40, minHeight: 40, maxHeight: 40, px: 3, borderRadius: '50px' }}
        >
          {saveButtonText}
        </Button>
      </Box>
    </Box>
  );
}
