import React, { useState } from 'react';
import { CaretDown } from '@phosphor-icons/react';
import './Auth.css';

export const AuthLayout = ({ children }: { children: React.ReactNode }) => (
    <div className="auth-container">
        <div className="auth-shape shape-1" />
        <div className="auth-shape shape-2" />
        <div className="auth-shape shape-3" />
        <div className="auth-shape shape-4" />
        <div className="auth-content">
            {children}
        </div>
    </div>
);

export const AuthHeader = ({ title, subtitle }: { title: string, subtitle: string }) => (
    <div className="auth-header animate-enter delay-1">
        <div className="auth-title">{title}</div>
        <div className="auth-subtitle">{subtitle}</div>
    </div>
);

import { TextField, Button, InputAdornment, IconButton, Typography, Box, CircularProgress } from '@mui/material';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';

export const AuthInput = ({ label, value, onChange, type = "text", placeholder, icon, error, ...props }: any) => {
    const [showPass, setShowPass] = useState(false);
    const isPass = type === 'password';

    return (
        <Box className="auth-field animate-enter delay-2" sx={{ width: '100%', mb: 2 }}>
            <TextField
                fullWidth
                label={label}
                value={value}
                onChange={onChange}
                type={isPass && showPass ? 'text' : type}
                placeholder={placeholder}
                error={!!error}
                helperText={error}
                slotProps={{
                    input: {
                        startAdornment: icon ? (
                            <InputAdornment position="start">
                                {icon}
                            </InputAdornment>
                        ) : null,
                        endAdornment: isPass ? (
                            <InputAdornment position="end">
                                <IconButton
                                    aria-label="toggle password visibility"
                                    onClick={() => setShowPass(!showPass)}
                                    edge="end"
                                    size="small"
                                >
                                    {showPass ? <VisibilityOff fontSize="small" /> : <Visibility fontSize="small" />}
                                </IconButton>
                            </InputAdornment>
                        ) : null,
                    }
                }}
                {...props}
            />
        </Box>
    );
};

export const AuthButton = ({ children, onClick, disabled, loading, secondary, className = "", type = "button" }: any) => (
    <Button
        fullWidth
        type={type}
        variant={secondary ? 'outlined' : 'contained'}
        color="primary"
        size="large"
        className={`animate-enter delay-3 ${className}`}
        onClick={onClick}
        disabled={disabled || loading}
        sx={{
            py: 1.5,
            borderRadius: 50,
            mt: 2,
            mb: 1,
            fontWeight: 600,
            textTransform: 'none',
            fontSize: '1rem',
            ...(secondary && {
                borderColor: 'var(--auth-text)',
                color: 'var(--auth-text)',
                backgroundColor: 'transparent',
                '&:hover': {
                    borderColor: 'var(--auth-text)',
                    backgroundColor: 'rgba(128, 128, 128, 0.08)'
                }
            })
        }}
    >
        {loading ? <CircularProgress size={24} color="inherit" /> : children}
    </Button>
);
