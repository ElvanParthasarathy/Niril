import React, { useState, useEffect } from 'react';
import { AuthLayout, AuthButton } from './AuthComponents';
import { Database } from '@phosphor-icons/react';

export default function Welcome({ onContinue }: { onContinue: () => void }) {
    const [showSetup, setShowSetup] = useState(false);

    useEffect(() => {
        setTimeout(() => setShowSetup(true), 100);
    }, []);

    return (
        <AuthLayout hideLogo>
            <div style={{
                display: 'flex',
                flexDirection: 'column',
                flex: 1,
                justifyContent: 'center',
                alignItems: 'center',
                maxWidth: '480px',
                margin: '0 auto',
                width: '100%',
                position: 'relative'
            }}>
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

                        <AuthButton onClick={onContinue}>
                            Get Started
                        </AuthButton>
                    </div>
                </div>
            </div>
        </AuthLayout>
    );
}
