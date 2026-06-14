import React from 'react';
import { AuthLayout } from './AuthComponents';
import { CircularProgress } from '@mui/material';
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

                <div className="animate-enter delay-1">
                    <CircularProgress size={28} thickness={4.5} sx={{ color: 'var(--auth-text, #ffffff)' }} />
                </div>
            </div>
        </AuthLayout>
    );
};

export default SplashScreen;
