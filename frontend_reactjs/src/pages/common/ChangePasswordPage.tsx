import React, { useState } from 'react';
import {
  Box,
  Paper,
  Typography,
  TextField,
  Button,
  Alert,
  CircularProgress,
} from '@mui/material';
import { VpnKey } from '@mui/icons-material';
import apiService from '../../services/api';
import useAuthStore from '../../stores/authStore';

const ChangePasswordPage: React.FC = () => {
  const { user } = useAuthStore();
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const [formData, setFormData] = useState({
    oldPassword: '',
    newPassword: '',
    confirmPassword: '',
  });

  const handleFormChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (formData.newPassword !== formData.confirmPassword) {
      setError('New passwords do not match');
      return;
    }

    if (formData.newPassword.length < 6) {
      setError('New password must be at least 6 characters long');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      setSuccess(false);

      await apiService.changePassword({
        email: user?.email || '',
        oldPassword: formData.oldPassword,
        newPassword: formData.newPassword,
      });

      setSuccess(true);
      setFormData({
        oldPassword: '',
        newPassword: '',
        confirmPassword: '',
      });
    } catch (err: any) {
      setError(err.message || 'Failed to change password');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box sx={{ p: 3, maxWidth: 600, mx: 'auto' }}>
      <Paper sx={{ p: 4 }}>
        <Box display="flex" alignItems="center" gap={2} mb={3}>
          <VpnKey color="primary" />
          <Typography variant="h4" component="h1">
            Change Password
          </Typography>
        </Box>

        {success && (
          <Alert severity="success" sx={{ mb: 3 }}>
            Password changed successfully!
          </Alert>
        )}

        {error && (
          <Alert severity="error" sx={{ mb: 3 }}>
            {error}
          </Alert>
        )}

        <Box component="form" onSubmit={handleSubmit}>
          <Box display="flex" flexDirection="column" gap={3}>
            <TextField
              name="oldPassword"
              label="Current Password"
              type="password"
              value={formData.oldPassword}
              onChange={handleFormChange}
              fullWidth
              required
              disabled={loading}
            />
            
            <TextField
              name="newPassword"
              label="New Password"
              type="password"
              value={formData.newPassword}
              onChange={handleFormChange}
              fullWidth
              required
              disabled={loading}
              helperText="Password must be at least 6 characters long"
            />
            
            <TextField
              name="confirmPassword"
              label="Confirm New Password"
              type="password"
              value={formData.confirmPassword}
              onChange={handleFormChange}
              fullWidth
              required
              disabled={loading}
            />

            <Button
              type="submit"
              variant="contained"
              size="large"
              disabled={loading || !formData.oldPassword || !formData.newPassword || !formData.confirmPassword}
              sx={{ 
                mt: 2,
                background: 'linear-gradient(45deg, #2196F3 30%, #21CBF3 90%)',
              }}
            >
              {loading ? (
                <CircularProgress size={24} color="inherit" />
              ) : (
                'Change Password'
              )}
            </Button>
          </Box>
        </Box>
      </Paper>
    </Box>
  );
};

export default ChangePasswordPage; 