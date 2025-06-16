import React, { useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { Box, CircularProgress } from '@mui/material';
import useAuthStore from './stores/authStore';

// Layout Components
import MainLayout from './components/Layout/MainLayout';
import ProtectedRoute from './components/ProtectedRoute';

// Auth Pages
import LoginPage from './pages/auth/LoginPage';
import RegisterPage from './pages/auth/RegisterPage';

// Dashboard Pages
import DashboardPage from './pages/dashboard/DashboardPage';

// Admin Pages (renamed from pet store management)
import StaffManagementPage from './pages/admin/StaffManagementPage'; // formerly UsersPage
import ApartmentManagementPage from './pages/admin/ApartmentManagementPage'; // formerly AllPetsPage 
import HouseholdManagementPage from './pages/admin/HouseholdManagementPage'; // formerly AllBookingsPage
import PaymentManagementPage from './pages/admin/PaymentManagementPage'; // formerly ServicesPage
import AnalyticsPage from './pages/admin/AnalyticsPage';

// Accountant Pages (accessible by both Admin and Accountant)
import FinancialReportPage from './pages/accountant/FinancialReportPage';

// Common Pages
import ProfilePage from './pages/common/ProfilePage';
import AccessDeniedPage from './pages/common/AccessDeniedPage';
import ChangePasswordPage from './pages/common/ChangePasswordPage';

// Root component that handles initial routing logic
const AppRouter: React.FC = () => {
  const { isAuthenticated, isLoading, getCurrentUser } = useAuthStore();

  // Try to restore user session on app start
  useEffect(() => {
    const restoreSession = async () => {
      try {
        await getCurrentUser();
      } catch (error) {
        console.log('No active session found');
      }
    };

    // Only try to restore session if we're not already authenticated
    if (!isAuthenticated) {
      restoreSession();
    }
  }, [getCurrentUser, isAuthenticated]);

  // Show loading spinner during initial authentication check
  if (isLoading) {
    return (
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
        sx={{ 
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          color: 'white'
        }}
      >
        <Box textAlign="center">
          <CircularProgress size={40} sx={{ color: 'white', mb: 2 }} />
          <Box>Loading BlueMoon Management System...</Box>
        </Box>
      </Box>
    );
  }

  return (
    <Routes>
      {/* Root route - redirect based on authentication */}
      <Route path="/" element={
        isAuthenticated ? <Navigate to="/dashboard" replace /> : <Navigate to="/login" replace />
      } />

      {/* Public Routes */}
      <Route path="/login" element={
        isAuthenticated ? <Navigate to="/dashboard" replace /> : <LoginPage />
      } />
      <Route path="/register" element={
        isAuthenticated ? <Navigate to="/dashboard" replace /> : <RegisterPage />
      } />
      <Route path="/access-denied" element={<AccessDeniedPage />} />

      {/* Protected Routes with Layout */}
      <Route path="/" element={
        <ProtectedRoute>
          <MainLayout />
        </ProtectedRoute>
      }>
        {/* Common Protected Routes (both Admin and Accountant) */}
        <Route path="dashboard" element={<DashboardPage />} />
        <Route path="profile" element={<ProfilePage />} />
        <Route path="change-password" element={<ChangePasswordPage />} />
        
        {/* Admin-only Routes */}
        <Route path="staff" element={
          <ProtectedRoute requiredRole="ADMIN">
            <StaffManagementPage />
          </ProtectedRoute>
        } />
        <Route path="apartments" element={
          <ProtectedRoute requiredRole="ADMIN">
            <ApartmentManagementPage />
          </ProtectedRoute>
        } />
        <Route path="households" element={
          <ProtectedRoute requiredRole="ADMIN">
            <HouseholdManagementPage />
          </ProtectedRoute>
        } />
        
        {/* Admin and Accountant Routes */}
        <Route path="payments" element={
          <ProtectedRoute>
            <PaymentManagementPage />
          </ProtectedRoute>
        } />
        <Route path="analytics" element={
          <ProtectedRoute>
            <AnalyticsPage />
          </ProtectedRoute>
        } />
        <Route path="financial-reports" element={
          <ProtectedRoute>
            <FinancialReportPage />
          </ProtectedRoute>
        } />
      </Route>

      {/* Catch all route - redirect to appropriate page */}
      <Route path="*" element={
        isAuthenticated ? <Navigate to="/dashboard" replace /> : <Navigate to="/login" replace />
      } />
    </Routes>
  );
};

function App() {
  return <AppRouter />;
}

export default App;
