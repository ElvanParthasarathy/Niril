import React, { useState, useEffect } from 'react';
import { AuthLayout, AuthButton } from './AuthComponents';
import { Database, CheckCircle, GlobeHemisphereWest } from '@phosphor-icons/react';
import { List, ListItem, ListItemButton, ListItemText, ListItemIcon } from '@mui/material';
import { useLanguage } from '../../mozhi/LanguageContext';

const GREETINGS = ["வணக்கம்!", "Hello!", "നമസ്കാരം!"];

export default function Welcome({ onContinue }: { onContinue: () => void }) {
    const { t, language, setLanguage } = useLanguage();
    
    // Phases: 'greeting' -> 'language' -> 'setup'
    const [phase, setPhase] = useState<'greeting' | 'language' | 'setup'>('greeting');
    
    // Greeting Animation State
    const [greetingIndex, setGreetingIndex] = useState(0);
    const [greetingOpacity, setGreetingOpacity] = useState(0);
    
    // Setup UI Animation State
    const [showLanguage, setShowLanguage] = useState(false);
    const [showSetup, setShowSetup] = useState(false);

    useEffect(() => {
        // Default to Tamil during setup if user hasn't explicitly set a language yet
        if (!localStorage.getItem('elvanniril_language')) {
            setLanguage('ta');
        }
    }, []);

    useEffect(() => {
        if (localStorage.getItem('elvanniril_theme') === 'dark') {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }

        let loopCount = 0;
        let isMounted = true;

        const runGreetingLoop = async () => {
            while (isMounted && phase === 'greeting') {
                // Fade in
                setGreetingOpacity(1);
                await new Promise(r => setTimeout(r, 1200));
                
                // Fade out
                setGreetingOpacity(0);
                await new Promise(r => setTimeout(r, 800));
                
                if (!isMounted) break;

                // Move to next greeting or switch to setup phase
                loopCount++;
                if (loopCount >= GREETINGS.length) {
                    setPhase('language');
                    break;
                } else {
                    setGreetingIndex((prev) => prev + 1);
                }
            }
        };

        if (phase === 'greeting') {
            runGreetingLoop();
        }

        return () => { isMounted = false; };
    }, [phase]);

    useEffect(() => {
        if (phase === 'language') {
            setTimeout(() => setShowLanguage(true), 100);
        } else if (phase === 'setup') {
            setTimeout(() => setShowSetup(true), 100);
        }
    }, [phase]);

    const handleContinue = () => {
        localStorage.setItem('elvanniril_welcomed', 'true');
        onContinue();
    };

    return (
        <AuthLayout hideLogo>
            <div style={{
                display: 'flex',
                flexDirection: 'column',
                height: '100%',
                justifyContent: 'center', // Center content naturally
                alignItems: 'center',
                padding: '40px 24px',
                maxWidth: '480px',
                margin: '0 auto',
                width: '100%',
                position: 'relative'
            }}>
                
                {/* PHASE 1: GREETING ANIMATION */}
                {phase === 'greeting' && (
                    <div style={{
                        opacity: greetingOpacity,
                        transition: 'opacity 0.8s ease-in-out',
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        justifyContent: 'center',
                        flex: 1
                    }}>
                        <h1 style={{
                            fontSize: '48px',
                            fontWeight: '300',
                            color: 'var(--auth-text)',
                            margin: 0,
                            letterSpacing: '-1px'
                        }}>
                            {GREETINGS[greetingIndex]}
                        </h1>
                    </div>
                )}

                {/* PHASE 2: LANGUAGE SELECTION SCREEN */}
                {phase === 'language' && (
                    <div style={{
                        display: 'flex',
                        flexDirection: 'column',
                        height: '100%',
                        width: '100%',
                        justifyContent: 'space-between',
                        opacity: showLanguage ? 1 : 0,
                        transform: showLanguage ? 'translateY(0)' : 'translateY(20px)',
                        transition: 'all 0.8s cubic-bezier(0.34, 1.56, 0.64, 1)',
                    }}>
                        <div style={{ flex: 1 }} />
                        
                        {/* ICON SECTION */}
                        <div style={{
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                            marginBottom: '40px'
                        }}>
                            <GlobeHemisphereWest size={80} weight="regular" color="var(--auth-text)" />
                        </div>

                        {/* TEXT SECTION */}
                        <div style={{
                            textAlign: 'center',
                            display: 'flex',
                            flexDirection: 'column',
                            gap: '12px'
                        }}>
                            <h1 style={{
                                fontSize: '32px',
                                fontWeight: '800',
                                color: 'var(--auth-text)',
                                margin: 0,
                                letterSpacing: '-0.5px'
                            }}>
                                {t('selectLanguageTitle') !== 'selectLanguageTitle' ? t('selectLanguageTitle') : 'Select Language'}
                            </h1>
                            <p style={{
                                fontSize: '18px',
                                color: 'var(--auth-text-secondary)',
                                margin: 0,
                                fontWeight: '500'
                            }}>
                                {t('selectLanguageSubtitle') !== 'selectLanguageSubtitle' ? t('selectLanguageSubtitle') : 'Choose your preferred language'}
                            </p>
                        </div>

                        <div style={{ flex: 1 }} />

                        {/* LANGUAGE OPTIONS & BUTTON SECTION */}
                        <div style={{
                            width: '100%',
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                            paddingBottom: '40px'
                        }}>
                            
                            {/* MUI LANGUAGE SELECTOR */}
                            <List sx={{
                                width: '100%',
                                maxWidth: '320px',
                                bgcolor: 'var(--auth-surface)',
                                borderRadius: '16px',
                                border: '1px solid var(--auth-divider)',
                                mb: 4,
                                boxShadow: '0 4px 12px var(--auth-glow)',
                                overflow: 'hidden',
                                p: 0
                            }}>
                                <ListItem disablePadding divider>
                                    <ListItemButton 
                                        onClick={() => setLanguage('ta')} 
                                        sx={{ 
                                            py: 2, 
                                            px: 3,
                                            bgcolor: language === 'ta' ? 'var(--auth-glow)' : 'transparent',
                                            '&:hover': { bgcolor: 'var(--auth-glow)' }
                                        }}
                                    >
                                        <ListItemText 
                                            primary="தமிழ்" 
                                            primaryTypographyProps={{ 
                                                fontSize: '18px', 
                                                fontWeight: language === 'ta' ? 600 : 500, 
                                                color: 'var(--auth-text)' 
                                            }} 
                                        />
                                        {language === 'ta' && (
                                            <ListItemIcon sx={{ minWidth: 'auto' }}>
                                                <CheckCircle size={24} weight="fill" color="var(--auth-text)" />
                                            </ListItemIcon>
                                        )}
                                    </ListItemButton>
                                </ListItem>
                                <ListItem disablePadding>
                                    <ListItemButton 
                                        onClick={() => setLanguage('en')} 
                                        sx={{ 
                                            py: 2, 
                                            px: 3,
                                            bgcolor: language === 'en' ? 'var(--auth-glow)' : 'transparent',
                                            '&:hover': { bgcolor: 'var(--auth-glow)' }
                                        }}
                                    >
                                        <ListItemText 
                                            primary="English" 
                                            primaryTypographyProps={{ 
                                                fontSize: '18px', 
                                                fontWeight: language === 'en' ? 600 : 500, 
                                                color: 'var(--auth-text)' 
                                            }} 
                                        />
                                        {language === 'en' && (
                                            <ListItemIcon sx={{ minWidth: 'auto' }}>
                                                <CheckCircle size={24} weight="fill" color="var(--auth-text)" />
                                            </ListItemIcon>
                                        )}
                                    </ListItemButton>
                                </ListItem>
                            </List>

                            <AuthButton onClick={() => setPhase('setup')}>
                                Continue
                            </AuthButton>
                        </div>
                    </div>
                )}

                {/* PHASE 3: SETUP SCREEN */}
                {phase === 'setup' && (
                    <div style={{
                        display: 'flex',
                        flexDirection: 'column',
                        height: '100%',
                        width: '100%',
                        justifyContent: 'space-between',
                        opacity: showSetup ? 1 : 0,
                        transform: showSetup ? 'translateY(0)' : 'translateY(20px)',
                        transition: 'all 0.8s cubic-bezier(0.34, 1.56, 0.64, 1)',
                    }}>
                        <div style={{ flex: 1 }} />
                        
                        {/* LOGO SECTION */}
                        <div style={{
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                            gap: '24px',
                            marginBottom: '40px'
                        }}>
                            <div style={{
                                width: '96px',
                                height: '96px',
                                background: 'var(--auth-surface)',
                                borderRadius: '28px',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                boxShadow: '0 20px 40px var(--auth-glow)',
                                border: '1px solid var(--auth-divider)'
                            }}>
                                <Database size={48} weight="duotone" color="var(--auth-accent)" />
                            </div>
                        </div>

                        {/* TEXT SECTION */}
                        <div style={{
                            textAlign: 'center',
                            display: 'flex',
                            flexDirection: 'column',
                            gap: '12px'
                        }}>
                            <h1 style={{
                                fontSize: '32px',
                                fontWeight: '800',
                                color: 'var(--auth-text)',
                                margin: 0,
                                letterSpacing: '-0.5px'
                            }}>
                                {t('welcomeTitle') !== 'welcomeTitle' ? t('welcomeTitle') : 'Welcome to Niril'}
                            </h1>
                            <p style={{
                                fontSize: '18px',
                                color: 'var(--auth-text-secondary)',
                                margin: 0,
                                fontWeight: '500'
                            }}>
                                {t('welcomeSubtitle') !== 'welcomeSubtitle' ? t('welcomeSubtitle') : 'Your Billing & GST, Sorted.'}
                            </p>
                        </div>

                        <div style={{ flex: 1 }} />

                        {/* BUTTON SECTION */}
                        <div style={{
                            width: '100%',
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                            paddingBottom: '40px'
                        }}>
                            <p style={{
                                fontSize: '12px',
                                color: 'var(--auth-text-muted)',
                                marginBottom: '24px',
                                textAlign: 'center',
                                maxWidth: '280px',
                                lineHeight: '1.5'
                            }}>
                                {t('welcomeAgreeText') !== 'welcomeAgreeText' ? t('welcomeAgreeText') : 'Tap "Get Started" to continue with Niril.'}
                            </p>

                            <AuthButton onClick={handleContinue}>
                                {t('agreeAndContinueBtn') !== 'agreeAndContinueBtn' ? t('agreeAndContinueBtn') : 'Get Started'}
                            </AuthButton>
                        </div>
                    </div>
                )}
            </div>
        </AuthLayout>
    );
}
