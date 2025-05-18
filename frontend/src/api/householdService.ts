// src/api/householdService.ts
import apiClient from './apiClient';
import type { Household, HouseholdFormData, Resident, Vehicle, Payment, Apartment, ApiErrorResponse } from '../types/index.ts';
import { AxiosError } from 'axios';

interface HouseholdDetails extends Household {
    residents: Resident[];
    vehicles: Vehicle[];
    payments: Payment[];
    apartment_area?: number | null;
    apartment_status?: string | null;
    head_resident_id?: number | null;
    head_full_name?: string;
    head_dob?: string | null;
    head_cccd?: string | null;
}


export const getHouseholds = async (): Promise<Household[]> => {
  try {
    const response = await apiClient.get<Household[]>('/management/households');
    return response.data;
  } catch (error) {
    console.error("Error fetching households:", error);
    throw error;
  }
};

// Assuming backend endpoint exists as per inferred from SDD/SRS
export const getHouseholdDetails = async (id: number): Promise<HouseholdDetails> => {
    try {
        // This endpoint structure is assumed based on the need to fetch details for a page
        // If your backend uses a different path (e.g., nested under apartments), adjust here.
        const response = await apiClient.get<HouseholdDetails>(`/management/households/${id}/details`);
        return response.data;
    } catch (error) {
        console.error(`Error fetching household details with id ${id}:`, error);
         const axiosError = error as AxiosError<ApiErrorResponse>;
         if (axiosError.response && axiosError.response.data) {
             throw new Error(axiosError.response.data.message || `Failed to fetch household details ${id}.`);
         }
        throw new Error(`An unexpected error occurred while fetching household details ${id}.`);
    }
}


// UC-04 Add Household (with Head Resident)
export const createHouseholdWithHead = async (data: HouseholdFormData): Promise<{ householdId: number, headResidentId: number }> => {
  try {
    // This endpoint matches the controller structure from Part 1
    const response = await apiClient.post<{ message: string, householdId: number, headResidentId: number }>('/management/households', data);
    return response.data;
  } catch (error) {
    const axiosError = error as AxiosError<ApiErrorResponse>;
    if (axiosError.response && axiosError.response.data) {
        throw new Error(axiosError.response.data.message || 'Failed to create household.');
    }
    throw new Error('An unexpected error occurred while creating the household.');
  }
};

// We might need update/delete household functions later, but they weren't explicitly
// implemented in the backend controller snippet, so we'll omit them for now
// or assume they would follow a similar pattern if added to the backend.

// We'll also need functions for Residents, Vehicles, Payments linked to a household,
// but those will be in separate service files for Part 4 and 5.
// However, getting apartments list is needed for the HouseholdForm, so import apartment service.
import { getApartments } from './apartmentService';
export { getApartments }; // Export getApartments from here for convenience in HouseholdForm if needed