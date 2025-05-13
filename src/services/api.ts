// src/services/api.ts
import axios, { AxiosError } from 'axios';
import { ApiErrorResponse } from '../types';

const apiClient = axios.create({
  baseURL: process.env.REACT_APP_BACKEND_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor to add JWT token to requests
apiClient.interceptors.request.use(
  (config) => {
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

// Optional: Interceptor to handle common error responses or token expiration
apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiErrorResponse>) => {
    if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      console.error('API Error:', error.response.data);
      if (error.response.status === 401 || error.response.status === 403) {
        // Handle unauthorized or forbidden errors, e.g., token expired
        // localStorage.removeItem('bluemoon_token');
        // localStorage.removeItem('bluemoon_user');
        // Potentially redirect to login: window.location.href = '/login';
        // This should ideally be handled by the AuthContext or a global error handler
      }
      // You can re-throw the error or return a custom error object
      return Promise.reject(error.response.data); // Pass backend error message
    } else if (error.request) {
      // The request was made but no response was received
      console.error('Network Error:', error.request);
      return Promise.reject({ message: 'Network error, please try again.' } as ApiErrorResponse);
    } else {
      // Something happened in setting up the request that triggered an Error
      console.error('Error:', error.message);
      return Promise.reject({ message: error.message } as ApiErrorResponse);
    }
  }
);


export default apiClient;