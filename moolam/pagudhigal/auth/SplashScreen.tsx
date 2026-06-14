import React from 'react';
import { AuthLayout } from './AuthComponents';
import { useLanguage } from '../../mozhi/LanguageContext';
import './splash.css';

const SplashScreen = () => {
    const { t } = useLanguage();
    
    return (
        <AuthLayout>
            <div style={{
                flex: 1,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                width: '100%',
                gap: '24px'
            }}>
                <div className="animate-zoom" style={{ 
                    display: 'flex', 
                    flexDirection: 'column', 
                    alignItems: 'center', 
                    color: 'var(--auth-text)',
                    lineHeight: 1.1
                }}>
                    <div style={{ fontSize: '18px', fontWeight: '500', opacity: 0.8, letterSpacing: '2px', textTransform: 'uppercase' }}>
                        {t('appNameFull')?.split(' ')[0] || 'Elvan'}
                    </div>
                    <div style={{ fontSize: '42px', fontWeight: 'bold' }}>
                        {t('appNameFull')?.split(' ').slice(1).join(' ') || 'Niril'}
                    </div>
                </div>
            </div>
        </AuthLayout>
    );
};

export default SplashScreen;
