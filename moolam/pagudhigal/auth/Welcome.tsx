import React, { useState, useEffect } from 'react';
import { AuthLayout, AuthButton } from './AuthComponents';
import { Database, CheckCircle, GlobeHemisphereWest, FileText } from '@phosphor-icons/react';
import { List, ListItem, ListItemButton, ListItemText, ListItemIcon, Divider } from '@mui/material';
import { useLanguage } from '../../mozhi/LanguageContext';

const GREETINGS = ["வணக்கம்!", "Hello!", "നമസ്കാരം!"];

export default function Welcome({ onContinue, mode = 'post-login' }: { onContinue: () => void, mode?: 'pre-login' | 'post-login' }) {
    const { t, language, setLanguage } = useLanguage();
    
    const [phase, setPhase] = useState<'greeting' | 'language' | 'billingLanguage' | 'setup'>('greeting');
    const [greetingIndex, setGreetingIndex] = useState(0);
    const [greetingOpacity, setGreetingOpacity] = useState(0);
    const [showLanguage, setShowLanguage] = useState(false);
    const [showSetup, setShowSetup] = useState(false);
    const [billingLanguage, setBillingLanguage] = useState<'Tamil' | 'English'>('Tamil');
    const [showBillingLanguage, setShowBillingLanguage] = useState(false);

    useEffect(() => {
        // Default to Tamil during post-login setup if user hasn't explicitly set a language yet
        if (mode === 'post-login' && !localStorage.getItem('elvanniril_language')) {
            setLanguage('ta');
        }
    }, [mode]);

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
                    if (mode === 'pre-login') {
                        setPhase('setup');
                    } else {
                        setPhase('language');
                    }
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
        } else if (phase === 'billingLanguage') {
            setTimeout(() => setShowBillingLanguage(true), 100);
        } else if (phase === 'setup') {
            setTimeout(() => setShowSetup(true), 100);
        }
    }, [phase]);

    const handleContinue = () => {
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
                                fontSize: 'clamp(24px, 7vw, 32px)',
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
                                bgcolor: 'var(--auth-input-bg)',
                                borderRadius: '16px',
                                mb: 4,
                                overflow: 'hidden',
                                p: 0
                            }}>
                                <ListItem disablePadding>
                                    <ListItemButton 
                                        onClick={() => setLanguage('ta')} 
                                        sx={{ 
                                            py: 2, 
                                            px: 3,
                                            bgcolor: 'transparent',
                                            '&:hover': { bgcolor: 'transparent' }
                                        }}
                                        disableRipple
                                    >
                                        <ListItemText 
                                            primary={
                                                <span style={{ 
                                                    fontSize: '18px', 
                                                    fontWeight: language === 'ta' ? 600 : 500, 
                                                    color: 'var(--auth-text)' 
                                                }}>
                                                    தமிழ்
                                                </span>
                                            } 
                                        />
                                        {language === 'ta' && (
                                            <ListItemIcon sx={{ minWidth: 'auto' }}>
                                                <CheckCircle size={24} weight="fill" color="var(--auth-text)" />
                                            </ListItemIcon>
                                        )}
                                    </ListItemButton>
                                </ListItem>
                                <Divider sx={{ mx: 3, borderColor: 'var(--auth-divider)' }} />
                                <ListItem disablePadding>
                                    <ListItemButton 
                                        onClick={() => setLanguage('en')} 
                                        sx={{ 
                                            py: 2, 
                                            px: 3,
                                            bgcolor: 'transparent',
                                            '&:hover': { bgcolor: 'transparent' }
                                        }}
                                        disableRipple
                                    >
                                        <ListItemText 
                                            primary={
                                                <span style={{ 
                                                    fontSize: '18px', 
                                                    fontWeight: language === 'en' ? 600 : 500, 
                                                    color: 'var(--auth-text)' 
                                                }}>
                                                    English
                                                </span>
                                            } 
                                        />
                                        {language === 'en' && (
                                            <ListItemIcon sx={{ minWidth: 'auto' }}>
                                                <CheckCircle size={24} weight="fill" color="var(--auth-text)" />
                                            </ListItemIcon>
                                        )}
                                    </ListItemButton>
                                </ListItem>
                            </List>

                            <div style={{ width: '100%', maxWidth: '320px' }}>
                                <AuthButton onClick={() => setPhase('billingLanguage')}>
                                    Continue
                                </AuthButton>
                            </div>
                        </div>
                    </div>
                )}

                {/* PHASE 2.5: BILLING LANGUAGE SELECTION SCREEN */}
                {phase === 'billingLanguage' && (
                    <div style={{
                        display: 'flex',
                        flexDirection: 'column',
                        height: '100%',
                        width: '100%',
                        justifyContent: 'space-between',
                        opacity: showBillingLanguage ? 1 : 0,
                        transform: showBillingLanguage ? 'translateY(0)' : 'translateY(20px)',
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
                            <FileText size={80} weight="duotone" color="var(--auth-text)" />
                        </div>

                        {/* TEXT SECTION */}
                        <div style={{
                            textAlign: 'center',
                            display: 'flex',
                            flexDirection: 'column',
                            gap: '12px'
                        }}>
                            <h1 style={{
                                fontSize: 'clamp(24px, 7vw, 32px)',
                                fontWeight: '800',
                                color: 'var(--auth-text)',
                                margin: 0,
                                letterSpacing: '-0.5px'
                            }}>
                                {language === 'ta' ? 'பில் முதன்மை மொழி' : 'Select Primary Billing Language'}
                            </h1>
                            <p style={{
                                fontSize: '18px',
                                color: 'var(--auth-text-secondary)',
                                margin: 0,
                                fontWeight: '500'
                            }}>
                                {language === 'ta' ? 'பில்களுக்கு எந்த மொழியைப் பயன்படுத்த விரும்புகிறீர்கள்?' : 'Which language would you like to use for your bills?'}
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
                                bgcolor: 'var(--auth-input-bg)',
                                borderRadius: '16px',
                                mb: 4,
                                overflow: 'hidden',
                                p: 0
                            }}>
                                <ListItem disablePadding>
                                    <ListItemButton 
                                        onClick={() => setBillingLanguage('Tamil')} 
                                        sx={{ 
                                            py: 2, 
                                            px: 3,
                                            bgcolor: 'transparent',
                                            '&:hover': { bgcolor: 'transparent' }
                                        }}
                                        disableRipple
                                    >
                                        <ListItemText 
                                            primary={
                                                <span style={{ 
                                                    fontSize: '18px', 
                                                    fontWeight: billingLanguage === 'Tamil' ? 600 : 500, 
                                                    color: 'var(--auth-text)' 
                                                }}>
                                                    தமிழ்
                                                </span>
                                            } 
                                        />
                                        {billingLanguage === 'Tamil' && (
                                            <ListItemIcon sx={{ minWidth: 'auto' }}>
                                                <CheckCircle size={24} weight="fill" color="var(--auth-text)" />
                                            </ListItemIcon>
                                        )}
                                    </ListItemButton>
                                </ListItem>
                                <Divider sx={{ mx: 3, borderColor: 'var(--auth-divider)' }} />
                                <ListItem disablePadding>
                                    <ListItemButton 
                                        onClick={() => setBillingLanguage('English')} 
                                        sx={{ 
                                            py: 2, 
                                            px: 3,
                                            bgcolor: 'transparent',
                                            '&:hover': { bgcolor: 'transparent' }
                                        }}
                                        disableRipple
                                    >
                                        <ListItemText 
                                            primary={
                                                <span style={{ 
                                                    fontSize: '18px', 
                                                    fontWeight: billingLanguage === 'English' ? 600 : 500, 
                                                    color: 'var(--auth-text)' 
                                                }}>
                                                    English
                                                </span>
                                            } 
                                        />
                                        {billingLanguage === 'English' && (
                                            <ListItemIcon sx={{ minWidth: 'auto' }}>
                                                <CheckCircle size={24} weight="fill" color="var(--auth-text)" />
                                            </ListItemIcon>
                                        )}
                                    </ListItemButton>
                                </ListItem>
                            </List>

                            <div style={{ width: '100%', maxWidth: '320px' }}>
                                <AuthButton onClick={() => {
                                    localStorage.setItem('elvanniril_setup_billingLang', billingLanguage);
                                    if (mode === 'post-login') {
                                        setPhase('setup');
                                    } else {
                                        onContinue();
                                    }
                                }}>
                                    Continue
                                </AuthButton>
                            </div>
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
                                background: 'var(--auth-accent)',
                                borderRadius: '28px',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                boxShadow: '0 20px 40px var(--auth-glow)'
                            }}>
                                <Database size={48} weight="duotone" color="var(--auth-bg)" />
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
                                Welcome to Niril
                            </h1>
                            <p style={{
                                fontSize: '18px',
                                color: 'var(--auth-text-secondary)',
                                margin: 0,
                                fontWeight: '500'
                            }}>
                                Your Billing & GST, Sorted.
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
                                Tap "Get Started" to continue with Niril.
                            </p>

                            <AuthButton onClick={handleContinue}>
                                Get Started
                            </AuthButton>
                        </div>
                    </div>
                )}
            </div>
        </AuthLayout>
    );
}
