import React, { useState, useEffect } from 'react';
import { AuthLayout, AuthButton } from './AuthComponents';
import { Database } from '@phosphor-icons/react';
import { useLanguage } from '../../mozhi/LanguageContext';

export default function Welcome({ onContinue }: { onContinue: () => void }) {
    const { t } = useLanguage();
    const [showLogo, setShowLogo] = useState(false);
    const [showText, setShowText] = useState(false);
    const [showButton, setShowButton] = useState(false);

    useEffect(() => {
        // Staggered Animation
        setTimeout(() => setShowLogo(true), 300);
        setTimeout(() => setShowText(true), 800);
        setTimeout(() => setShowButton(true), 1200);

        if (localStorage.getItem('elvanniril_theme') === 'dark') {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    }, []);

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
                justifyContent: 'space-between',
                padding: '40px 24px',
                maxWidth: '480px',
                margin: '0 auto',
                width: '100%'
            }}>
                <div style={{ flex: 1 }} />
                
                {/* LOGO SECTION */}
                <div style={{
                    opacity: showLogo ? 1 : 0,
                    transform: showLogo ? 'scale(1)' : 'scale(0.8)',
                    transition: 'all 0.8s cubic-bezier(0.34, 1.56, 0.64, 1)',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: '24px',
                    marginBottom: '40px'
                }}>
                    <div style={{
                        width: '96px',
                        height: '96px',
                        background: 'linear-gradient(135deg, var(--mac-blue), #5E5CE6)',
                        borderRadius: '28px',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        boxShadow: '0 20px 40px rgba(10, 132, 255, 0.3)'
                    }}>
                        <Database size={48} weight="duotone" color="white" />
                    </div>
                </div>

                {/* TEXT SECTION */}
                <div style={{
                    opacity: showText ? 1 : 0,
                    transform: showText ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.6s ease-out',
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
                    opacity: showButton ? 1 : 0,
                    transform: showButton ? 'translateY(0)' : 'translateY(40px)',
                    transition: 'all 0.6s ease-out',
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
                        {t('welcomeAgreeText') !== 'welcomeAgreeText' ? t('welcomeAgreeText') : 'Tap "Agree and Continue" to get started with Niril.'}
                    </p>

                    <AuthButton
                        onClick={handleContinue}
                    >
                        {t('agreeAndContinueBtn') !== 'agreeAndContinueBtn' ? t('agreeAndContinueBtn') : 'Agree and Continue'}
                    </AuthButton>
                </div>

            </div>

            <style>{`
                @keyframes float {
                    0% { transform: translateY(0px); }
                    100% { transform: translateY(-12px); }
                }
                @keyframes pulse {
                    0% { transform: scale(1); opacity: 0.5; }
                    50% { transform: scale(1.1); opacity: 0.8; }
                    100% { transform: scale(1); opacity: 0.5; }
                }
            `}</style>
        </AuthLayout>
    );
}
