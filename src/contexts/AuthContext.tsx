// src/contexts/AuthContext.tsx
import React, { createContext, useState, useEffect, ReactNode } from 'react';
import { AuthUser, Staff } from '../types'; // Assuming Staff type can be used for login response

interface AuthContextType {
  user: AuthUser | null;
  token: string | null;
  isLoading: boolean;
  login: (email: string, pass: string) => Promise<void>;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true); // For checking initial auth state

  useEffect(() => {
    // Check for existing token and user in localStorage on initial load
    const storedToken = localStorage.getItem('bluemoon_token');
    const storedUserString = localStorage.getItem('bluemoon_user');
    if (storedToken && storedUserString) {
      try {
        const storedUser = JSON.parse(storedUserString) as AuthUser;
        setToken(storedToken);
        setUser(storedUser);
      } catch (error) {
        console.error("Failed to parse stored user:", error);
        localStorage.removeItem('bluemoon_token');
        localStorage.removeItem('bluemoon_user');
      }
    }
    setIsLoading(false);
  }, []);

  const login = async (email: string, pass: string) => {
    // apiClient is already configured in services/api.ts
    // We need to import it or define login service function there
    const api = (await import('../services/api')).default; // Dynamic import for example
    const response = await api.post<{token: string, user: AuthUser, message: string}>('/auth/staff/login', { email, password: pass });

    if (response.data.token && response.data.user) {
      setToken(response.data.token);
      setUser(response.data.user);
      localStorage.setItem('bluemoon_token', response.data.token);
      localStorage.setItem('bluemoon_user', JSON.stringify(response.data.user));
    } else {
        throw new Error(response.data.message || "Login failed");
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('bluemoon_token');
    localStorage.removeItem('bluemoon_user');
    // Optionally redirect to login page via useNavigate or window.location
  };

  return (
    <AuthContext.Provider value={{ user, token, isLoading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};