import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { User, LoginRequest, RegisterRequest, UserRole, AuthState, ApiError } from '../types/auth';
import apiService from '../services/api';

interface AuthStore extends AuthState {
  // Actions
  login: (credentials: LoginRequest) => Promise<void>;
  register: (userData: RegisterRequest) => Promise<void>;
  logout: () => Promise<void>;
  getCurrentUser: () => Promise<void>;
  clearError: () => void;
  setLoading: (loading: boolean) => void;
  
  // Utility methods
  hasRole: (role: UserRole) => boolean;
  isAdmin: () => boolean;
  isAccountant: () => boolean;
}

const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      // Initial state
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      // Actions
      login: async (credentials: LoginRequest) => {
        set({ isLoading: true, error: null });
        try {
          const loginResponse = await apiService.login(credentials);
          console.log('Login response:', loginResponse);
          
          // Store user info from login response
          const user = loginResponse.user;
          localStorage.setItem('user-info', JSON.stringify(user));
          
          set({
            user,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          const apiError = error as ApiError;
          set({
            user: null,
            isAuthenticated: false,
            isLoading: false,
            error: apiError.message,
          });
          throw error;
        }
      },

      register: async (userData: RegisterRequest) => {
        set({ isLoading: true, error: null });
        try {
          await apiService.register(userData);
          // Don't automatically authenticate after registration
          // User needs to login manually after registration
          set({
            user: null,
            isAuthenticated: false,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          const apiError = error as ApiError;
          set({
            user: null,
            isAuthenticated: false,
            isLoading: false,
            error: apiError.message,
          });
          throw error;
        }
      },

      logout: async () => {
        set({ isLoading: true });
        try {
          await apiService.logout();
        } catch (error) {
          console.error('Logout error:', error);
          // Continue with logout even if API call fails
        } finally {
          localStorage.removeItem('user-info');
          set({
            user: null,
            isAuthenticated: false,
            isLoading: false,
            error: null,
          });
        }
      },

      getCurrentUser: async () => {
        set({ isLoading: true, error: null });
        try {
          const user = await apiService.getCurrentUser();
          set({
            user,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          const apiError = error as ApiError;
          // Don't set error message for failed session restoration
          set({
            user: null,
            isAuthenticated: false,
            isLoading: false,
            error: null, // Clear any previous errors
          });
          throw error;
        }
      },

      clearError: () => {
        set({ error: null });
      },

      setLoading: (loading: boolean) => {
        set({ isLoading: loading });
      },

      // Utility methods for BlueMoon roles
      hasRole: (role: UserRole): boolean => {
        const { user } = get();
        if (!user) return false;
        
        if (role === 'ADMIN') {
          return user.roles === 0;
        } else if (role === 'ACCOUNTANT') {
          return user.roles === 1;
        }
        return false;
      },

      isAdmin: (): boolean => {
        return get().hasRole('ADMIN');
      },

      isAccountant: (): boolean => {
        return get().hasRole('ACCOUNTANT');
      },
    }),
    {
      name: 'auth-store',
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
      // Don't persist loading state
      onRehydrateStorage: () => (state) => {
        // Reset loading state after rehydration
        if (state) {
          state.isLoading = false;
        }
      },
    }
  )
);

export default useAuthStore; 