// src/App.tsx
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import darkTheme from './theme/theme';
import { AuthProvider } from './contexts/AuthContext';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import ApartmentManagementPage from './pages/ApartmentManagementPage';
// Import other pages: StaffManagementPage, HouseholdListPage, HouseholdDetailPage, PaymentsPage, ReportsPage etc.
import MainLayout from './components/layout/MainLayout';
import ProtectedRoute from './components/layout/ProtectedRoute';

function App() {
  return (
    <ThemeProvider theme={darkTheme}>
      <CssBaseline /> {/* Applies baseline dark mode styles and normalizations */}
      <AuthProvider>
        <Router>
          <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route element={<ProtectedRoute />}> {/* Routes inside here are protected */}
              <Route element={<MainLayout />}> {/* Layout for authenticated routes */}
                <Route path="/" element={<DashboardPage />} />
                <Route path="/apartments" element={<ApartmentManagementPage />} />
                {/* Add other protected routes here */}
                {/* <Route path="/staff" element={<StaffManagementPage />} /> */}
                {/* <Route path="/households" element={<HouseholdListPage />} /> */}
                {/* <Route path="/households/:id" element={<HouseholdDetailPage />} /> */}
                {/* <Route path="/payments" element={<PaymentsPage />} /> */}
                {/* <Route path="/reports" element={<ReportsPage />} /> */}
              </Route>
            </Route>
            <Route path="*" element={<Navigate to="/login" replace />} /> {/* Fallback to login */}
          </Routes>
        </Router>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;