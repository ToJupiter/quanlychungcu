// src/api/vehicleService.ts
import apiClient from './apiClient';
import type { Vehicle, VehicleFormData, ApiErrorResponse } from '../types';
import { AxiosError } from 'axios';

// NOTE: Fetching vehicles for a household is already done by getHouseholdDetails in householdService.ts

// UC-04 (SRS pg 20): Add Vehicle to Household
export const addVehicleToHousehold = async (householdId: number, data: VehicleFormData): Promise<Vehicle> => {
  try {
    // Backend endpoint: POST /api/management/households/:household_id/vehicles
    const response = await apiClient.post<{ message: string, vehicleId: number }>(
      `/management/households/${householdId}/vehicles`,
      data
    );
    // Backend returns vehicleId. Return constructed object.
    return { ...data, vehicle_id: response.data.vehicleId, household_id: householdId } as Vehicle;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to add vehicle.');
    }
    throw new Error('An unexpected error occurred while adding the vehicle.');
  }
};

// Update Vehicle
export const updateVehicle = async (vehicleId: number, data: VehicleFormData): Promise<Vehicle> => {
  try {
    // Backend endpoint: PUT /api/management/vehicles/:vehicle_id
    await apiClient.put(`/management/vehicles/${vehicleId}`, data);
    // Backend returns success. Return updated data optimistically.
     // Note: Household ID is typically not changed via this endpoint based on backend structure
    return { ...data, vehicle_id: vehicleId } as Vehicle;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to update vehicle.');
    }
    throw new Error('An unexpected error occurred while updating the vehicle.');
  }
};

// Delete Vehicle
export const deleteVehicle = async (vehicleId: number): Promise<{ message: string }> => {
  try {
    // Backend endpoint: DELETE /api/management/vehicles/:vehicle_id
    const response = await apiClient.delete<{ message: string }>(`/management/vehicles/${vehicleId}`);
    return response.data;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to delete vehicle.');
    }
    throw new Error('An unexpected error occurred while deleting the vehicle.');
  }
};