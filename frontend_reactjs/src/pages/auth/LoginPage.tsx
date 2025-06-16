import React, { useState, useEffect } from 'react';
import {
  Box,
  Paper,
  TextField,
  Button,
  Typography,
  Container,
  Alert,
  CircularProgress,
  Link,
  Grid,
  Divider,
} from '@mui/material';
import { useNavigate, Link as RouterLink, useLocation } from 'react-router-dom';
import { Login, Pets } from '@mui/icons-material';
import useAuthStore from '../../stores/authStore';
import type { LoginRequest } from '../../types/auth';

const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { login, isAuthenticated, isLoading, error, clearError } = useAuthStore();

  const [formData, setFormData] = useState<LoginRequest>({
    email: '',
    password: '',
  });

  // Get the intended destination from location state or default to dashboard
  const from = location.state?.from?.pathname || '/dashboard';

  // Redirect if already authenticated
  useEffect(() => {
    if (isAuthenticated) {
      navigate(from, { replace: true });
    }
  }, [isAuthenticated, navigate, from]);

  // Clear error when component mounts
  useEffect(() => {
    clearError();
  }, [clearError]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
    
    // Clear error when user starts typing
    if (error) {
      clearError();
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.email || !formData.password) {
      return;
    }

    try {
      await login(formData);
      // Redirect will happen automatically due to useEffect above
    } catch (err) {
      // Error is handled by the store
      console.error('Login failed:', err);
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: `
          linear-gradient(135deg, rgba(76, 175, 80, 0.1) 0%, rgba(33, 150, 243, 0.1) 100%),
          radial-gradient(circle at top right, rgba(156, 39, 176, 0.15) 0%, transparent 50%),
          radial-gradient(circle at bottom left, rgba(255, 152, 0, 0.15) 0%, transparent 50%),
          linear-gradient(45deg, #f8f9fa 25%, transparent 25%, transparent 75%, #f8f9fa 75%, #f8f9fa),
          linear-gradient(-45deg, #f8f9fa 25%, transparent 25%, transparent 75%, #f8f9fa 75%, #f8f9fa)
        `,
        backgroundSize: '100% 100%, 200% 200%, 200% 200%, 20px 20px, 20px 20px',
        backgroundPosition: '0 0, 0 0, 100% 100%, 0 0, 10px 10px',
        py: 3,
      }}
    >
      <Container maxWidth="lg">
        <Grid container spacing={4} alignItems="center" justifyContent="center">
          {/* Left side - Welcome message */}
          <Grid item xs={12} md={6}>
            <Box sx={{ 
              textAlign: { xs: 'center', md: 'left' }, 
              color: '#2c3e50', 
              mb: { xs: 3, md: 0 },
              p: 3,
              backgroundColor: 'rgba(255, 255, 255, 0.9)',
              borderRadius: 3,
              backdropFilter: 'blur(10px)',
              boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)',
            }}>
              <Box sx={{ 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: { xs: 'center', md: 'flex-start' }, 
                mb: 3 
              }}>
                <Pets sx={{ 
                  fontSize: 56, 
                  mr: 2, 
                  color: '#4CAF50',
                  filter: 'drop-shadow(2px 2px 4px rgba(0,0,0,0.1))'
                }} />
                <Typography variant="h3" component="h1" sx={{ 
                  fontWeight: 700,
                  background: 'linear-gradient(45deg, #4CAF50, #2196F3)',
                  backgroundClip: 'text',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                }}>
                  BlueMoon
                </Typography>
              </Box>
              <Typography variant="h5" sx={{ 
                mb: 2, 
                color: '#34495e',
                fontWeight: 500,
              }}>
                Welcome Back!
              </Typography>
              <Typography variant="body1" sx={{ 
                color: '#5a6c7d',
                lineHeight: 1.6,
                fontSize: '1.1rem',
              }}>
                Sign in to manage apartment residents, household information, and access all our management services. 
                Your trusted partner in apartment management and administration.
              </Typography>
            </Box>
          </Grid>

          {/* Right side - Login form */}
          <Grid item xs={12} md={6}>
            <Paper
              elevation={24}
              sx={{
                p: 4,
                borderRadius: 3,
                backdropFilter: 'blur(20px)',
                backgroundColor: 'rgba(255, 255, 255, 0.95)',
                boxShadow: '0 20px 40px rgba(0, 0, 0, 0.1)',
                border: '1px solid rgba(255, 255, 255, 0.2)',
              }}
            >
              <Box sx={{ textAlign: 'center', mb: 3 }}>
                <Login sx={{ 
                  fontSize: 48, 
                  color: 'primary.main', 
                  mb: 1,
                  filter: 'drop-shadow(2px 2px 4px rgba(0,0,0,0.1))'
                }} />
                <Typography variant="h4" component="h2" sx={{ 
                  fontWeight: 600, 
                  mb: 1,
                  color: '#2c3e50',
                }}>
                  Sign In
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Enter your credentials to access your account
                </Typography>
              </Box>

              {/* Registration success message */}
              {location.state?.message && (
                <Alert severity="success" sx={{ mb: 3 }}>
                  {location.state.message}
                </Alert>
              )}

              {error && (
                <Alert severity="error" sx={{ mb: 3 }}>
                  {error}
                </Alert>
              )}

              <Box component="form" onSubmit={handleSubmit} sx={{ mt: 2 }}>
                <TextField
                  fullWidth
                  id="email"
                  name="email"
                  label="Email Address"
                  type="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                  autoComplete="email"
                  autoFocus
                  sx={{ 
                    mb: 2,
                    '& .MuiOutlinedInput-root': {
                      '&:hover fieldset': {
                        borderColor: '#4CAF50',
                      },
                    },
                  }}
                />

                <TextField
                  fullWidth
                  id="password"
                  name="password"
                  label="Password"
                  type="password"
                  value={formData.password}
                  onChange={handleChange}
                  required
                  autoComplete="current-password"
                  sx={{ 
                    mb: 3,
                    '& .MuiOutlinedInput-root': {
                      '&:hover fieldset': {
                        borderColor: '#4CAF50',
                      },
                    },
                  }}
                />

                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  size="large"
                  disabled={isLoading}
                  sx={{ 
                    mb: 2,
                    background: 'linear-gradient(45deg, #4CAF50, #45a049)',
                    boxShadow: '0 4px 15px rgba(76, 175, 80, 0.4)',
                    '&:hover': {
                      background: 'linear-gradient(45deg, #45a049, #3e8e41)',
                      boxShadow: '0 6px 20px rgba(76, 175, 80, 0.6)',
                    },
                  }}
                >
                  {isLoading ? (
                    <CircularProgress size={24} color="inherit" />
                  ) : (
                    'Sign In'
                  )}
                </Button>

                <Divider sx={{ my: 2 }}>
                  <Typography variant="body2" color="text.secondary">
                    or
                  </Typography>
                </Divider>

                <Box sx={{ textAlign: 'center' }}>
                  <Typography variant="body2" color="text.secondary">
                    Don't have an account?{' '}
                    <Link 
                      component={RouterLink} 
                      to="/register" 
                      underline="hover"
                      sx={{
                        color: '#4CAF50',
                        fontWeight: 500,
                        '&:hover': {
                          color: '#45a049',
                        },
                      }}
                    >
                      Sign up
                    </Link>
                  </Typography>
                </Box>
              </Box>
            </Paper>
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
};

export default LoginPage; 