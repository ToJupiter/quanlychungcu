// BlueMoon Management System API Types

// Re-export User type from auth for convenience
export type { User } from './auth';

// Staff Management
export interface StaffDto {
  staff_id: string;
  full_name: string;
  email: string;
  phone_number: string;
  status: string;
  created_at: string;
  roles: number; // 0 = Admin, 1 = Accountant
  password?: string; // write-only for creation
}

export interface StaffCreateRequest {
  full_name: string;
  email: string;
  phone_number: string;
  password: string;
  status: string;
  roles: number;
}

// Apartment Management
export interface ApartmentDto {
  apartment_id: string;
  apartment_number: string;
  area: number;
  status: string;
}

export interface ApartmentCreateRequest {
  apartment_id?: string; // Optional, backend might auto-generate
  apartment_number: string;
  area: number;
  status: string;
}

// Resident Management
export interface ResidentDto {
  resident_id: string;
  household_id: string;
  full_name: string;
  date_of_birth: string;
  cccd_number: string;
  role_in_household: string;
}

export interface ResidentCreateRequest {
  resident_id?: string;
  household_id: string;
  full_name: string;
  date_of_birth: string;
  cccd_number: string;
  role_in_household: string;
}

// Vehicle Management
export interface VehicleDto {
  vehicle_id: string;
  household_id: string;
  plate_number: string;
  vehicle_type: string;
  registration_date: string;
}

export interface VehicleCreateRequest {
  vehicle_id?: string;
  household_id: string;
  plate_number: string;
  vehicle_type: string;
  registration_date: string;
}

// Household Management
export interface HouseholdDto {
  household_id: string;
  apartment_id: string;
  apartment_number: string;
  apartment_area: number;
  apartment_status: string;
  head_resident_id: string;
  head_full_name: string;
  head_dob: string;
  head_cccd: string;
  move_in_date: string;
  residents: ResidentDto[];
  vehicles: VehicleDto[];
}

export interface HouseholdCreateRequest {
  household_id?: string;
  apartment_id: string;
  move_in_date: string;
  residents: ResidentCreateRequest[];
  vehicles: VehicleCreateRequest[];
}

// Payment Management
export interface PaymentDto {
  payment_id: string;
  household_id: string;
  apartment_id: string;
  apartment_number: string;
  payment_type: string;
  amount: number;
  due_date: string;
  payment_date: string;
  status: string;
  notes: string;
}

export interface PaymentCreateRequest {
  payment_id?: string;
  household_id: string;
  payment_type: string;
  amount: number;
  due_date: string;
  payment_date?: string;
  status: string;
  notes?: string;
}

export interface BulkPaymentRequest {
  payment_type: string;
  amount: number;
  due_date: string;
}

// Analytics Types
export interface DashboardAnalytics {
  totalHouseholds: number;
  totalResidents: number;
  totalVehicles: number;
  totalPayments: number;
  totalRevenue: number;
}

export interface FinancialOverview {
  totalRevenue: number;
  totalDue: number;
  totalPayments: number;
  paidPayments: number;
  unpaidPayments: number;
}

export interface MonthlyRevenue {
  month: string;
  revenue: number;
}

export interface PaymentTypeAnalytics {
  payment_type: string;
  total: number;
}

export interface GeneralOverview {
  totalApartments: number;
  totalHouseholds: number;
  totalResidents: number;
}

export interface VehicleAnalytics {
  totalVehicles: number;
  vehicleTypes: Array<{
    type: string;
    count: number;
  }>;
}

// Common API Response Types
export interface ApiResponse<T> {
  message: string;
  data?: T;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
}

// Role helper interface
export interface UserRoleDTO {
  role: string;
  permissions: string[];
} 