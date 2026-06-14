import React, { useState, useEffect } from 'react';
import { AuthLayout, AuthButton } from './AuthComponents';
import { Database, CheckCircle } from '@phosphor-icons/react';
import { useLanguage } from '../../mozhi/LanguageContext';

const GREETINGS = ["வணக்கம்!", "Hello!", "നമസ്കാരം!"];

export default function Welcome({ onContinue }: { onContinue: () => void }) {
    const { t, language, setLanguage } = useLanguage();
    
    // Phases: 'greeting' -> 'setup'
    const [phase, setPhase] = useState<'greeting' | 'setup'>('greeting');
    
    // Greeting Animation State
    const [greetingIndex, setGreetingIndex] = useState(0);
    const [greetingOpacity, setGreetingOpacity] = useState(0);
    
    // Setup UI Animation State
    const [showSetup, setShowSetup] = useState(false);

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
                    setPhase('setup');
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
        if (phase === 'setup') {
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

                {/* PHASE 2: SETUP SCREEN */}
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

                        {/* LANGUAGE & BUTTON SECTION */}
                        <div style={{
                            width: '100%',
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                            paddingBottom: '40px'
                        }}>
                            
                            {/* IOS-STYLE LANGUAGE SELECTOR */}
                            <div style={{
                                display: 'flex',
                                flexDirection: 'column',
                                gap: '12px',
                                width: '100%',
                                maxWidth: '300px',
                                marginBottom: '32px'
                            }}>
                                <div 
                                    onClick={() => setLanguage('ta')}
                                    style={{
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'space-between',
                                        padding: '16px 20px',
                                        background: language === 'ta' ? 'var(--auth-text)' : 'var(--auth-surface)',
                                        color: language === 'ta' ? 'var(--auth-surface)' : 'var(--auth-text)',
                                        borderRadius: '16px',
                                        cursor: 'pointer',
                                        border: `2px solid ${language === 'ta' ? 'var(--auth-text)' : 'var(--auth-divider)'}`,
                                        transition: 'all 0.2s ease',
                                        boxShadow: language === 'ta' ? '0 8px 16px var(--auth-glow)' : '0 2px 8px var(--auth-glow)',
                                        fontWeight: language === 'ta' ? '700' : '500'
                                    }}
                                >
                                    <span style={{ fontSize: '18px' }}>தமிழ்</span>
                                    {language === 'ta' && <CheckCircle size={24} weight="fill" />}
                                </div>
                                <div 
                                    onClick={() => setLanguage('en')}
                                    style={{
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'space-between',
                                        padding: '16px 20px',
                                        background: language === 'en' ? 'var(--auth-text)' : 'var(--auth-surface)',
                                        color: language === 'en' ? 'var(--auth-surface)' : 'var(--auth-text)',
                                        borderRadius: '16px',
                                        cursor: 'pointer',
                                        border: `2px solid ${language === 'en' ? 'var(--auth-text)' : 'var(--auth-divider)'}`,
                                        transition: 'all 0.2s ease',
                                        boxShadow: language === 'en' ? '0 8px 16px var(--auth-glow)' : '0 2px 8px var(--auth-glow)',
                                        fontWeight: language === 'en' ? '700' : '500'
                                    }}
                                >
                                    <span style={{ fontSize: '18px' }}>English</span>
                                    {language === 'en' && <CheckCircle size={24} weight="fill" />}
                                </div>
                            </div>

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
