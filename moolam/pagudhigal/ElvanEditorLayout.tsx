import React, { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { Box, Typography, Button, useMediaQuery, useTheme } from '@mui/material';
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
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [mounted, setMounted] = useState(false);

  useEffect(() => { setMounted(true); }, []);

  const isEditingTitle = title.includes(t('edit')) || title.toLowerCase().includes('edit') || title.includes('திருத்து');
  const displayTitle = isMobile && isEditingTitle ? (t('edit') || 'Edit') : title;

  const titleElement = (
    <Typography variant="h5" sx={{ 
      ml: { xs: 1.5, md: 2 }, 
      fontWeight: 800, 
      letterSpacing: '-0.5px', 
      color: 'text.primary',
      fontSize: { xs: '1.1rem', md: '1.5rem' }
    }}>
      {displayTitle}
    </Typography>
  );

  const backButtonElement = (
    <FloatingBackButton onBack={onBack} label={(t('back') || 'Back') as string} className="back-pill" />
  );

  let renderHeader = null;
  if (isMobile && mounted) {
    const leftTarget = document.getElementById('mobile-topbar-left');
    const rightTarget = document.getElementById('mobile-topbar-right');
    if (leftTarget && rightTarget) {
      renderHeader = (
        <>
          {createPortal(titleElement, leftTarget)}
          {createPortal(backButtonElement, rightTarget)}
        </>
      );
    }
  } else if (!isMobile) {
    renderHeader = (
      <Box sx={{ 
        px: 0, 
        mb: 4, 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center'
      }}>
        {titleElement}
        {backButtonElement}
      </Box>
    );
  }

  return (
    <Box sx={{ py: { xs: 1.5, md: 4 }, px: { xs: 0, md: 4 }, maxWidth: 1200, mx: 'auto', position: 'relative' }}>
      {renderHeader}

      <Box sx={{ px: 0 }}>
        {children}
      </Box>

      <Box sx={{ display: { xs: 'none', md: 'flex' }, justifyContent: 'flex-end', gap: 2, mb: 6, mt: 5, px: 0 }}>
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

      {/* Mobile Squircle FAB for Save */}
      {isMobile && (
        <Button
          variant="contained"
          color="primary"
          onClick={onSave}
          sx={{
            display: { xs: 'flex', md: 'none' },
            position: 'fixed',
            bottom: 'calc(env(safe-area-inset-bottom, 0px) + 40px)',
            right: 20,
            minWidth: 56,
            width: 56,
            height: 56,
            borderRadius: '20px',
            zIndex: 1100,
            boxShadow: '0 8px 24px rgba(0,0,0,0.2)',
            p: 0,
          }}
        >
          {saveButtonIcon || <FloppyDisk size={24} weight="fill" />}
        </Button>
      )}
    </Box>
  );
}
