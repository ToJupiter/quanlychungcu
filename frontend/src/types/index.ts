// src/types/index.ts

// User/Staff Type (from JWT payload)
export interface AuthenticatedUser {
  staff_id: number;
  email: string;
  name: string;
  // role?: string; // If you add roles
}

// API Error structure
export interface ApiErrorResponse {
  message: string;
  statusCode?: number;
  // Add other fields your backend might send
}

// Entities (based on your bluemoon_database.sql)
export interface Staff {
  staff_id: number;
  full_name: string;
  email: string;
  phone_number?: string | null;
  status: string; // 'active', 'inactive'
  created_at: string; // ISO date string
}

export interface Apartment {
  apartment_id: number;
  apartment_number: string;
  area?: number | null;
  status?: string | null; // 'occupied', 'vacant'
}

export interface Household {
  household_id: number;
  apartment_id: number;
  move_in_date?: string | null; // ISO date string
  head_of_household_resident_id?: number | null;

  // Joined data from backend queries
  apartment_number?: string;
  head_full_name?: string;
}

export interface Resident {
  resident_id: number;
  household_id?: number | null;
  full_name: string;
  date_of_birth?: string | null; // ISO date string
  cccd_number?: string | null;
  role_in_household?: string | null; // 'Head', 'Member'
}

export interface Vehicle {
  vehicle_id: number;
  household_id: number;
  plate_number: string;
  vehicle_type?: string | null;
  registration_date?: string | null; // ISO date string
}

export interface Payment {
  payment_id: number;
  household_id: number;
  payment_type: string;
  amount: number;
  due_date: string; // ISO date string
  payment_date?: string | null; // ISO date string
  status: string; // 'Paid', 'Unpaid', 'Overdue'

  // Joined data
  apartment_number?: string;
}

// For forms, often partial types or specific DTOs are useful
export type ApartmentFormData = Omit<Apartment, 'apartment_id'>;
export type HouseholdFormData = {
  apartment_id: number;
  move_in_date?: string;
  head_full_name: string;
  head_date_of_birth?: string;
  head_cccd_number?: string;
};
export type ResidentFormData = Omit<Resident, 'resident_id' | 'household_id'> & { household_id?: number };
export type VehicleFormData = Omit<Vehicle, 'vehicle_id' | 'household_id'> & { household_id?: number };
export type PaymentFormData = Omit<Payment, 'payment_id' | 'apartment_number'>;