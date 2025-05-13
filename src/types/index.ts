// src/types/index.ts

// Based on backend responses and database schema

export interface Staff {
  staff_id: number;
  full_name: string;
  email: string;
  phone_number?: string;
  status: 'active' | 'inactive';
  created_at: string;
}

export interface Apartment {
  apartment_id: number;
  apartment_number: string;
  area?: number;
  status?: 'occupied' | 'vacant' | string; // Allow other statuses if any
}

export interface Household {
  household_id: number;
  move_in_date?: string;
  apartment_id: number;
  apartment_number: string;
  apartment_area?: number;
  head_resident_id?: number;
  head_full_name?: string;
  head_cccd?: string;
}

export interface Resident {
  resident_id: number;
  household_id?: number;
  full_name: string;
  date_of_birth?: string;
  cccd_number?: string;
  role_in_household: string;
}

export interface Vehicle {
  vehicle_id: number;
  household_id?: number;
  plate_number: string;
  vehicle_type: string;
  registration_date?: string;
}

export interface Payment {
  payment_id: number;
  household_id: number;
  apartment_number: string; // Joined from Apartments table
  payment_type: string;
  amount: number;
  due_date: string;
  payment_date?: string;
  status: 'Paid' | 'Unpaid' | 'Overdue' | string;
}

export interface AuthUser { // User object stored in AuthContext
  staff_id: number;
  email: string;
  name: string;
}

export interface ApiErrorResponse {
  message: string;
  statusCode?: number;
  status?: string;
}