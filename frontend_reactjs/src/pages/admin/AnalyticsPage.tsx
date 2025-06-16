import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  CircularProgress,
  Alert,
  Divider,
  Button,
} from '@mui/material';
import {
  Analytics as AnalyticsIcon,
  Home,
  People,
  DirectionsCar,
  Payment,
  Refresh,
} from '@mui/icons-material';
import apiService from '../../services/api';
import type { 
  DashboardAnalytics, 
  FinancialOverview, 
  MonthlyRevenue, 
  PaymentTypeAnalytics, 
  GeneralOverview, 
  VehicleAnalytics 
} from '../../types/api';

const AnalyticsPage: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [dashboardData, setDashboardData] = useState<DashboardAnalytics | null>(null);
  const [financialData, setFinancialData] = useState<FinancialOverview | null>(null);
  const [monthlyRevenue, setMonthlyRevenue] = useState<MonthlyRevenue[]>([]);
  const [paymentTypes, setPaymentTypes] = useState<PaymentTypeAnalytics[]>([]);
  const [generalData, setGeneralData] = useState<GeneralOverview | null>(null);
  const [vehicleData, setVehicleData] = useState<VehicleAnalytics | null>(null);
  const [individualErrors, setIndividualErrors] = useState<string[]>([]);

  useEffect(() => {
    loadAnalyticsData();
  }, []);

  const loadAnalyticsData = async () => {
    try {
      setLoading(true);
      setError('');
      setIndividualErrors([]);

      const errors: string[] = [];
      
      // Load each section individually with error handling
      try {
        const dashboard = await apiService.getDashboardAnalytics();
        setDashboardData(dashboard);
      } catch (err: any) {
        console.error('Failed to load dashboard analytics:', err);
        errors.push('Dashboard overview data failed to load');
        // Set fallback data
        setDashboardData({
          totalHouseholds: 0,
          totalResidents: 0,
          totalVehicles: 0,
          totalPayments: 0,
          totalRevenue: 0,
        });
      }

      try {
        const financial = await apiService.getFinancialOverview();
        setFinancialData(financial);
      } catch (err: any) {
        console.error('Failed to load financial overview:', err);
        errors.push('Financial overview data failed to load');
        setFinancialData({
          totalRevenue: 0,
          totalDue: 0,
          totalPayments: 0,
          paidPayments: 0,
          unpaidPayments: 0,
        });
      }

      try {
        const revenue = await apiService.getMonthlyRevenue();
        setMonthlyRevenue(revenue);
      } catch (err: any) {
        console.error('Failed to load monthly revenue:', err);
        errors.push('Monthly revenue data failed to load');
      }

      try {
        const payments = await apiService.getPaymentTypeAnalytics();
        setPaymentTypes(payments);
      } catch (err: any) {
        console.error('Failed to load payment type analytics:', err);
        errors.push('Payment type breakdown failed to load');
      }

      try {
        const general = await apiService.getGeneralOverview();
        setGeneralData(general);
      } catch (err: any) {
        console.error('Failed to load general overview:', err);
        errors.push('General statistics failed to load');
      }

      try {
        const vehicles = await apiService.getVehicleAnalytics();
        setVehicleData(vehicles);
      } catch (err: any) {
        console.error('Failed to load vehicle analytics:', err);
        errors.push('Vehicle analytics failed to load');
      }

      setIndividualErrors(errors);
      
      if (errors.length === 6) {
        setError('All analytics data failed to load. Please check your connection and try again.');
      }

    } catch (err: any) {
      console.error('Failed to load analytics data:', err);
      setError('Failed to load analytics data. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(amount);
  };

  if (loading) {
    return (
      <Box display="flex" flexDirection="column" justifyContent="center" alignItems="center" minHeight="60vh">
        <CircularProgress size={60} />
        <Typography variant="h6" sx={{ mt: 2 }}>
          Loading analytics data...
        </Typography>
      </Box>
    );
  }

  return (
    <Box p={3}>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" component="h1" gutterBottom>
          <AnalyticsIcon sx={{ mr: 2, verticalAlign: 'middle' }} />
          Analytics Dashboard
        </Typography>
        <Button
          variant="outlined"
          startIcon={<Refresh />}
          onClick={loadAnalyticsData}
          disabled={loading}
        >
          Refresh Data
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError('')}>
          {error}
        </Alert>
      )}

      {individualErrors.length > 0 && (
        <Alert severity="warning" sx={{ mb: 2 }}>
          Some sections failed to load: {individualErrors.join(', ')}
        </Alert>
      )}

      {/* Dashboard Overview */}
      {dashboardData && (
        <Box mb={4}>
          <Typography variant="h6" gutterBottom>
            System Overview
          </Typography>
          <Grid container spacing={3}>
            <Grid item xs={12} sm={6} md={2.4}>
              <Card>
                <CardContent>
                  <Box display="flex" alignItems="center">
                    <Home color="primary" sx={{ mr: 2 }} />
                    <Box>
                      <Typography color="textSecondary" gutterBottom>
                        Total Households
                      </Typography>
                      <Typography variant="h5">
                        {dashboardData.totalHouseholds}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} sm={6} md={2.4}>
              <Card>
                <CardContent>
                  <Box display="flex" alignItems="center">
                    <People color="success" sx={{ mr: 2 }} />
                    <Box>
                      <Typography color="textSecondary" gutterBottom>
                        Total Residents
                      </Typography>
                      <Typography variant="h5">
                        {dashboardData.totalResidents}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} sm={6} md={2.4}>
              <Card>
                <CardContent>
                  <Box display="flex" alignItems="center">
                    <DirectionsCar color="warning" sx={{ mr: 2 }} />
                    <Box>
                      <Typography color="textSecondary" gutterBottom>
                        Total Vehicles
                      </Typography>
                      <Typography variant="h5">
                        {dashboardData.totalVehicles}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} sm={6} md={2.4}>
              <Card>
                <CardContent>
                  <Box display="flex" alignItems="center">
                    <Payment color="info" sx={{ mr: 2 }} />
                    <Box>
                      <Typography color="textSecondary" gutterBottom>
                        Total Payments
                      </Typography>
                      <Typography variant="h5">
                        {dashboardData.totalPayments}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} sm={6} md={2.4}>
              <Card>
                <CardContent>
                  <Box display="flex" alignItems="center">
                    <AnalyticsIcon color="error" sx={{ mr: 2 }} />
                    <Box>
                      <Typography color="textSecondary" gutterBottom>
                        Total Revenue
                      </Typography>
                      <Typography variant="h5">
                        {formatCurrency(dashboardData.totalRevenue)}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </Box>
      )}

      {/* Financial Overview */}
      {financialData && (
        <Box mb={4}>
          <Typography variant="h6" gutterBottom>
            Financial Overview
          </Typography>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Revenue & Due Amounts
                  </Typography>
                  <Box mb={2}>
                    <Typography color="textSecondary">
                      Total Revenue
                    </Typography>
                    <Typography variant="h5" color="success.main">
                      {formatCurrency(financialData.totalRevenue)}
                    </Typography>
                  </Box>
                  <Box>
                    <Typography color="textSecondary">
                      Total Due
                    </Typography>
                    <Typography variant="h5" color="warning.main">
                      {formatCurrency(financialData.totalDue)}
                    </Typography>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} md={6}>
              <Card>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Payment Status
                  </Typography>
                  <Box mb={2}>
                    <Typography color="textSecondary">
                      Paid Payments: {financialData.paidPayments}
                    </Typography>
                    <Typography color="textSecondary">
                      Unpaid Payments: {financialData.unpaidPayments}
                    </Typography>
                  </Box>
                  <Box>
                    <Typography variant="h6">
                      Total Payments: {financialData.totalPayments}
                    </Typography>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </Box>
      )}

      {/* General Overview */}
      {generalData && (
        <Box mb={4}>
          <Typography variant="h6" gutterBottom>
            General Statistics
          </Typography>
          <Grid container spacing={3}>
            <Grid item xs={12} sm={4}>
              <Card>
                <CardContent>
                  <Typography color="textSecondary" gutterBottom>
                    Total Apartments
                  </Typography>
                  <Typography variant="h4" color="primary">
                    {generalData.totalApartments}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} sm={4}>
              <Card>
                <CardContent>
                  <Typography color="textSecondary" gutterBottom>
                    Total Households
                  </Typography>
                  <Typography variant="h4" color="success.main">
                    {generalData.totalHouseholds}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} sm={4}>
              <Card>
                <CardContent>
                  <Typography color="textSecondary" gutterBottom>
                    Total Residents
                  </Typography>
                  <Typography variant="h4" color="info.main">
                    {generalData.totalResidents}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </Box>
      )}

      {/* Vehicle Analytics */}
      {vehicleData && (
        <Box mb={4}>
          <Typography variant="h6" gutterBottom>
            Vehicle Analytics
          </Typography>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Total Vehicles
                  </Typography>
                  <Typography variant="h4" color="warning.main">
                    {vehicleData.totalVehicles}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} md={6}>
              <Card>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Vehicle Types
                  </Typography>
                  {vehicleData.vehicleTypes.map((type) => (
                    <Box key={type.type} display="flex" justifyContent="space-between" py={1}>
                      <Typography>{type.type}</Typography>
                      <Typography fontWeight="bold">{type.count}</Typography>
                    </Box>
                  ))}
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </Box>
      )}

      {/* Monthly Revenue */}
      {monthlyRevenue.length > 0 && (
        <Box mb={4}>
          <Typography variant="h6" gutterBottom>
            Monthly Revenue
          </Typography>
          <Card>
            <CardContent>
              {monthlyRevenue.map((month) => (
                <Box key={month.month} display="flex" justifyContent="space-between" py={1}>
                  <Typography>{month.month}</Typography>
                  <Typography fontWeight="bold">{formatCurrency(month.revenue)}</Typography>
                </Box>
              ))}
            </CardContent>
          </Card>
        </Box>
      )}

      {/* Payment Types */}
      {paymentTypes.length > 0 && (
        <Box mb={4}>
          <Typography variant="h6" gutterBottom>
            Payment Types Analysis
          </Typography>
          <Card>
            <CardContent>
              {paymentTypes.map((type) => (
                <Box key={type.payment_type} display="flex" justifyContent="space-between" py={1}>
                  <Typography>{type.payment_type}</Typography>
                  <Typography fontWeight="bold">{formatCurrency(type.total)}</Typography>
                </Box>
              ))}
            </CardContent>
          </Card>
        </Box>
      )}
    </Box>
  );
};

export default AnalyticsPage; 