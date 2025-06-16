import React from 'react';
import {
  Box,
  Typography,
  Button,
  Container,
  Paper,
} from '@mui/material';
import { Block, Home } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';

const AccessDeniedPage: React.FC = () => {
  const navigate = useNavigate();

  const handleGoHome = () => {
    navigate('/dashboard');
  };

  const handleGoBack = () => {
    navigate(-1);
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        py: 3,
      }}
    >
      <Container maxWidth="sm">
        <Paper
          elevation={24}
          sx={{
            p: 6,
            textAlign: 'center',
            borderRadius: 3,
            backdropFilter: 'blur(10px)',
            backgroundColor: 'rgba(255, 255, 255, 0.95)',
          }}
        >
          <Block
            sx={{
              fontSize: 80,
              color: 'error.main',
              mb: 2,
            }}
          />
          
          <Typography variant="h3" component="h1" gutterBottom sx={{ fontWeight: 700, color: 'error.main' }}>
            403
          </Typography>
          
          <Typography variant="h5" component="h2" gutterBottom sx={{ fontWeight: 600, mb: 2 }}>
            Access Denied
          </Typography>
          
          <Typography variant="body1" color="text.secondary" paragraph>
            You don't have permission to access this resource. This page is restricted based on your user role.
          </Typography>
          
          <Typography variant="body2" color="text.secondary" sx={{ mb: 4 }}>
            If you believe this is an error, please contact your system administrator.
          </Typography>
          
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap' }}>
            <Button
              variant="contained"
              startIcon={<Home />}
              onClick={handleGoHome}
              sx={{ minWidth: 120 }}
            >
              Go Home
            </Button>
            
            <Button
              variant="outlined"
              onClick={handleGoBack}
              sx={{ minWidth: 120 }}
            >
              Go Back
            </Button>
          </Box>
        </Paper>
      </Container>
    </Box>
  );
};

export default AccessDeniedPage; 