import React, { useState, useEffect } from 'react';
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  Avatar,
  Chip,
  CircularProgress,
  Alert,
  Button,
  Paper,
} from '@mui/material';
import {
  Home,
  People,
  DirectionsCar,
  Payment,
  Apartment,
  TrendingUp,
  Dashboard as DashboardIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import useAuthStore from '../../stores/authStore';
import apiService from '../../services/api';
import type { DashboardAnalytics } from '../../types/api';

interface StatCard {
  title: string;
  value: number;
  icon: React.ReactNode;
  color: string;
  loading?: boolean;
}

const DashboardPage: React.FC = () => {
  const { user, isAdmin, isAccountant } = useAuthStore();
  const navigate = useNavigate();
  const [analytics, setAnalytics] = useState<DashboardAnalytics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadDashboardData = async () => {
      try {
        setLoading(true);
        setError(null);

        const data = await apiService.getDashboardAnalytics();
        setAnalytics(data);
      } catch (err) {
        console.error('Failed to load dashboard data:', err);
        setError('Failed to load dashboard data. Please try again.');
      } finally {
        setLoading(false);
      }
    };

    loadDashboardData();
  }, []);

  const getWelcomeMessage = () => {
    if (!user) return 'Welcome to BlueMoon Management System';
    
    const name = user.full_name || user.email;
    return `Welcome back, ${name}!`;
  };

  const getRoleColor = () => {
    return user?.roles === 0 ? '#f44336' : '#ff9800'; // Admin: red, Accountant: orange
  };

  const getRoleLabel = () => {
    return user?.roles === 0 ? 'Admin' : 'Accountant';
  };

  const getProfileGradient = () => {
    return user?.roles === 0 
      ? 'linear-gradient(135deg, #6366f1 0%, #4f46e5 100%)'
      : 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)';
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(amount);
  };

  const quickActions = [
    ...(isAdmin() ? [
      {
        title: 'Manage Staff',
        description: 'Add, edit, or remove staff members',
        action: () => navigate('/staff'),
        color: '#8b5cf6',
      },
      {
        title: 'Apartment Management',
        description: 'Manage apartment units and their status',
        action: () => navigate('/apartments'),
        color: '#06b6d4',
      },
      {
        title: 'Household Management',
        description: 'Manage households, residents, and vehicles',
        action: () => navigate('/households'),
        color: '#10b981',
      },
    ] : []),
    {
      title: 'Payment Management',
      description: 'Handle payments and billing',
      action: () => navigate('/payments'),
      color: '#f59e0b',
    },
    {
      title: 'View Analytics',
      description: 'See detailed reports and analytics',
      action: () => navigate('/analytics'),
      color: '#ec4899',
    },
  ];

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress size={40} />
      </Box>
    );
  }

  return (
    <Box>
      {/* Header */}
      <Box mb={4}>
        <Typography variant="h4" component="h1" gutterBottom sx={{ fontWeight: 600 }}>
          Dashboard
        </Typography>
        <Typography variant="h6" color="text.secondary" gutterBottom>
          {getWelcomeMessage()}
        </Typography>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      <Grid container spacing={3}>
        {/* Statistics Cards */}
        {analytics && (
          <>
            <Grid item xs={12} sm={6} md={3}>
              <Card>
                <CardContent>
                  <Box display="flex" alignItems="center">
                    <Avatar sx={{ bgcolor: '#10b981', mr: 2 }}>
                      <Home />
                    </Avatar>
                    <Box>
                      <Typography color="textSecondary" gutterBottom>
                        Total Households
                      </Typography>
                      <Typography variant="h5">
                        {analytics.totalHouseholds}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} sm={6} md={3}>
              <Card>
                <CardContent>
                  <Box display="flex" alignItems="center">
                    <Avatar sx={{ bgcolor: '#3b82f6', mr: 2 }}>
                      <People />
                    </Avatar>
                    <Box>
                      <Typography color="textSecondary" gutterBottom>
                        Total Residents
                      </Typography>
                      <Typography variant="h5">
                        {analytics.totalResidents}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} sm={6} md={3}>
              <Card>
                <CardContent>
                  <Box display="flex" alignItems="center">
                    <Avatar sx={{ bgcolor: '#f59e0b', mr: 2 }}>
                      <DirectionsCar />
                    </Avatar>
                    <Box>
                      <Typography color="textSecondary" gutterBottom>
                        Total Vehicles
                      </Typography>
                      <Typography variant="h5">
                        {analytics.totalVehicles}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} sm={6} md={3}>
              <Card>
                <CardContent>
                  <Box display="flex" alignItems="center">
                    <Avatar sx={{ bgcolor: '#ef4444', mr: 2 }}>
                      <Payment />
                    </Avatar>
                    <Box>
                      <Typography color="textSecondary" gutterBottom>
                        Total Revenue
                      </Typography>
                      <Typography variant="h6">
                        {formatCurrency(analytics.totalRevenue)}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          </>
        )}

        {/* Profile Card */}
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Box
                sx={{
                  background: getProfileGradient(),
                  borderRadius: 2,
                  p: 3,
                  color: 'white',
                  textAlign: 'center',
                  mb: 2,
                }}
              >
                <Avatar
                  sx={{
                    width: 64,
                    height: 64,
                    bgcolor: 'rgba(255, 255, 255, 0.2)',
                    mx: 'auto',
                    mb: 2,
                    fontSize: '1.5rem',
                  }}
                >
                  {user?.full_name?.charAt(0)?.toUpperCase() || 'U'}
                </Avatar>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 1 }}>
                  {user?.full_name || 'User'}
                </Typography>
                <Chip
                  label={getRoleLabel()}
                  sx={{
                    bgcolor: 'rgba(255, 255, 255, 0.2)',
                    color: 'white',
                    fontWeight: 500,
                  }}
                />
              </Box>
              <Button
                fullWidth
                variant="outlined"
                onClick={() => navigate('/profile')}
              >
                View Profile
              </Button>
            </CardContent>
          </Card>
        </Grid>

        {/* Quick Actions */}
        <Grid item xs={12} md={8}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom sx={{ fontWeight: 600, mb: 3 }}>
                Quick Actions
              </Typography>
              <Grid container spacing={2}>
                {quickActions.map((action, index) => (
                  <Grid item xs={12} sm={6} key={index}>
                    <Paper
                      sx={{
                        p: 2,
                        cursor: 'pointer',
                        transition: 'all 0.2s',
                        borderLeft: `4px solid ${action.color}`,
                        '&:hover': {
                          transform: 'translateY(-2px)',
                          boxShadow: 3,
                        },
                      }}
                      onClick={action.action}
                    >
                      <Typography variant="subtitle1" sx={{ fontWeight: 600, mb: 1 }}>
                        {action.title}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        {action.description}
                      </Typography>
                    </Paper>
                  </Grid>
                ))}
              </Grid>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default DashboardPage; 