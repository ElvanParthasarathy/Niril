import React from 'react';
import { Box, Typography, IconButton, Tooltip } from '@mui/material';
import { PencilSimple, Printer as PrintIcon, DownloadSimple, ShareNetwork, Spinner } from '@phosphor-icons/react';
import { FloatingBackButton } from './FloatingBackButton';
import { useLanguage } from '../mozhi/LanguageContext';

export const ViewHeader = ({ onEdit, onPrint, onPDF, onShare, saving, sharing = false, title, onBack }) => {
  const { t } = useLanguage();
  return (
    <Box sx={{ px: { xs: 2, md: 0 }, mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 2, position: 'relative' }}>
      <Box sx={{ ml: {xs: 0, md: 2}, display: 'flex', gap: 0.5, alignItems: 'center', bgcolor: 'background.paper', borderRadius: '999px', px: 1, height: 40, boxSizing: 'border-box' }}>
        {onEdit && (
          <Tooltip title="Edit">
            <IconButton onClick={onEdit} size="small" sx={{ color: 'text.secondary' }}>
              <PencilSimple size={20} />
            </IconButton>
          </Tooltip>
        )}
        <Tooltip title="Print">
          <IconButton onClick={onPrint} size="small" sx={{ color: 'text.secondary' }}>
            <PrintIcon size={20} />
          </IconButton>
        </Tooltip>
        <Tooltip title="PDF">
          <IconButton onClick={onPDF} disabled={saving} size="small" sx={{ color: 'text.secondary' }}>
            <DownloadSimple size={20} />
          </IconButton>
        </Tooltip>
        <Tooltip title="Share">
          <IconButton onClick={onShare} disabled={sharing || saving} size="small" sx={{ color: 'text.secondary' }}>
            {sharing ? <Spinner size={20} className="animate-spin" /> : <ShareNetwork size={20} />}
          </IconButton>
        </Tooltip>
      </Box>
      
      {/* Centered Title (Desktop Only) */}
      <Typography variant="h6" sx={{ display: { xs: 'none', md: 'block' }, position: 'absolute', left: '50%', transform: 'translateX(-50%)', fontWeight: 700, color: 'text.primary', letterSpacing: '-0.5px' }}>
        {title}
      </Typography>

      <FloatingBackButton onBack={onBack} label={(t('back') || 'Back') as string} className="back-pill" />
    </Box>
  );
};
