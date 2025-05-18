// src/api/paymentService.ts
import apiClient from './apiClient';
import type { Payment, PaymentFormData, ApiErrorResponse } from '../types';
import { AxiosError } from 'axios';

// NOTE: Fetching payments for a household is already done by getHouseholdDetails in householdService.ts

interface GetAllPaymentsParams {
  status?: string;
  startDate?: string; // YYYY-MM-DD
  endDate?: string;   // YYYY-MM-DD
  householdId?: number;
}

// Get all payments with optional filters (corresponds to backend getAllPayments)
export const getAllPayments = async (params?: GetAllPaymentsParams): Promise<Payment[]> => {
  try {
    // Backend endpoint: GET /api/finance/payments
    const response = await apiClient.get<Payment[]>('/finance/payments', { params });
    return response.data;
  } catch (error) {
    console.error("Error fetching payments:", error);
    throw error;
  }
};

// Get a single payment by ID
export const getPaymentById = async (id: number): Promise<Payment> => {
  try {
    // Backend endpoint: GET /api/finance/payments/:payment_id
    const response = await apiClient.get<Payment>(`/finance/payments/${id}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching payment with id ${id}:`, error);
    throw error;
  }
};


// Create a new payment record (corresponds to backend createPayment)
export const createPayment = async (data: PaymentFormData): Promise<Payment> => {
  try {
    // Backend endpoint: POST /api/finance/payments
    const response = await apiClient.post<{ message: string, paymentId: number }>('/finance/payments', data);
     // Backend returns paymentId. Return constructed object.
     // Note: backend doesn't return full object including joined apartment_number here
    return { ...data, payment_id: response.data.paymentId } as Payment; // Partial Payment
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to create payment.');
    }
    throw new Error('An unexpected error occurred while creating the payment.');
  }
};

interface UpdatePaymentStatusData {
  status: string;
  payment_date?: string | null; // YYYY-MM-DD, optional, backend sets if Paid
}

// Update payment status (corresponds to backend updatePaymentStatus)
export const updatePaymentStatus = async (paymentId: number, data: UpdatePaymentStatusData): Promise<{ message: string }> => {
  try {
    // Backend endpoint: PATCH /api/finance/payments/:payment_id/status
    const response = await apiClient.patch<{ message: string }>(`/finance/payments/${paymentId}/status`, data);
    return response.data;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to update payment status.');
    }
    throw new Error('An unexpected error occurred while updating the payment status.');
  }
};

// Delete a payment record (corresponds to backend deletePayment)
export const deletePayment = async (paymentId: number): Promise<{ message: string }> => {
  try {
    // Backend endpoint: DELETE /api/finance/payments/:payment_id
    const response = await apiClient.delete<{ message: string }>(`/finance/payments/${paymentId}`);
    return response.data;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to delete payment.');
    }
    throw new Error('An unexpected error occurred while deleting the payment.');
  }
};

// Need a way to get households for the payment form dropdown
import { getHouseholds } from './householdService'; // Re-use existing service
export { getHouseholds };