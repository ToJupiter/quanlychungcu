// src/api/apiClient.ts
import axios, { AxiosError } from 'axios';
import type {InternalAxiosRequestConfig} from 'axios';
import type { ApiErrorResponse } from '../types';

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_BACKEND_API_URL, // From .env.local
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request Interceptor to add JWT token
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('bluemoon_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response Interceptor for global error handling (optional, can be handled per call)
apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiErrorResponse>) => {
    // You can handle specific error codes globally here if needed
    // e.g., if (error.response?.status === 401) { logoutUser(); }
    // For now, just re-throw to be caught by the caller
    return Promise.reject(error);
  }
);

export default apiClient;