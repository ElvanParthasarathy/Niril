import { Box, Typography, Card, CardActionArea, CardContent, useTheme, Fade, Zoom } from '@mui/material';
import { FileText, Truck } from '@phosphor-icons/react';
import { useState, useEffect } from 'react';
import { useLanguage } from '../mozhi/LanguageContext';

export default function ModeSelector({ onSelect, currentMode }) {
  const { language } = useLanguage();
  const theme = useTheme();
  const darkMode = theme.palette.mode === 'dark';
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const handleSelect = (mode) => {
    setMounted(false);
    setTimeout(() => {
      onSelect(mode);
    }, 400); // Wait for fade out animation
  };

  return (
    <Fade in={mounted} timeout={800}>
      <Box
        sx={{
          position: 'fixed',
          top: 0,
          left: 0,
          width: '100vw',
          height: '100vh',
          bgcolor: darkMode ? '#0a0a0a' : '#f0f2f5',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 99999, // Ensure it covers everything
        }}
      >
        <Zoom in={mounted} timeout={1000}>
          <Box sx={{ textAlign: 'center', mb: 8 }}>
            <Typography
              variant="h3"
              sx={{
                fontWeight: 800,
                color: darkMode ? '#ffffff' : '#111827',
                letterSpacing: '-0.02em',
                mb: 1,
              }}
            >
              Who's working today?
            </Typography>
            <Typography
              variant="h6"
              sx={{
                fontWeight: 500,
                color: darkMode ? '#9ca3af' : '#6b7280',
              }}
            >
              Select your operating mode
            </Typography>
          </Box>
        </Zoom>

        <Box sx={{ display: 'flex', gap: { xs: 4, md: 8 }, flexWrap: 'wrap', justifyContent: 'center' }}>
          {/* GST Mode Card */}
          <Zoom in={mounted} timeout={1200}>
            <Card
              elevation={0}
              sx={{
                width: 240,
                height: 280,
                bgcolor: 'transparent',
                borderRadius: 4,
                overflow: 'visible',
              }}
            >
              <CardActionArea
                onClick={() => handleSelect('GST')}
                sx={{
                  height: '100%',
                  borderRadius: 4,
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                  '&:hover': {
                    transform: 'scale(1.05) translateY(-8px)',
                    '& .icon-box': {
                      boxShadow: darkMode 
                        ? '0 20px 40px rgba(99, 102, 241, 0.3)' 
                        : '0 20px 40px rgba(99, 102, 241, 0.2)',
                      border: '2px solid #6366f1',
                    },
                    '& .card-text': {
                      color: darkMode ? '#ffffff' : '#111827',
                    }
                  },
                }}
              >
                <Box
                  className="icon-box"
                  sx={{
                    width: 140,
                    height: 140,
                    borderRadius: '50%',
                    bgcolor: darkMode ? '#1f2937' : '#ffffff',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    mb: 3,
                    border: `2px solid ${darkMode ? '#374151' : '#e5e7eb'}`,
                    transition: 'all 0.3s ease',
                    boxShadow: darkMode ? '0 8px 16px rgba(0,0,0,0.4)' : '0 8px 16px rgba(0,0,0,0.05)',
                  }}
                >
                  <FileText size={64} weight="duotone" color="#6366f1" />
                </Box>
                <CardContent sx={{ p: 0, textAlign: 'center' }}>
                  <Typography
                    className="card-text"
                    variant="h5"
                    sx={{
                      fontWeight: 700,
                      color: darkMode ? '#9ca3af' : '#4b5563',
                      transition: 'color 0.3s ease',
                    }}
                  >
                    {language === 'ta' ? 'Niril Pattu' : 'Niril Silk'}
                  </Typography>
                </CardContent>
              </CardActionArea>
            </Card>
          </Zoom>

          {/* Coolie Mode Card */}
          <Zoom in={mounted} timeout={1400}>
            <Card
              elevation={0}
              sx={{
                width: 240,
                height: 280,
                bgcolor: 'transparent',
                borderRadius: 4,
                overflow: 'visible',
              }}
            >
              <CardActionArea
                onClick={() => handleSelect('COOLIE')}
                sx={{
                  height: '100%',
                  borderRadius: 4,
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                  '&:hover': {
                    transform: 'scale(1.05) translateY(-8px)',
                    '& .icon-box': {
                      boxShadow: darkMode 
                        ? '0 20px 40px rgba(16, 185, 129, 0.3)' 
                        : '0 20px 40px rgba(16, 185, 129, 0.2)',
                      border: '2px solid #10b981',
                    },
                    '& .card-text': {
                      color: darkMode ? '#ffffff' : '#111827',
                    }
                  },
                }}
              >
                <Box
                  className="icon-box"
                  sx={{
                    width: 140,
                    height: 140,
                    borderRadius: '50%',
                    bgcolor: darkMode ? '#1f2937' : '#ffffff',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    mb: 3,
                    border: `2px solid ${darkMode ? '#374151' : '#e5e7eb'}`,
                    transition: 'all 0.3s ease',
                    boxShadow: darkMode ? '0 8px 16px rgba(0,0,0,0.4)' : '0 8px 16px rgba(0,0,0,0.05)',
                  }}
                >
                  <Truck size={64} weight="duotone" color="#10b981" />
                </Box>
                <CardContent sx={{ p: 0, textAlign: 'center' }}>
                  <Typography
                    className="card-text"
                    variant="h5"
                    sx={{
                      fontWeight: 700,
                      color: darkMode ? '#9ca3af' : '#4b5563',
                      transition: 'color 0.3s ease',
                    }}
                  >
                    Niril Coolie
                  </Typography>
                </CardContent>
              </CardActionArea>
            </Card>
          </Zoom>
        </Box>
      </Box>
    </Fade>
  );
}
