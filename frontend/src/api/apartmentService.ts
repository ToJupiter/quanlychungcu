// src/api/apartmentService.ts
import apiClient from './apiClient';
import type { Apartment, ApartmentFormData, ApiErrorResponse } from '../types/index.ts';
import { AxiosError } from 'axios';

export const getApartments = async (): Promise<Apartment[]> => {
  try {
    const response = await apiClient.get<Apartment[]>('/management/apartments');
    return response.data;
  } catch (error) {
    console.error("Error fetching apartments:", error);
    throw error; // Re-throw to be handled by the caller
  }
};

export const getApartmentById = async (id: number): Promise<Apartment> => {
  try {
    const response = await apiClient.get<Apartment>(`/management/apartments/${id}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching apartment with id ${id}:`, error);
    throw error;
  }
};

export const createApartment = async (data: ApartmentFormData): Promise<Apartment> => {
  try {
    const response = await apiClient.post<{ message: string, apartmentId: number }>('/management/apartments', data);
    // The backend returns apartmentId, so we construct a partial Apartment object
    // A better backend might return the full created object.
    return { ...data, apartment_id: response.data.apartmentId } as Apartment;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to create apartment.');
    }
    throw new Error('An unexpected error occurred while creating the apartment.');
  }
};

export const updateApartment = async (id: number, data: ApartmentFormData): Promise<Apartment> => {
  try {
    await apiClient.put(`/management/apartments/${id}`, data);
    // Backend returns a success message. We return the updated data optimistically.
    // A better backend might return the full updated object.
    return { ...data, apartment_id: id } as Apartment;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to update apartment.');
    }
    throw new Error('An unexpected error occurred while updating the apartment.');
  }
};

export const deleteApartment = async (id: number): Promise<{ message: string }> => {
  try {
    const response = await apiClient.delete<{ message: string }>(`/management/apartments/${id}`);
    return response.data;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to delete apartment.');
    }
    throw new Error('An unexpected error occurred while deleting the apartment.');
  }
};