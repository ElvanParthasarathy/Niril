import React, { useState, useEffect } from 'react';
import { AuthLayout, AuthButton } from './AuthComponents';
import { Database } from '@phosphor-icons/react';

export default function Welcome({ onContinue }: { onContinue: () => void }) {
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
        <AuthLayout>
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', width: '100%' }}>

                {/* LOGO SECTION */}
                <div
                    className={`animate-enter`}
                    style={{
                        marginTop: '60px',
                        opacity: showLogo ? 1 : 0,
                        transform: showLogo ? 'scale(1)' : 'scale(0.8)',
                        transition: 'all 0.8s cubic-bezier(0.34, 1.56, 0.64, 1)'
                    }}
                >
                    <div style={{
                        position: 'relative',
                        width: '180px',
                        height: '180px',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        animation: 'float 3s ease-in-out infinite alternate' // Floating Animation
                    }}>
                        {/* Glow Effect */}
                        <div style={{
                            position: 'absolute',
                            width: '100%',
                            height: '100%',
                            borderRadius: '50%',
                            background: 'rgba(0, 122, 255, 0.15)',
                            filter: 'blur(20px)',
                            zIndex: -1,
                            animation: 'pulse 2s ease-in-out infinite'
                        }} />

                        <div className="auth-logo-themed" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                            <Database size={80} weight="duotone" color="var(--auth-accent)" />
                        </div>
                    </div>
                </div>

                <div style={{ height: '48px' }} />

                {/* TEXT SECTION */}
                <div style={{
                    opacity: showText ? 1 : 0,
                    transform: showText ? 'translateY(0)' : 'translateY(20px)',
                    transition: 'all 0.6s ease-out',
                    textAlign: 'center',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: '12px'
                }}>
                    <h1 style={{
                        fontSize: '32px',
                        fontWeight: '800',
                        color: 'var(--auth-text)',
                        margin: 0,
                        letterSpacing: '-0.5px'
                    }}>
                        Welcome to Elvan Niril
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
                        Tap "Agree and Continue" to get started with Elvan Niril.
                    </p>

                    <AuthButton
                        onClick={handleContinue}
                    >
                        Agree and Continue
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
