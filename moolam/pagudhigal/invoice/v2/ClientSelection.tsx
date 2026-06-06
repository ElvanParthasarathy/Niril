import React, { useState, useEffect, useRef } from 'react';
import { Box, Typography, Paper, Grid, TextField, Button, List, ListItem, ListItemButton, ListItemText, Divider } from '@mui/material';
import { Plus } from '@phosphor-icons/react';
import { useLanguage } from '../../../mozhi/LanguageContext';
import { ClientState } from './InvoiceTypes';
import { getBilingualStateName, getBilingualCountryName } from '../../../Payanpadu';
import { getAllClients, saveClient } from '../../../Avanam';
import { thagaval } from '../../Thagaval';
import ElvanCard from '../../ElvanCard';

interface ClientSelectionProps {
  client: ClientState;
  setClient: (client: ClientState | ((prev: ClientState) => ClientState)) => void;
  isBilingual: boolean;
  primaryLang: string;
  secondaryLang: string;
  profile: any;
  invoiceOptions: any;
}

export default function ClientSelection({
  client,
  setClient,
  isBilingual,
  primaryLang,
  secondaryLang,
  profile,
  invoiceOptions,
}: ClientSelectionProps) {
  const { t } = useLanguage();
  
  const [savedClients, setSavedClients] = useState<any[]>([]);
  const [showClientSuggestions, setShowClientSuggestions] = useState(false);
  const [selectedClientId, setSelectedClientId] = useState<string | null>(null);
  
  const clientNameRef = useRef<HTMLInputElement>(null);
  const clientSuggestionsRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    getAllClients().then(clients => {
      setSavedClients(clients);
    });
  }, []);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (clientSuggestionsRef.current && !clientSuggestionsRef.current.contains(e.target as Node) &&
          clientNameRef.current && !clientNameRef.current.contains(e.target as Node)) {
        setShowClientSuggestions(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const getClientField = (f: keyof ClientState, lang: string) => {
    const field = client[f];
    if (typeof field === 'object' && field !== null) {
      return (lang === primaryLang ? field.primary : field.secondary) || '';
    }
    return (field as string) || '';
  };

  const setClientField = (f: keyof ClientState, lang: string, v: string) => {
    setClient(prev => {
      const field = prev[f];
      if (typeof field === 'object' && field !== null) {
        return {
          ...prev,
          [f]: { ...field, [lang === primaryLang ? 'primary' : 'secondary']: v }
        };
      }
      return { ...prev, [f]: v };
    });
  };

  // Convert Legacy Snapshot structure to V2 State
  const convertFromSnapshotToV2 = (obj: any) => {
    if (!obj) return client;
    const result = { ...client };
    const fields = ['name', 'mugavari', 'oor', 'maavattam', 'maanilam', 'country'];
    fields.forEach((f: any) => {
       result[f] = {
         primary: obj[`${f}_${primaryLang}`] || obj[f] || '',
         secondary: obj[`${f}_${secondaryLang}`] || obj[`${f}En`] || ''
       };
    });
    result.pin = obj.pin || '';
    result.gstin = obj.gstin || '';
    return result;
  };

  const selectSavedClient = (cli: any) => {
    setClient(convertFromSnapshotToV2(cli));
    setSelectedClientId(cli.id);
    setShowClientSuggestions(false);
    thagaval(`Loaded client: ${cli.name}`, 'info');
  };

  const filteredClients = getClientField('name', primaryLang).trim()
    ? savedClients.filter(cli => {
        const cliName = typeof cli.name === 'object' && cli.name !== null ? cli.name.primary : cli.name;
        const cliNameSec = typeof cli.name === 'object' && cli.name !== null ? cli.name.secondary : (cli.nameEn || cli.peyarEn);
        const q = getClientField('name', primaryLang).trim().toLowerCase();
        return (cliName || '').toLowerCase().includes(q) || (cliNameSec || '').toLowerCase().includes(q);
      })
    : savedClients;

  return (
    <>
      <Box sx={{ py: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3, ml: 1.5 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
            <Box sx={{ width: 24, height: 24, borderRadius: '50%', bgcolor: 'primary.main', color: 'primary.contrastText', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.8rem', fontWeight: 'bold', lineHeight: 1, pt: '1px' }}>1</Box>
            <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600 }}>{t('billedTo')}</Typography>
          </Box>
        </Box>

        <Grid container spacing={2}>
          <Grid size={{ xs: 12, md: 5, lg: 4 }}>
            <Typography variant="caption" color="text.secondary" sx={{ display: 'block', ml: 1.5, mb: 0.5 }}>
              {t('clientName')}{profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'} & ${profile?.secondaryDataLanguage || 'English'})` : ''}
            </Typography>
            <Box sx={{ display: 'flex', gap: 1, flexDirection: 'column', mt: 0 }}>
              <Box sx={{ position: 'relative' }}>
                <TextField fullWidth size="small" label="" margin="none" sx={{ m: 0, '& .MuiInputBase-root': { mt: 0 } }} value={getClientField('name', primaryLang)} inputRef={clientNameRef}
                  onChange={(e) => {
                    setClientField('name', primaryLang, e.target.value);
                    setSelectedClientId(null);
                    setShowClientSuggestions(true);
                  }}
                  onFocus={() => { if (savedClients.length > 0) setShowClientSuggestions(true); }}
                  placeholder={`${t("typeClientName")}${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} autoComplete="off" />

                {showClientSuggestions && (
                  <Paper elevation={4} sx={{ position: 'absolute', top: '100%', left: 0, right: 0, zIndex: 10, mt: 0.5, maxHeight: 300, overflow: 'auto' }} ref={clientSuggestionsRef}>
                    <List disablePadding>
                      {filteredClients.length > 0 ? filteredClients.map(cli => {
                        const cliName = typeof cli.name === 'object' && cli.name !== null ? cli.name.primary : cli.name;
                        const cliNameSec = typeof cli.name === 'object' && cli.name !== null ? cli.name.secondary : (cli.nameEn || cli.peyarEn);
                        
                        return (
                          <ListItem key={cli.id} disablePadding>
                            <ListItemButton onClick={() => selectSavedClient(cli)}>
                              <ListItemText 
                                primary={cliName} 
                                secondary={
                                  profile?.enableBilingual !== false && cliNameSec
                                    ? `${cliNameSec}${cli.oorEn ? ` · ${cli.oorEn}` : ''}`
                                    : [cli.oor || cli.mugavari?.substring(0, 30), typeof cli.maanilam === 'object' && cli.maanilam !== null ? cli.maanilam.primary : cli.maanilam].filter(Boolean).join(' · ')
                                }
                              />
                            </ListItemButton>
                          </ListItem>
                        );
                      }) : (
                        <ListItem>
                          <ListItemText primary={getClientField('name', primaryLang).trim() ? "No saved clients found." : "Type to search clients"} />
                        </ListItem>
                      )}
                      <Divider />
                      <ListItem disablePadding>
                        <ListItemButton 
                          onClick={() => {
                             window.location.href = window.location.pathname + '?view=client-editor';
                          }} 
                          sx={{ color: 'primary.main' }}
                        >
                          <Plus size={18} weight="bold" style={{ marginRight: 8 }} />
                          <ListItemText primary={t('hc_addNewClient') || 'Add New Customer'} primaryTypographyProps={{ fontWeight: 600 }} />
                        </ListItemButton>
                      </ListItem>
                    </List>
                  </Paper>
                )}
              </Box>
              {selectedClientId && (getClientField('mugavari', primaryLang) || getClientField('oor', primaryLang) || client.maanilam.primary || client.gstin || getClientField('name', secondaryLang)) && (
                <ElvanCard sx={{ mt: 2 }} boxSx={{ p: 2 }}>
                  <Typography variant="overline" color="text.secondary" sx={{ fontWeight: 600, display: 'block', mb: 0.5 }}>{t('hc_savedClientDetails')}</Typography>
                  {getClientField('mugavari', primaryLang) && <Typography variant="body2">{getClientField('mugavari', primaryLang)}{getClientField('mugavari', secondaryLang) ? ` / ${getClientField('mugavari', secondaryLang)}` : ''}</Typography>}
                  {(getClientField('oor', primaryLang) || getClientField('maavattam', primaryLang) || client.pin) && <Typography variant="body2">{[
                    getClientField('oor', primaryLang) ? getClientField('oor', primaryLang) + (getClientField('oor', secondaryLang) ? ` / ${getClientField('oor', secondaryLang)}` : '') : '', 
                    getClientField('maavattam', primaryLang) ? getClientField('maavattam', primaryLang) + (getClientField('maavattam', secondaryLang) ? ` / ${getClientField('maavattam', secondaryLang)}` : '') : '', 
                    client.pin
                  ].filter(Boolean).join(' - ')}</Typography>}
                  {client.maanilam.primary && <Typography variant="body2">{getBilingualStateName(client.maanilam.primary, profile)}</Typography>}
                  {client.country.primary && <Typography variant="body2">{getBilingualCountryName(client.country.primary, profile)}</Typography>}
                  {getClientField('name', secondaryLang) && profile?.enableBilingual !== false && <Typography variant="body2" sx={{ mt: 0.5 }}>Name ({profile?.secondaryDataLanguage || 'English'}): <strong>{getClientField('name', secondaryLang)}</strong></Typography>}
                  {client.gstin && <Typography variant="body2" sx={{ mt: 0.5 }}>GSTIN: <strong>{client.gstin}</strong></Typography>}
                </ElvanCard>
              )}
            </Box>
          </Grid>
        </Grid>
      </Box>
    </>
  );
}
