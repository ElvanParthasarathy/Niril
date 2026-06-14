import React, { useState } from 'react';
import { Eye, EyeClosed, CaretDown } from '@phosphor-icons/react';
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

export const AuthInput = ({ label, value, onChange, type = "text", placeholder, icon, error, ...props }: any) => {
    const [showPass, setShowPass] = useState(false);
    const isPass = type === 'password';

    return (
        <div className="auth-field animate-enter delay-2">
            <label className="auth-label">{label}</label>
            <div className={`auth-input-wrapper ${error ? 'has-error' : ''}`}>
                {icon && <div className="auth-icon-start">{icon}</div>}
                <input
                    className={`auth-input ${icon ? 'has-start-icon' : ''} ${isPass ? 'has-end-icon' : ''}`}
                    type={isPass && showPass ? 'text' : type}
                    value={value}
                    onChange={onChange}
                    placeholder={placeholder}
                    {...props}
                />
                {isPass && (
                    <div className="auth-icon-end" onClick={() => setShowPass(!showPass)}>
                        {showPass ? <EyeClosed size={20} /> : <Eye size={20} />}
                    </div>
                )}
            </div>
            {error && <div className="auth-error">{error}</div>}
        </div>
    );
};

export const AuthButton = ({ children, onClick, disabled, loading, secondary, className = "", type = "button" }: any) => (
    <button
        type={type}
        className={`auth-btn ${secondary ? 'auth-btn-google' : ''} ${className} animate-enter delay-3`}
        onClick={onClick}
        disabled={disabled || loading}
    >
        {loading ? <div className="btn-loader" /> : children}
    </button>
);
