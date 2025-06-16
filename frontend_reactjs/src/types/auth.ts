// BlueMoon Authentication Types

export type UserRole = 'ADMIN' | 'ACCOUNTANT';

export interface User {
  staff_id: string;
  full_name: string;
  email: string;
  phone_number: string;
  status: string;
  created_at: string;
  roles: number; // 0 = Admin, 1 = Accountant
  is_admin?: boolean;
  is_accountant?: boolean;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  full_name: string;
  phone_number: string;
  status: string;
}

export interface LoginResponse {
  message: string;
  token: string;
  user: User;
}

export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}

export interface ApiError {
  message: string;
  status?: number;
  errors?: Record<string, string>;
  statusCode?: number;
  timestamp?: string;
} 