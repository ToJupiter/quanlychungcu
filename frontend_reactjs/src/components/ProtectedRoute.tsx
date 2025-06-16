import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { Box, CircularProgress } from '@mui/material';
import useAuthStore from '../stores/authStore';
import type { UserRole } from '../types/auth';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRole?: UserRole;
  requireAuth?: boolean;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  children,
  requiredRole,
  requireAuth = true,
}) => {
  const location = useLocation();
  const { user, isAuthenticated, isLoading, hasRole } = useAuthStore();

  // Show loading spinner while checking authentication
  if (isLoading) {
    return (
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
      >
        <CircularProgress size={40} />
      </Box>
    );
  }

  // If authentication is required but user is not authenticated
  if (requireAuth && !isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // If specific role is required, check if user has that role
  if (requiredRole && !hasRole(requiredRole)) {
    return <Navigate to="/access-denied" replace />;
  }

  return <>{children}</>;
};

export default ProtectedRoute; 