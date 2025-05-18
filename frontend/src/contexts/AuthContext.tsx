// src/contexts/AuthContext.tsx
import React, { createContext, useState, useEffect,  } from 'react';
import type {ReactNode} from 'react';
import type { AuthenticatedUser } from '../types';
import apiClient from '../api/apiClient'; // To clear auth header on logout if needed

interface AuthContextType {
  isAuthenticated: boolean;
  user: AuthenticatedUser | null;
  token: string | null;
  login: (token: string, userData: AuthenticatedUser) => void;
  logout: () => void;
  isLoading: boolean; // To handle initial token check
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [user, setUser] = useState<AuthenticatedUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true); // Start as true

  useEffect(() => {
    // Check for token in localStorage on initial load
    const storedToken = localStorage.getItem('bluemoon_token');
    const storedUser = localStorage.getItem('bluemoon_user');

    if (storedToken && storedUser) {
      try {
        const parsedUser: AuthenticatedUser = JSON.parse(storedUser);
        setToken(storedToken);
        setUser(parsedUser);
        setIsAuthenticated(true);
        // Optionally, you could verify the token with a backend endpoint here
        // For simplicity, we'll assume if it's there, it's valid for now
      } catch (error) {
        console.error("Failed to parse stored user data:", error);
        localStorage.removeItem('bluemoon_token');
        localStorage.removeItem('bluemoon_user');
      }
    }
    setIsLoading(false); // Finished initial check
  }, []);

  const login = (newToken: string, userData: AuthenticatedUser) => {
    localStorage.setItem('bluemoon_token', newToken);
    localStorage.setItem('bluemoon_user', JSON.stringify(userData));
    setToken(newToken);
    setUser(userData);
    setIsAuthenticated(true);
  };

  const logout = () => {
    localStorage.removeItem('bluemoon_token');
    localStorage.removeItem('bluemoon_user');
    setToken(null);
    setUser(null);
    setIsAuthenticated(false);
    // Remove Authorization header from subsequent apiClient requests
    delete apiClient.defaults.headers.common['Authorization'];
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, user, token, login, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
};