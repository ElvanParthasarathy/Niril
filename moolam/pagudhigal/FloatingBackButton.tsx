import React from 'react';
import { Button } from '@mui/material';
import { CaretLeft } from '@phosphor-icons/react';

interface FloatingBackButtonProps {
    to?: string; 
    label?: string;
    className?: string;
    onBack?: () => void;
}

export const FloatingBackButton: React.FC<FloatingBackButtonProps> = ({ label = "பின்செல்", className, onBack }) => {
    return (
        <Button 
            variant="contained"
            disableElevation
            className={className}
            startIcon={<CaretLeft weight="bold" size={16} />}
            onClick={(e) => {
                if (onBack) {
                    onBack();
                } else if (window.history.state && window.history.state.idx > 0) {
                    window.history.back();
                } else {
                    window.location.search = '';
                }
            }}
            sx={{ 
                borderRadius: '50px', 
                textTransform: 'none',
                fontWeight: 700,
                px: 2.5,
                height: 40,
                minHeight: 40,
                maxHeight: 40,
                display: 'flex',
                alignItems: 'center',
                fontSize: '0.9rem',
                bgcolor: 'background.paper',
                color: 'text.primary',
                '& .MuiButton-startIcon': {
                    transform: 'translateY(-1px)'
                },
                '&:hover': {
                    bgcolor: 'action.hover',
                }
            }}
        >
            {label}
        </Button>
    );
};
