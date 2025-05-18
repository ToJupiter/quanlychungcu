// src/pages/HouseholdDetailPage.tsx
import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import * as householdService from '../api/householdService';
import * as residentService from '../api/residentService';
import * as vehicleService from '../api/vehicleService';
import * as paymentService from '../api/paymentService'; // Import payment service
import type { Household, Resident, Vehicle, Payment, ResidentFormData, VehicleFormData } from '../types';
import Modal from '../components/common/Modal';
import ResidentForm from '../components/residents/ResidentForm';
import VehicleForm from '../components/vehicles/VehicleForm';


interface HouseholdDetailsState extends Household {
    residents: Resident[];
    vehicles: Vehicle[];
    payments: Payment[]; // Payments array already fetched here
    apartment_area?: number | null;
    apartment_status?: string | null;
    head_resident_id?: number | null;
    head_full_name?: string;
    head_dob?: string | null;
    head_cccd?: string | null;
}


const HouseholdDetailPage: React.FC = () => {
  const { householdId } = useParams<{ householdId: string }>();
  const id = householdId ? parseInt(householdId, 10) : NaN;

  const [householdDetails, setHouseholdDetails] = useState<HouseholdDetailsState | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // State for Resident Modal
  const [isResidentModalOpen, setIsResidentModalOpen] = useState(false);
  const [currentResident, setCurrentResident] = useState<Resident | null>(null); // Resident being edited
  const [residentFormError, setResidentFormError] = useState<string | null>(null);
  const [isResidentSubmitting, setIsResidentSubmitting] = useState(false);

  // State for Vehicle Modal
  const [isVehicleModalOpen, setIsVehicleModalOpen] = useState(false);
  const [currentVehicle, setCurrentVehicle] = useState<Vehicle | null>(null); // Vehicle being edited
  const [vehicleFormError, setVehicleFormError] = useState<string | null>(null);
  const [isVehicleSubmitting, setIsVehicleSubmitting] = useState(false);

   // State for Payment action feedback (within the page, not modal)
  const [paymentActionError, setPaymentActionError] = useState<string | null>(null);
   const [paymentActionSuccess, setPaymentActionSuccess] = useState<string | null>(null);
    const [isPaymentActionLoading, setIsPaymentActionLoading] = useState(false); // Loading state for payment actions


  const fetchDetails = async () => {
        if (isNaN(id)) {
            setError("Invalid Household ID.");
            setIsLoading(false);
            return;
        }
      setIsLoading(true);
      setError(null);
       setPaymentActionError(null); // Clear payment errors on refresh
       setPaymentActionSuccess(null); // Clear payment success on refresh
      try {
        const data = await householdService.getHouseholdDetails(id);
        setHouseholdDetails(data);
      } catch (err: any) {
        setError(err.message || `Failed to fetch details for household ID ${id}.`);
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    };

  useEffect(() => {
    fetchDetails();
  }, [id]); // Re-fetch if householdId changes


    // --- Resident Handlers (from Part 4) ---
    // ... (Keep handleOpenResidentModal, handleCloseResidentModal, handleSubmitResident, handleDeleteResident as they were)
    const handleOpenResidentModal = (resident?: Resident) => {
        setCurrentResident(resident || null);
        setResidentFormError(null);
        setIsResidentModalOpen(true);
    };

    const handleCloseResidentModal = () => {
        setIsResidentModalOpen(false);
        setCurrentResident(null);
        setResidentFormError(null);
    };

    const handleSubmitResident = async (data: ResidentFormData) => {
        if (isNaN(id)) return;

        setIsResidentSubmitting(true);
        setResidentFormError(null);
        try {
            if (currentResident && currentResident.resident_id) {
                await residentService.updateResident(currentResident.resident_id, data);
            } else {
                await residentService.addResidentToHousehold(id, data);
            }
            await fetchDetails();
            handleCloseResidentModal();
        } catch (err: any) {
            setResidentFormError(err.message || 'An error occurred saving resident.');
            console.error(err);
        } finally {
            setIsResidentSubmitting(false);
        }
    };

    const handleDeleteResident = async (residentId: number) => {
        if (isNaN(id)) return;

        if (window.confirm('Are you sure you want to delete this resident? This action cannot be undone.')) {
             if (householdDetails?.head_of_household_resident_id === residentId) {
                 setError("Cannot delete the head of household directly. Please assign a new head or delete the household.");
                 return;
             }

            setIsLoading(true);
            setError(null);
            try {
                await residentService.deleteResident(residentId);
                await fetchDetails();
            } catch (err: any) {
                setError(err.message || 'Failed to delete resident. It might be linked as a head of household or other data.');
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        }
    };
    // --- End Resident Handlers ---

     // --- Vehicle Handlers (from Part 5) ---
    // ... (Keep handleOpenVehicleModal, handleCloseVehicleModal, handleSubmitVehicle, handleDeleteVehicle as they were)
     const handleOpenVehicleModal = (vehicle?: Vehicle) => {
        setCurrentVehicle(vehicle || null);
        setVehicleFormError(null);
        setIsVehicleModalOpen(true);
    };

    const handleCloseVehicleModal = () => {
        setIsVehicleModalOpen(false);
        setCurrentVehicle(null);
        setVehicleFormError(null);
    };

    const handleSubmitVehicle = async (data: VehicleFormData) => {
         if (isNaN(id)) return;

        setIsVehicleSubmitting(true);
        setVehicleFormError(null);
        try {
            if (currentVehicle && currentVehicle.vehicle_id) {
                await vehicleService.updateVehicle(currentVehicle.vehicle_id, data);
            } else {
                await vehicleService.addVehicleToHousehold(id, data);
            }
            await fetchDetails();
            handleCloseVehicleModal();
        } catch (err: any) {
            setVehicleFormError(err.message || 'An error occurred saving vehicle.');
            console.error(err);
        } finally {
            setIsVehicleSubmitting(false);
        }
    };

    const handleDeleteVehicle = async (vehicleId: number) => {
         if (isNaN(id)) return;

        if (window.confirm('Are you sure you want to delete this vehicle? This action cannot be undone.')) {
            setIsLoading(true);
            setError(null);
            try {
                await vehicleService.deleteVehicle(vehicleId);
                await fetchDetails();
            } catch (err: any) {
                setError(err.message || 'Failed to delete vehicle.');
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        }
    };
    // --- End Vehicle Handlers ---

    // --- Payment Handlers (NEW/Modified for actions within details page) ---
    // Note: Add Payment is primarily on the dedicated Finance page now

    const handleUpdatePaymentStatus = async (paymentId: number, newStatus: string) => {
         if (isNaN(id)) return; // Should not happen

         if (window.confirm(`Are you sure you want to mark this payment as ${newStatus}?`)) {
            setIsPaymentActionLoading(true); // Use specific loading for payment actions
            setPaymentActionError(null);
             setPaymentActionSuccess(null);
            try {
                 await paymentService.updatePaymentStatus(paymentId, { status: newStatus });
                 setPaymentActionSuccess(`Payment status updated to ${newStatus}.`);
                 await fetchDetails(); // Refresh details
            } catch (err: any) {
                setPaymentActionError(err.message || `Failed to update payment status to ${newStatus}.`);
                console.error(err);
            } finally {
                setIsPaymentActionLoading(false);
            }
         }
    };

     const handleDeletePayment = async (paymentId: number) => {
         if (isNaN(id)) return; // Should not happen

        if (window.confirm('Are you sure you want to delete this payment record? This cannot be undone.')) {
             setIsPaymentActionLoading(true); // Use specific loading for payment actions
             setPaymentActionError(null);
             setPaymentActionSuccess(null);
            try {
                await paymentService.deletePayment(paymentId);
                setPaymentActionSuccess('Payment record deleted.');
                await fetchDetails(); // Refresh details
            } catch (err: any) {
                setPaymentActionError(err.message || 'Failed to delete payment.');
                console.error(err);
            } finally {
                setIsPaymentActionLoading(false);
            }
        }
    };
    // --- End Payment Handlers ---


  if (isLoading) {
    return <p>Loading household details...</p>;
  }

  if (error) {
    return <p className="error-message">{error}</p>;
  }

  if (!householdDetails) {
      return <p>Household details not found.</p>;
  }

  return (
    <div>
      <div className="page-header">
        <h1>Household Details for Apartment {householdDetails.apartment_number}</h1>
         {/* Add Edit/Delete Household buttons here if implemented */}
      </div>

      <div style={{ marginBottom: '2rem' }}>
          <h3>General Information</h3>
          <p><strong>Household ID:</strong> {householdDetails.household_id}</p>
          <p><strong>Apartment:</strong> {householdDetails.apartment_number} (Area: {householdDetails.apartment_area} sqm, Status: {householdDetails.apartment_status})</p>
          <p><strong>Move In Date:</strong> {householdDetails.move_in_date ? new Date(householdDetails.move_in_date).toLocaleDateString() : 'N/A'}</p>
          <p><strong>Head of Household:</strong> {householdDetails.head_full_name || 'N/A'} (CCCD: {householdDetails.head_cccd || 'N/A'})</p>
           {/* Display the general error here if needed */}
           {error && <p className="error-message" style={{ marginTop: '1rem' }}>{error}</p>}
      </div>

      {/* Residents Section (from Part 4) */}
      <div style={{ marginBottom: '2rem' }}>
        <div className="page-header" style={{ marginBottom: '1rem', borderBottom: '1px solid #eee', paddingBottom: '0.5rem'}}>
            <h3>Residents</h3>
            <button onClick={() => handleOpenResidentModal()}>Add Resident</button>
        </div>
        {householdDetails.residents.length === 0 ? (
            <p>No residents listed for this household yet.</p>
        ) : (
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Full Name</th>
                        <th>Date of Birth</th>
                        <th>CCCD</th>
                        <th>Role</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {householdDetails.residents.map(resident => (
                        <tr key={resident.resident_id}>
                            <td>{resident.resident_id}</td>
                            <td>{resident.full_name}</td>
                            <td>{resident.date_of_birth ? new Date(resident.date_of_birth).toLocaleDateString() : 'N/A'}</td>
                            <td>{resident.cccd_number || 'N/A'}</td>
                            <td>{resident.role_in_household || 'N/A'}</td>
                            <td>
                                <button onClick={() => handleOpenResidentModal(resident)} style={{ marginRight: '0.5rem', backgroundColor: '#ffc107', color: '#212529'}}>Edit</button>
                                <button onClick={() => handleDeleteResident(resident.resident_id)} style={{ backgroundColor: '#dc3545'}}>Delete</button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        )}
      </div>

      {/* Vehicles Section (from Part 5) */}
       <div style={{ marginBottom: '2rem' }}>
        <div className="page-header" style={{ marginBottom: '1rem', borderBottom: '1px solid #eee', paddingBottom: '0.5rem'}}>
            <h3>Vehicles</h3>
             <button onClick={() => handleOpenVehicleModal()}>Add Vehicle</button>
        </div>
        {householdDetails.vehicles.length === 0 ? (
            <p>No vehicles listed for this household yet.</p>
        ) : (
             <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Plate Number</th>
                        <th>Type</th>
                        <th>Registration Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                 <tbody>
                    {householdDetails.vehicles.map(vehicle => (
                        <tr key={vehicle.vehicle_id}>
                            <td>{vehicle.vehicle_id}</td>
                            <td>{vehicle.plate_number}</td>
                            <td>{vehicle.vehicle_type || 'N/A'}</td>
                            <td>{vehicle.registration_date ? new Date(vehicle.registration_date).toLocaleDateString() : 'N/A'}</td>
                             <td>
                                <button onClick={() => handleOpenVehicleModal(vehicle)} style={{ marginRight: '0.5rem', backgroundColor: '#ffc107', color: '#212529'}}>Edit</button>
                                <button onClick={() => handleDeleteVehicle(vehicle.vehicle_id)} style={{ backgroundColor: '#dc3545'}}>Delete</button>
                             </td>
                        </tr>
                    ))}
                 </tbody>
             </table>
        )}
      </div>

      {/* Payments Section (Part 6 - Actions added here) */}
       <div style={{ marginBottom: '2rem' }}>
        <div className="page-header" style={{ marginBottom: '1rem', borderBottom: '1px solid #eee', paddingBottom: '0.5rem'}}>
            <h3>Payments</h3>
             {/* Add Payment button is on the dedicated Finance page */}
             {/* <button>Add Payment</button> */}
        </div>
         {isPaymentActionLoading && <p>Processing payment action...</p>}
         {paymentActionError && <p className="error-message">{paymentActionError}</p>}
         {paymentActionSuccess && <p className="success-message">{paymentActionSuccess}</p>}

        {householdDetails.payments.length === 0 ? (
            <p>No payments listed for this household yet.</p>
        ) : (
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type</th>
                        <th>Amount</th>
                        <th>Due Date</th>
                        <th>Payment Date</th>
                        <th>Status</th>
                         <th>Actions</th>
                    </tr>
                </thead>
                 <tbody>
                    {householdDetails.payments.map(payment => (
                        <tr key={payment.payment_id}>
                            <td>{payment.payment_id}</td>
                            <td>{payment.payment_type}</td>
                            <td>{payment.amount.toFixed(2)}</td>
                            <td>{new Date(payment.due_date).toLocaleDateString()}</td>
                            <td>{payment.payment_date ? new Date(payment.payment_date).toLocaleDateString() : 'N/A'}</td>
                            <td>{payment.status}</td>
                             <td>
                                 {/* Actions: Mark Paid/Unpaid, Delete */}
                                  {payment.status === 'Unpaid' && (
                                      <button onClick={() => handleUpdatePaymentStatus(payment.payment_id, 'Paid')} style={{ marginRight: '0.5rem', backgroundColor: '#28a745', color: 'white'}}>Mark Paid</button>
                                  )}
                                   {payment.status === 'Paid' && (
                                      <button onClick={() => handleUpdatePaymentStatus(payment.payment_id, 'Unpaid')} style={{ marginRight: '0.5rem', backgroundColor: '#ffc107', color: '#212529'}}>Mark Unpaid</button>
                                   )}
                                   <button onClick={() => handleDeletePayment(payment.payment_id)} style={{ backgroundColor: '#dc3545'}}>Delete</button>
                             </td>
                        </tr>
                    ))}
                 </tbody>
            </table>
        )}
      </div>

        {/* Resident Add/Edit Modal (from Part 4) */}
        <Modal
            isOpen={isResidentModalOpen}
            onClose={handleCloseResidentModal}
            title={currentResident ? 'Edit Resident' : 'Add New Resident'}
        >
            <ResidentForm
                onSubmit={handleSubmitResident}
                initialData={currentResident}
                onCancel={handleCloseResidentModal}
                isLoading={isResidentSubmitting}
                errorMessage={residentFormError}
            />
        </Modal>

         {/* Vehicle Add/Edit Modal (from Part 5) */}
        <Modal
            isOpen={isVehicleModalOpen}
            onClose={handleCloseVehicleModal}
            title={currentVehicle ? 'Edit Vehicle' : 'Add New Vehicle'}
        >
            <VehicleForm
                onSubmit={handleSubmitVehicle}
                initialData={currentVehicle}
                onCancel={handleCloseVehicleModal}
                isLoading={isVehicleSubmitting}
                errorMessage={vehicleFormError}
            />
        </Modal>

         {/* Note: No Payment Add/Edit Modal on this page, using dedicated Finance page */}

    </div>
  );
};

export default HouseholdDetailPage;