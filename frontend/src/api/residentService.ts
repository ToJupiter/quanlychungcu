// src/api/residentService.ts
import apiClient from './apiClient';
import type { Resident, ResidentFormData, ApiErrorResponse } from '../types';
import { AxiosError } from 'axios';

// NOTE: Fetching residents for a household is already done by getHouseholdDetails in householdService.ts

// UC-05: Add Resident to Household
export const addResidentToHousehold = async (householdId: number, data: ResidentFormData): Promise<Resident> => {
  try {
    // Backend endpoint: POST /api/management/households/:household_id/residents
    const response = await apiClient.post<{ message: string, residentId: number }>(
      `/management/households/${householdId}/residents`,
      data
    );
    // Backend returns residentId. Return constructed object.
    return { ...data, resident_id: response.data.residentId, household_id: householdId } as Resident;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to add resident.');
    }
    throw new Error('An unexpected error occurred while adding the resident.');
  }
};

// UC-05: Update Resident
export const updateResident = async (residentId: number, data: ResidentFormData): Promise<Resident> => {
  try {
    // Backend endpoint: PUT /api/management/residents/:resident_id
    await apiClient.put(`/management/residents/${residentId}`, data);
    // Backend returns success. Return updated data optimistically.
     // Note: Household ID is typically not changed via this endpoint based on backend structure
    return { ...data, resident_id: residentId } as Resident;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to update resident.');
    }
    throw new Error('An unexpected error occurred while updating the resident.');
  }
};

// UC-05: Delete Resident
export const deleteResident = async (residentId: number): Promise<{ message: string }> => {
  try {
    // Backend endpoint: DELETE /api/management/residents/:resident_id
    const response = await apiClient.delete<{ message: string }>(`/management/residents/${residentId}`);
    return response.data;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to delete resident.');
    }
    throw new Error('An unexpected error occurred while deleting the resident.');
  }
};