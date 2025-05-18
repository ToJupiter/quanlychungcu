// src/router/AppRouter.tsx
import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from '../pages/LoginPage';
import DashboardPage from '../pages/DashboardPage';
import ApartmentsPage from '../pages/ApartmentsPage';
import HouseholdsPage from '../pages/HouseholdsPage';
import HouseholdDetailPage from '../pages/HouseholdDetailPage';
import FinancePage from '../pages/FinancePage.tsx'; // Import FinancePage
import ChangePasswordPage from '../pages/ChangePasswordPage';
import ProtectedRoute from '../components/layout/ProtectedRoute';
import Navbar from '../components/layout/Navbar';
import { useAuth } from '../hooks/useAuth';

const AppRouter: React.FC = () => {
  const { isLoading } = useAuth();

  if (isLoading) {
    return <div>Loading application...</div>; // Or a more sophisticated loader
  }

  return (
    <BrowserRouter>
      <Navbar />
      <main className="page-container">
        <Routes>
          <Route path="/login" element={<LoginPage />} />

          {/* Protected Routes */}
          <Route element={<ProtectedRoute />}>
            <Route path="/dashboard" element={<DashboardPage />} />
            <Route path="/apartments" element={<ApartmentsPage />} />
            <Route path="/households" element={<HouseholdsPage />} />
            <Route path="/households/:householdId" element={<HouseholdDetailPage />} />
            <Route path="/finance" element={<FinancePage />} /> {/* Add Finance Route */}
            <Route path="/change-password" element={<ChangePasswordPage />} />
            {/* Add other protected routes here */}
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
          </Route>

          {/* Fallback for non-matched routes or redirect to login if not authenticated */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
    </BrowserRouter>
  );
};

export default AppRouter;