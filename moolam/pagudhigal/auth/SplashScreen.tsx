import React from 'react';
import { AuthLayout } from './AuthComponents';
import './splash.css';

const SplashScreen = () => {
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
                    Elvan Niril
                </div>
            </div>
        </AuthLayout>
    );
};

export default SplashScreen;
