import axios, { AxiosInstance, AxiosResponse, AxiosError } from 'axios';
import type { 
  User, 
  LoginRequest, 
  LoginResponse, 
  RegisterRequest,
  ApiError
} from '../types/auth';
import type {
  StaffDto,
  StaffCreateRequest,
  ApartmentDto,
  ApartmentCreateRequest,
  HouseholdDto,
  HouseholdCreateRequest,
  ResidentDto,
  ResidentCreateRequest,
  VehicleDto,
  VehicleCreateRequest,
  PaymentDto,
  PaymentCreateRequest,
  BulkPaymentRequest,
  DashboardAnalytics,
  FinancialOverview,
  MonthlyRevenue,
  PaymentTypeAnalytics,
  GeneralOverview,
  VehicleAnalytics,
  UserRoleDTO
} from '../types/api';

class ApiService {
  private api: AxiosInstance;
  private static instance: ApiService;

  private constructor() {
    this.api = axios.create({
      baseURL: 'http://localhost:3001/api', // BlueMoon backend URL
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor to add JWT token
    this.api.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('auth-token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Response interceptor to handle errors globally
    this.api.interceptors.response.use(
      (response: AxiosResponse) => {
        return response;
      },
      (error: AxiosError) => {
        const apiError: ApiError = {
          message: 'Unknown error occurred',
          status: error.response?.status,
        };

        if (error.response?.data) {
          const errorData = error.response.data as any;
          apiError.message = errorData.message || errorData.error || 'Unknown error occurred';
          apiError.errors = errorData.errors;
          apiError.statusCode = errorData.statusCode;
          apiError.timestamp = errorData.timestamp;
        } else if (error.message) {
          apiError.message = error.message;
        }

        console.error('API Error:', apiError);
        throw apiError;
      }
    );
  }

  public static getInstance(): ApiService {
    if (!ApiService.instance) {
      ApiService.instance = new ApiService();
    }
    return ApiService.instance;
  }

  // Authentication endpoints
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const response = await this.api.post<LoginResponse>('/auth/staff/login', credentials);
    if (response.data.token) {
      localStorage.setItem('auth-token', response.data.token);
      localStorage.setItem('user-info', JSON.stringify(response.data.user));
    }
    return response.data;
  }

  async register(userData: RegisterRequest): Promise<{ message: string; staffId: string }> {
    const response = await this.api.post<{ message: string; staffId: string }>('/auth/staff/register', userData);
    return response.data;
  }

  async changePassword(data: { email: string; oldPassword: string; newPassword: string }): Promise<{ message: string }> {
    const response = await this.api.post<{ message: string }>('/auth/staff/change-password', data);
    return response.data;
  }

  async logout(): Promise<void> {
    localStorage.removeItem('auth-token');
    localStorage.removeItem('user-info');
  }

  // Staff endpoints (Admin only)
  async getAllStaff(): Promise<StaffDto[]> {
    const response = await this.api.get<StaffDto[]>('/staff');
    return response.data;
  }

  async getStaffById(id: string): Promise<StaffDto> {
    const response = await this.api.get<StaffDto>(`/staff/${id}`);
    return response.data;
  }

  async createStaff(staffData: StaffCreateRequest): Promise<{ message: string; staffId: string }> {
    const response = await this.api.post<{ message: string; staffId: string }>('/staff', staffData);
    return response.data;
  }

  async updateStaff(id: string, staffData: Partial<StaffDto>): Promise<{ message: string }> {
    const response = await this.api.put<{ message: string }>(`/staff/${id}`, staffData);
    return response.data;
  }

  async updateStaffStatus(id: string, status: string): Promise<{ message: string }> {
    const response = await this.api.patch<{ message: string }>(`/staff/${id}/status`, { status });
    return response.data;
  }

  async resetStaffPassword(id: string, password: string): Promise<{ message: string }> {
    const response = await this.api.patch<{ message: string }>(`/staff/${id}/reset-password`, { password });
    return response.data;
  }

  async deleteStaff(id: string): Promise<{ message: string }> {
    const response = await this.api.delete<{ message: string }>(`/staff/${id}`);
    return response.data;
  }

  // Apartment endpoints (Admin only)
  async getAllApartments(): Promise<ApartmentDto[]> {
    const response = await this.api.get<ApartmentDto[]>('/management/apartments');
    return response.data;
  }

  async getApartmentById(id: string): Promise<ApartmentDto> {
    const response = await this.api.get<ApartmentDto>(`/management/apartments/${id}`);
    return response.data;
  }

  async createApartment(apartmentData: ApartmentCreateRequest): Promise<ApartmentDto> {
    const response = await this.api.post<ApartmentDto>('/management/apartments', apartmentData);
    return response.data;
  }

  // Household endpoints (Admin only)
  async getAllHouseholds(): Promise<HouseholdDto[]> {
    const response = await this.api.get<HouseholdDto[]>('/management/households');
    return response.data;
  }

  async getHouseholdById(id: string): Promise<HouseholdDto> {
    const response = await this.api.get<HouseholdDto>(`/management/households/${id}`);
    return response.data;
  }

  async createHousehold(householdData: HouseholdCreateRequest): Promise<HouseholdDto> {
    const dataWithId = {
      ...householdData,
      household_id: householdData.household_id || this.generateUUID(),
    };
    const response = await this.api.post<HouseholdDto>('/management/households', dataWithId);
    return response.data;
  }

  async deleteHousehold(householdId: string): Promise<{ message: string }> {
    const response = await this.api.delete<{ message: string }>(`/management/households/${householdId}`);
    return response.data;
  }

  async updateHousehold(householdId: string, householdData: Partial<HouseholdDto>): Promise<{ message: string }> {
    const response = await this.api.put<{ message: string }>(`/management/households/${householdId}`, householdData);
    return response.data;
  }

  // Resident endpoints (Admin only)
  async getResidentsByHousehold(householdId: string): Promise<ResidentDto[]> {
    const response = await this.api.get<ResidentDto[]>(`/management/households/${householdId}/residents`);
    return response.data;
  }

  async createResident(householdId: string, residentData: ResidentCreateRequest): Promise<ResidentDto> {
    const response = await this.api.post<ResidentDto>(`/management/households/${householdId}/residents`, residentData);
    return response.data;
  }

  async updateResident(residentId: string, residentData: Partial<ResidentDto>): Promise<ResidentDto> {
    const response = await this.api.put<ResidentDto>(`/management/residents/${residentId}`, residentData);
    return response.data;
  }

  async deleteResident(residentId: string): Promise<{ message: string }> {
    const response = await this.api.delete<{ message: string }>(`/management/residents/${residentId}`);
    return response.data;
  }

  // Vehicle endpoints (Admin only)
  async getVehiclesByHousehold(householdId: string): Promise<VehicleDto[]> {
    const response = await this.api.get<VehicleDto[]>(`/management/households/${householdId}/vehicles`);
    return response.data;
  }

  async createVehicle(householdId: string, vehicleData: VehicleCreateRequest): Promise<VehicleDto> {
    const response = await this.api.post<VehicleDto>(`/management/households/${householdId}/vehicles`, vehicleData);
    return response.data;
  }

  async updateVehicle(vehicleId: string, vehicleData: Partial<VehicleDto>): Promise<VehicleDto> {
    const response = await this.api.put<VehicleDto>(`/management/vehicles/${vehicleId}`, vehicleData);
    return response.data;
  }

  async deleteVehicle(vehicleId: string): Promise<{ message: string }> {
    const response = await this.api.delete<{ message: string }>(`/management/vehicles/${vehicleId}`);
    return response.data;
  }

  // Payment endpoints (Admin/Accountant)
  async getPaymentsByHousehold(householdId: string): Promise<PaymentDto[]> {
    const response = await this.api.get<PaymentDto[]>(`/finance/households/${householdId}/payments`);
    return response.data;
  }

  async createPayment(paymentData: PaymentCreateRequest): Promise<PaymentDto> {
    const response = await this.api.post<PaymentDto>('/finance/payments', paymentData);
    return response.data;
  }

  async createBulkPayments(bulkData: BulkPaymentRequest): Promise<{ message: string; count: number }> {
    const response = await this.api.post<{ message: string; count: number }>('/finance/payments/bulk', bulkData);
    return response.data;
  }

  async updatePaymentStatus(paymentId: string, status: string, paymentDate?: string): Promise<{ message: string }> {
    const response = await this.api.patch<{ message: string }>(`/finance/payments/${paymentId}/status`, { status, payment_date: paymentDate });
    return response.data;
  }

  async updatePayment(paymentId: string, paymentData: Partial<PaymentDto>): Promise<PaymentDto> {
    const response = await this.api.put<PaymentDto>(`/finance/payments/${paymentId}`, paymentData);
    return response.data;
  }

  async deletePayment(paymentId: string): Promise<{ message: string }> {
    const response = await this.api.delete<{ message: string }>(`/finance/payments/${paymentId}`);
    return response.data;
  }

  async getFinancialSummary(): Promise<any> {
    const response = await this.api.get('/finance/reports/financial-summary');
    return response.data;
  }

  async getDashboardStats(): Promise<any> {
    const response = await this.api.get('/finance/dashboard/stats');
    return response.data;
  }

  // Analytics endpoints (Admin/Accountant)
  async getDashboardAnalytics(): Promise<DashboardAnalytics> {
    const response = await this.api.get<DashboardAnalytics>('/analytics/dashboard');
    return response.data;
  }

  async getFinancialOverview(): Promise<FinancialOverview> {
    const response = await this.api.get<FinancialOverview>('/analytics/financial/overview');
    return response.data;
  }

  async getMonthlyRevenue(): Promise<MonthlyRevenue[]> {
    const response = await this.api.get<MonthlyRevenue[]>('/analytics/financial/monthly-revenue');
    return response.data;
  }

  async getPaymentTypeAnalytics(): Promise<PaymentTypeAnalytics[]> {
    const response = await this.api.get<PaymentTypeAnalytics[]>('/analytics/financial/payment-types');
    return response.data;
  }

  async getGeneralOverview(): Promise<GeneralOverview> {
    const response = await this.api.get<GeneralOverview>('/analytics/general/overview');
    return response.data;
  }

  async getVehicleAnalytics(): Promise<VehicleAnalytics> {
    const response = await this.api.get<VehicleAnalytics>('/analytics/general/vehicles');
    return response.data;
  }

  // Convenience method to get current user info
  async getCurrentUser(): Promise<User> {
    // We'll need to store user info from login response
    const userInfo = localStorage.getItem('user-info');
    if (userInfo) {
      return JSON.parse(userInfo);
    }
    throw new Error('No user information available');
  }

  // Helper method to generate UUID
  private generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
}

const apiService = ApiService.getInstance();
export default apiService; 