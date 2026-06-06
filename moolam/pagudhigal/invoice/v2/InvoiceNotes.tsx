import React, { useRef, useEffect, useCallback } from 'react';
import { Box, Typography, Paper, Grid } from '@mui/material';
import { useLanguage } from '../../../mozhi/LanguageContext';
import DOMPurify from 'dompurify';

function RichEditor({ value, onChange, placeholder, toolbar = false }: any) {
  const { t } = useLanguage();
  const ref = useRef<HTMLDivElement>(null);
  const isInitialized = useRef(false);

  useEffect(() => {
    if (ref.current && !isInitialized.current) {
      ref.current.innerHTML = DOMPurify.sanitize(value || '');
      isInitialized.current = true;
    }
  }, []);

  useEffect(() => {
    if (ref.current && isInitialized.current && ref.current.innerHTML !== value) {
      ref.current.innerHTML = DOMPurify.sanitize(value || '');
    }
  }, [value]);

  const handleInput = useCallback(() => {
    if (ref.current) {
      onChange(ref.current.innerHTML);
    }
  }, [onChange]);

  const applyFormat = (cmd: string, val?: string) => {
    if (ref.current) ref.current.focus();
    document.execCommand(cmd, false, val);
    if (ref.current) onChange(ref.current.innerHTML);
  };
  
  const btnStyle = { padding: '0.2rem 0.5rem', fontSize: '0.78rem', borderRadius: '4px', border: '1px solid var(--border-color)', background: 'var(--bg-secondary)', cursor: 'pointer', minWidth: '28px' };

  return (
    <Box sx={{ width: '100%', position: 'relative' }}>
      {toolbar && (
        <Box sx={{ display: 'flex', gap: '0.25rem', flexWrap: 'wrap', mb: 1 }}>
          <button type="button" onClick={() => applyFormat('bold')} title="Bold (Ctrl+B)" style={{ ...btnStyle, fontWeight: 700 }}>B</button>
          <button type="button" onClick={() => applyFormat('italic')} title="Italic (Ctrl+I)" style={{ ...btnStyle, fontStyle: 'italic' }}>I</button>
          <button type="button" onClick={() => applyFormat('underline')} title="Underline (Ctrl+U)" style={{ ...btnStyle, textDecoration: 'underline' }}>U</button>
          <span style={{ width: 1, background: 'var(--border-color)', margin: '0 0.2rem' }} />
          <button type="button" onClick={() => applyFormat('insertUnorderedList')} title={t('hc_bulletList')} style={btnStyle}>•&nbsp;List</button>
          <button type="button" onClick={() => applyFormat('insertOrderedList')} title={t('hc_numberedList')} style={btnStyle}>1.&nbsp;List</button>
          <span style={{ width: 1, background: 'var(--border-color)', margin: '0 0.2rem' }} />
          <button type="button" onClick={() => applyFormat('formatBlock', '<h4>')} title={t('hc_heading')} style={{ ...btnStyle, fontWeight: 700, fontSize: '0.85rem' }}>H</button>
          <button type="button" onClick={() => applyFormat('formatBlock', '<p>')} title={t('hc_paragraph')} style={btnStyle}>¶</button>
          <button type="button" onClick={() => { const url = window.prompt('Link URL:'); if (url) applyFormat('createLink', url); }} title={t('hc_insertLink')} style={btnStyle}>🔗</button>
          <span style={{ width: 1, background: 'var(--border-color)', margin: '0 0.2rem' }} />
          <button type="button" onClick={() => applyFormat('removeFormat')} title={t('hc_clearFormatting')} style={btnStyle}>✕</button>
        </Box>
      )}
      <Box component="div" ref={ref} contentEditable suppressContentEditableWarning
        onInput={handleInput}
        sx={{
          minHeight: '100px', whiteSpace: 'pre-wrap', width: '100%', padding: '0.65rem 0.9rem',
          border: '1px solid', borderColor: 'divider', borderRadius: 2, 
          bgcolor: (theme) => theme.palette.mode === 'dark' ? 'rgba(255,255,255,0.03)' : '#FFFFFF',
          fontFamily: 'inherit', fontSize: '0.9rem', color: 'text.primary', transition: 'all 0.2s',
          cursor: 'text', outline: 'none', lineHeight: 1.6,
          '&:empty::before': { content: 'attr(data-placeholder)', color: 'text.disabled', pointerEvents: 'none' },
          '&:focus': { borderColor: 'primary.main', boxShadow: '0 0 0 2px rgba(25, 118, 210, 0.2)' },
          '& ul, & ol': { marginLeft: '1.5rem', pl: 0, mt: 0.5, mb: 0.5 },
          '& table': { borderCollapse: 'collapse', width: '100%' },
          '& table th, & table td': { border: '1px solid', borderColor: 'divider', padding: '0.35rem 0.5rem' }
        }}
        data-placeholder={placeholder} />
    </Box>
  );
}

interface InvoiceNotesProps {
  customTerms: string;
  setCustomTerms: (terms: string) => void;
  internalNote: string;
  setInternalNote: (note: string) => void;
  showTerms: boolean;
  showNotes: boolean;
}

export default function InvoiceNotes({
  customTerms,
  setCustomTerms,
  showTerms,
}: InvoiceNotesProps) {
  const { t } = useLanguage();

  if (!showTerms) return null;

  return (
    <Box sx={{ mb: 2 }}>
      <Grid container spacing={3}>
        {showTerms && (
          <Grid size={{ xs: 12, md: 6 }}>
            <Typography variant="subtitle2" gutterBottom>{t('terms') || 'Terms & Conditions'}</Typography>
            <RichEditor 
              toolbar 
              value={customTerms} 
              onChange={setCustomTerms} 
              placeholder="E.g., Payment is due within 30 days." 
            />
          </Grid>
        )}
      </Grid>
    </Box>
  );
}
