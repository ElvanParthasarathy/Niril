import React, { useState } from 'react';
import { Box, Typography, Select, MenuItem } from '@mui/material';
import { Translate, Palette, CheckCircle, Circle } from '@phosphor-icons/react';
import { SettingsPillContainer, SettingsPillRow } from '../ElvanSettingsSection';
import { useLanguage } from '../../mozhi/LanguageContext';

export default function AppPreferences({ thagaval, darkMode, setDarkMode }: { thagaval: any, darkMode?: boolean, setDarkMode?: (v: boolean) => void }) {
  const { language, setLanguage, t } = useLanguage();
  const [editingSection, setEditingSection] = useState<string | null>(null);
  const [localLanguage, setLocalLanguage] = useState(language);

  const onPillSave = () => {
    setLanguage(localLanguage);
    thagaval(localLanguage === 'ta' ? t('languageChangedTa') || 'Language changed' : t('languageChangedEn') || 'Language changed', 'success');
    setEditingSection(null);
  };

  const onPillCancel = () => {
    setLocalLanguage(language);
    setEditingSection(null);
  };

  const handleThemeChange = (newTheme: 'light' | 'dark') => {
    if (!setDarkMode) return;
    setDarkMode(newTheme === 'dark');
    localStorage.setItem('elvanniril_theme', newTheme);
  };

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3, width: '100%', pb: 6 }}>
      
      <SettingsPillContainer 
        title={t('appearance') || 'Appearance'} 
        icon={<Palette size={20} weight="fill" />} 
        iconColor="orange"
      >
        <Box sx={{ display: 'flex', justifyContent: 'space-evenly', p: 3 }}>
            
            {/* Light Mode Option */}
            <Box 
              onClick={() => handleThemeChange("light")}
              sx={{ 
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
                cursor: 'pointer', userSelect: 'none'
              }}
            >
              <Box sx={{
                width: 110, height: 85, borderRadius: '24px',
                bgcolor: '#f5f5f5', border: '1px solid', borderColor: !darkMode ? '#555' : 'divider',
                display: 'flex', flexDirection: 'column', gap: 1.2, p: 2,
                transition: 'all 0.2s',
                transform: !darkMode ? 'scale(1.02)' : 'scale(1)'
              }}>
                <Box sx={{ width: 32, height: 8, borderRadius: 4, bgcolor: '#000', opacity: 0.7 }} />
                <Box sx={{ width: '100%', height: 6, borderRadius: 4, bgcolor: '#cfcfcf' }} />
                <Box sx={{ width: '60%', height: 6, borderRadius: 4, bgcolor: '#cfcfcf' }} />
              </Box>
              <Typography variant="body2" sx={{ 
                fontWeight: !darkMode ? 600 : 500, 
                color: !darkMode ? 'text.primary' : 'text.secondary',
                transition: 'color 0.2s',
                mt: 0.5
              }}>
                {t('lightMode') || 'Light'}
              </Typography>
              <Box sx={{ mt: -1 }}>
                {!darkMode ? <CheckCircle weight="fill" size={24} color="#000" /> : <Circle weight="regular" size={24} color="#888" />}
              </Box>
            </Box>

            {/* Dark Mode Option */}
            <Box 
              onClick={() => handleThemeChange("dark")}
              sx={{ 
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
                cursor: 'pointer', userSelect: 'none'
              }}
            >
              <Box sx={{
                width: 110, height: 85, borderRadius: '24px',
                bgcolor: '#1e1e1e', border: '1px solid', borderColor: darkMode ? '#888' : 'divider',
                display: 'flex', flexDirection: 'column', gap: 1.2, p: 2,
                transition: 'all 0.2s',
                transform: darkMode ? 'scale(1.02)' : 'scale(1)'
              }}>
                <Box sx={{ width: 32, height: 8, borderRadius: 4, bgcolor: '#fff', opacity: 0.8 }} />
                <Box sx={{ width: '100%', height: 6, borderRadius: 4, bgcolor: '#444' }} />
                <Box sx={{ width: '60%', height: 6, borderRadius: 4, bgcolor: '#444' }} />
              </Box>
              <Typography variant="body2" sx={{ 
                fontWeight: darkMode ? 600 : 500, 
                color: darkMode ? 'text.primary' : 'text.secondary',
                transition: 'color 0.2s',
                mt: 0.5
              }}>
                {t('darkMode') || 'Dark'}
              </Typography>
              <Box sx={{ mt: -1 }}>
                {darkMode ? <CheckCircle weight="fill" size={24} color="#fff" /> : <Circle weight="regular" size={24} color="#888" />}
              </Box>
            </Box>

        </Box>
      </SettingsPillContainer>

      <SettingsPillContainer 
        title={t('appPreferences') || 'App Preferences'} 
        icon={<Translate size={20} weight="fill" />} 
        iconColor="blue"
      >
        <SettingsPillRow
          label={t('appLanguage') || 'App Language'}
          value={language === 'ta' ? 'தமிழ்' : 'English'}
          isEditing={editingSection === 'language'}
          onEdit={() => {
            setLocalLanguage(language);
            setEditingSection('language');
          }}
          onCancel={onPillCancel}
          onSave={onPillSave}
        >
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5 }}>
            <Typography sx={{ fontSize: '13px', color: 'var(--mac-text-secondary, #aaaaaa)', fontWeight: 500 }}>
              {t('appLanguage') || 'App Language'}
            </Typography>
            <Select
              fullWidth
              value={localLanguage}
              onChange={(e) => setLocalLanguage(e.target.value as any)}
              size="small"
              sx={{ 
                bgcolor: 'action.hover',
                borderRadius: '100px',
                '& .MuiOutlinedInput-notchedOutline': { border: 'none' },
                '&:hover .MuiOutlinedInput-notchedOutline': { border: 'none' },
                '&.Mui-focused .MuiOutlinedInput-notchedOutline': { border: 'none' },
                '& .MuiSelect-select': { py: 1.5, px: 2 }
              }}
              MenuProps={{ disableScrollLock: true }}
            >
              <MenuItem value="ta">தமிழ்</MenuItem>
              <MenuItem value="en">English</MenuItem>
            </Select>
          </Box>
        </SettingsPillRow>
      </SettingsPillContainer>
    </Box>
  );
}
