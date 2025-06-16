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
} from '@mui/material';
import { useNavigate, Link as RouterLink } from 'react-router-dom';
import { PersonAdd, Pets } from '@mui/icons-material';
import useAuthStore from '../../stores/authStore';
import type { RegisterRequest } from '../../types/auth';

const RegisterPage: React.FC = () => {
  const navigate = useNavigate();
  const { register, isAuthenticated, isLoading, error, clearError } = useAuthStore();

  const [formData, setFormData] = useState<RegisterRequest>({
    full_name: '',
    email: '',
    phone_number: '',
    password: '',
    status: 'active',
  });

  const [confirmPassword, setConfirmPassword] = useState('');
  const [validationErrors, setValidationErrors] = useState<{[key: string]: string}>({});

  // Redirect if already authenticated
  useEffect(() => {
    if (isAuthenticated) {
      navigate('/dashboard', { replace: true });
    }
  }, [isAuthenticated, navigate]);

  // Clear error when component mounts
  useEffect(() => {
    clearError();
  }, [clearError]);

  const validateForm = () => {
    const errors: {[key: string]: string} = {};

    if (!formData.full_name.trim()) {
      errors.full_name = 'Name is required';
    } else if (formData.full_name.length < 2) {
      errors.full_name = 'Name must be at least 2 characters';
    }

    if (!formData.email.trim()) {
      errors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      errors.email = 'Email is invalid';
    }

    if (!formData.phone_number.trim()) {
      errors.phone_number = 'Phone number is required';
    } else if (!/^\d{10,}$/.test(formData.phone_number.replace(/\D/g, ''))) {
      errors.phone_number = 'Phone number must be at least 10 digits';
    }

    if (!formData.password) {
      errors.password = 'Password is required';
    } else if (formData.password.length < 10) {
      errors.password = 'Password must be at least 10 characters';
    }

    if (!confirmPassword) {
      errors.confirmPassword = 'Please confirm your password';
    } else if (formData.password !== confirmPassword) {
      errors.confirmPassword = 'Passwords do not match';
    }

    setValidationErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    
    if (name === 'confirmPassword') {
      setConfirmPassword(value);
    } else {
      setFormData(prev => ({
        ...prev,
        [name]: value,
      }));
    }
    
    // Clear validation errors when user starts typing
    if (validationErrors[name]) {
      setValidationErrors(prev => ({
        ...prev,
        [name]: '',
      }));
    }
    
    // Clear API error when user starts typing
    if (error) {
      clearError();
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    try {
      await register(formData);
      // Registration successful - redirect to login page
      navigate('/login', { 
        replace: true,
        state: { 
          message: 'Registration successful! Please sign in with your new account.' 
        }
      });
    } catch (err) {
      // Error is handled by the store
      console.error('Registration failed:', err);
    }
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
      <Container maxWidth="lg">
        <Grid container spacing={4} alignItems="center" justifyContent="center">
          {/* Left side - Welcome message */}
          <Grid item xs={12} md={6}>
            <Box sx={{ textAlign: { xs: 'center', md: 'left' }, color: 'white', mb: { xs: 3, md: 0 } }}>
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: { xs: 'center', md: 'flex-start' }, mb: 2 }}>
                <Pets sx={{ fontSize: 48, mr: 2 }} />
                <Typography variant="h3" component="h1" sx={{ fontWeight: 700 }}>
                  BlueMoon
                </Typography>
              </Box>
              <Typography variant="h5" sx={{ mb: 2, opacity: 0.9 }}>
                Join Our Management System
              </Typography>
              <Typography variant="body1" sx={{ opacity: 0.8 }}>
                Create your account to manage apartment buildings, households, residents, and payment information all in one place.
              </Typography>
            </Box>
          </Grid>

          {/* Right side - Registration form */}
          <Grid item xs={12} md={6}>
            <Paper
              elevation={24}
              sx={{
                p: 4,
                borderRadius: 3,
                backdropFilter: 'blur(10px)',
                backgroundColor: 'rgba(255, 255, 255, 0.95)',
              }}
            >
              <Box sx={{ textAlign: 'center', mb: 3 }}>
                <PersonAdd sx={{ fontSize: 48, color: 'primary.main', mb: 1 }} />
                <Typography variant="h4" component="h2" sx={{ fontWeight: 600, mb: 1 }}>
                  Create Account
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Fill in your details to get started
                </Typography>
              </Box>

              {error && (
                <Alert severity="error" sx={{ mb: 3 }}>
                  {error}
                </Alert>
              )}

              <Box component="form" onSubmit={handleSubmit} sx={{ mt: 2 }}>
                <TextField
                  fullWidth
                  id="full_name"
                  name="full_name"
                  label="Full Name"
                  value={formData.full_name}
                  onChange={handleChange}
                  required
                  autoComplete="name"
                  autoFocus
                  error={!!validationErrors.full_name}
                  helperText={validationErrors.full_name}
                  sx={{ mb: 2 }}
                />

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
                  error={!!validationErrors.email}
                  helperText={validationErrors.email}
                  sx={{ mb: 2 }}
                />

                <TextField
                  fullWidth
                  id="phone_number"
                  name="phone_number"
                  label="Phone Number"
                  type="tel"
                  value={formData.phone_number}
                  onChange={handleChange}
                  required
                  autoComplete="tel"
                  error={!!validationErrors.phone_number}
                  helperText={validationErrors.phone_number}
                  sx={{ mb: 2 }}
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
                  autoComplete="new-password"
                  error={!!validationErrors.password}
                  helperText={validationErrors.password || 'Password must be at least 10 characters'}
                  sx={{ mb: 2 }}
                />

                <TextField
                  fullWidth
                  id="confirmPassword"
                  name="confirmPassword"
                  label="Confirm Password"
                  type="password"
                  value={confirmPassword}
                  onChange={handleChange}
                  required
                  autoComplete="new-password"
                  error={!!validationErrors.confirmPassword}
                  helperText={validationErrors.confirmPassword}
                  sx={{ mb: 3 }}
                />

                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  size="large"
                  disabled={isLoading}
                  sx={{ mb: 2 }}
                >
                  {isLoading ? (
                    <CircularProgress size={24} color="inherit" />
                  ) : (
                    'Create Account'
                  )}
                </Button>

                <Box sx={{ textAlign: 'center' }}>
                  <Typography variant="body2" color="text.secondary">
                    Already have an account?{' '}
                    <Link component={RouterLink} to="/login" underline="hover">
                      Sign in
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

export default RegisterPage; 