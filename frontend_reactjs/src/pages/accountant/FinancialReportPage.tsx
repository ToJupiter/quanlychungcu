import React, { useState, useEffect } from 'react';
import {
  Box,
  Paper,
  Typography,
  Button,
  Grid,
  Card,
  CardContent,
  CircularProgress,
  Alert,
} from '@mui/material';
import {
  Assessment,
  TrendingUp,
  AccountBalance,
  Receipt,
  Refresh,
} from '@mui/icons-material';
import apiService from '../../services/api';
import type { 
  FinancialOverview, 
  MonthlyRevenue, 
  PaymentTypeAnalytics 
} from '../../types/api';

const FinancialReportPage: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [financialOverview, setFinancialOverview] = useState<FinancialOverview | null>(null);
  const [monthlyRevenue, setMonthlyRevenue] = useState<MonthlyRevenue[]>([]);
  const [paymentTypes, setPaymentTypes] = useState<PaymentTypeAnalytics[]>([]);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const [overview, monthly, types] = await Promise.all([
        apiService.getFinancialOverview(),
        apiService.getMonthlyRevenue(),
        apiService.getPaymentTypeAnalytics(),
      ]);
      
      setFinancialOverview(overview);
      setMonthlyRevenue(monthly);
      setPaymentTypes(types);
    } catch (err: any) {
      console.error('Financial report data loading failed:', err);
      setError(err.message || 'Failed to load financial data');
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
    }).format(amount);
  };

  if (loading) {
    return (
      <Box display="flex" flexDirection="column" justifyContent="center" alignItems="center" minHeight="60vh">
        <CircularProgress size={60} />
        <Typography variant="h6" sx={{ mt: 2 }}>
          Loading financial reports...
        </Typography>
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" component="h1" gutterBottom>
          <Assessment sx={{ mr: 2, verticalAlign: 'middle' }} />
          Financial Reports
        </Typography>
        <Button
          variant="outlined"
          startIcon={<Refresh />}
          onClick={loadData}
          disabled={loading}
        >
          Refresh Data
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}

      {financialOverview && (
        <Grid container spacing={3}>
          {/* Overview Cards */}
          <Grid item xs={12} md={6} lg={3}>
            <Card>
              <CardContent>
                <Box display="flex" alignItems="center" gap={2}>
                  <TrendingUp color="primary" />
                  <Box>
                    <Typography variant="h6">Total Revenue</Typography>
                    <Typography variant="h4" color="primary">
                      {formatCurrency(financialOverview.totalRevenue)}
                    </Typography>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          </Grid>
          
          <Grid item xs={12} md={6} lg={3}>
            <Card>
              <CardContent>
                <Box display="flex" alignItems="center" gap={2}>
                  <Receipt color="warning" />
                  <Box>
                    <Typography variant="h6">Total Due</Typography>
                    <Typography variant="h4" color="warning.main">
                      {formatCurrency(financialOverview.totalDue)}
                    </Typography>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          </Grid>
          
          <Grid item xs={12} md={6} lg={3}>
            <Card>
              <CardContent>
                <Box display="flex" alignItems="center" gap={2}>
                  <Assessment color="success" />
                  <Box>
                    <Typography variant="h6">Paid Payments</Typography>
                    <Typography variant="h4" color="success.main">
                      {financialOverview.paidPayments}
                    </Typography>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          </Grid>
          
          <Grid item xs={12} md={6} lg={3}>
            <Card>
              <CardContent>
                <Box display="flex" alignItems="center" gap={2}>
                  <AccountBalance color="error" />
                  <Box>
                    <Typography variant="h6">Unpaid Payments</Typography>
                    <Typography variant="h4" color="error.main">
                      {financialOverview.unpaidPayments}
                    </Typography>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          </Grid>

          {/* Monthly Revenue */}
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom>
                Monthly Revenue
              </Typography>
              {monthlyRevenue.length > 0 ? (
                monthlyRevenue.map((month) => (
                  <Box 
                    key={month.month} 
                    display="flex" 
                    justifyContent="space-between" 
                    alignItems="center"
                    py={1}
                    borderBottom="1px solid"
                    borderColor="divider"
                  >
                    <Typography>{month.month}</Typography>
                    <Typography fontWeight="bold">
                      {formatCurrency(month.revenue)}
                    </Typography>
                  </Box>
                ))
              ) : (
                <Typography color="text.secondary">No monthly revenue data available</Typography>
              )}
            </Paper>
          </Grid>

          {/* Payment Types */}
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom>
                Payment Types
              </Typography>
              {paymentTypes.length > 0 ? (
                paymentTypes.map((type) => (
                  <Box 
                    key={type.payment_type} 
                    display="flex" 
                    justifyContent="space-between" 
                    alignItems="center"
                    py={1}
                    borderBottom="1px solid"
                    borderColor="divider"
                  >
                    <Typography>
                      {type.payment_type.charAt(0).toUpperCase() + type.payment_type.slice(1).replace('_', ' ')}
                    </Typography>
                    <Typography fontWeight="bold">
                      {formatCurrency(type.total)}
                    </Typography>
                  </Box>
                ))
              ) : (
                <Typography color="text.secondary">No payment type data available</Typography>
              )}
            </Paper>
          </Grid>
        </Grid>
      )}

      {!financialOverview && !loading && (
        <Box textAlign="center" py={6}>
          <Assessment sx={{ fontSize: 64, color: 'grey.400', mb: 2 }} />
          <Typography variant="h6" color="text.secondary" gutterBottom>
            No financial data available
          </Typography>
          <Typography variant="body2" color="text.secondary" mb={3}>
            This could be because there's no data in the system yet, or there are connection issues.
          </Typography>
          <Button variant="contained" onClick={loadData}>
            Try Again
          </Button>
        </Box>
      )}
    </Box>
  );
};

export default FinancialReportPage; 