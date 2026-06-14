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
                <div className="animate-zoom" style={{ fontSize: '32px', fontWeight: 'bold', color: 'var(--auth-text)' }}>
                    {t('appName')}
                </div>

                {/* Spinner */}
                <div className="splash-spinner animate-enter delay-1">
                    {[...Array(12)].map((_, i) => (
                        <div key={i} className="bar"></div>
                    ))}
                </div>
            </div>
        </AuthLayout>
    );
};

export default SplashScreen;
