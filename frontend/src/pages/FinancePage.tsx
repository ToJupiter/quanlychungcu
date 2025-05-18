// src/pages/FinancePage.tsx
import React, { useEffect, useState } from 'react';
import type { Payment, PaymentFormData } from '../types';
import * as paymentService from '../api/paymentService';
import Modal from '../components/common/Modal';
import PaymentForm from '../components/payments/PaymentForm';

const FinancePage: React.FC = () => {
  const [payments, setPayments] = useState<Payment[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  // State for filters (optional, but good for Finance page)
  const [filterStatus, setFilterStatus] = useState('');
  const [filterHouseholdId, setFilterHouseholdId] = useState(''); // Could fetch households for a dropdown
  // Add date filters later if needed


  const fetchPayments = async (filters = {}) => {
    setIsLoading(true);
    setError(null);
    setSuccessMessage(null); // Clear success message on new fetch
    try {
      const data = await paymentService.getAllPayments(filters);
      setPayments(data);
    } catch (err) {
      setError('Failed to fetch payments. Please try again.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    // Initial fetch
    fetchPayments();
  }, []);

  // Effect to re-fetch when filters change
  useEffect(() => {
      const filters = {
        ...(filterStatus && { status: filterStatus }),
        ...(filterHouseholdId && { householdId: parseInt(filterHouseholdId, 10) }),
        // Add date filters here
      };
      fetchPayments(filters);
  }, [filterStatus, filterHouseholdId]);


  const handleOpenModal = () => {
    setFormError(null);
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setFormError(null);
     // No currentPayment state here as we only Add on this page
  };

  const handleSubmitPayment = async (data: PaymentFormData) => {
    setIsSubmitting(true);
    setFormError(null);
    try {
      await paymentService.createPayment(data);
      setSuccessMessage('Payment created successfully!');
      await fetchPayments({
           ...(filterStatus && { status: filterStatus }),
           ...(filterHouseholdId && { householdId: parseInt(filterHouseholdId, 10) }),
      }); // Refresh list with current filters
      handleCloseModal();
    } catch (err: any) {
        setFormError(err.message || 'An error occurred creating payment.');
        console.error(err);
    } finally {
        setIsSubmitting(false);
    }
  };

  const handleUpdateStatus = async (paymentId: number, newStatus: string) => {
       if (window.confirm(`Are you sure you want to mark this payment as ${newStatus}?`)) {
            setIsLoading(true); // Use main loading state for status update feedback
            setError(null);
             setSuccessMessage(null);
            try {
                // Backend handles setting payment_date if status is 'Paid'
                await paymentService.updatePaymentStatus(paymentId, { status: newStatus });
                setSuccessMessage(`Payment status updated to ${newStatus} successfully.`);
                 await fetchPayments({
                   ...(filterStatus && { status: filterStatus }),
                   ...(filterHouseholdId && { householdId: parseInt(filterHouseholdId, 10) }),
                }); // Refresh list with current filters
            } catch (err: any) {
                setError(err.message || 'Failed to update payment status.');
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        }
  };

  const handleDeletePayment = async (paymentId: number) => {
      if (window.confirm('Are you sure you want to delete this payment record? This cannot be undone.')) {
            setIsLoading(true); // Use main loading state for delete feedback
            setError(null);
            setSuccessMessage(null);
            try {
                await paymentService.deletePayment(paymentId);
                 setSuccessMessage('Payment deleted successfully.');
                await fetchPayments({
                   ...(filterStatus && { status: filterStatus }),
                   ...(filterHouseholdId && { householdId: parseInt(filterHouseholdId, 10) }),
                }); // Refresh list with current filters
            } catch (err: any) {
                setError(err.message || 'Failed to delete payment.');
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        }
  };


  if (isLoading && payments.length === 0) { // Show loading only on initial load or if list is empty
    return <p>Loading payments...</p>;
  }

  return (
    <div>
      <div className="page-header">
        <h1>Finance & Payment Management</h1>
        <button onClick={() => handleOpenModal()}>Create New Payment</button>
      </div>

      {successMessage && <p className="success-message">{successMessage}</p>}
      {error && <p className="error-message">{error}</p>}

      {/* Filter Section */}
      <div style={{ marginBottom: '1.5rem', padding: '1rem', backgroundColor: 'white', borderRadius: '8px', boxShadow: '0 1px 5px rgba(0,0,0,0.05)'}}>
          <h3>Filters</h3>
          <div style={{ display: 'flex', gap: '1rem', alignItems: 'flex-end' }}>
               <div>
                <label htmlFor="filterStatus" style={{display: 'block', marginBottom: '0.5rem'}}>Status:</label>
                <select
                  id="filterStatus"
                  value={filterStatus}
                  onChange={(e) => setFilterStatus(e.target.value)}
                   style={{padding: '0.5rem', border: '1px solid #ccc', borderRadius: '4px'}}
                >
                  <option value="">All Statuses</option>
                  <option value="Unpaid">Unpaid</option>
                  <option value="Paid">Paid</option>
                   <option value="Overdue">Overdue</option>
                </select>
              </div>
               {/* To implement household filter dropdown, you'd need to fetch households here */}
               {/* <div>
                   <label htmlFor="filterHousehold" style={{display: 'block', marginBottom: '0.5rem'}}>Household:</label>
                    <input type="text" placeholder="Household ID" value={filterHouseholdId} onChange={(e) => setFilterHouseholdId(e.target.value)} style={{padding: '0.5rem', border: '1px solid #ccc', borderRadius: '4px'}} />
               </div> */}
                {/* Add Date range filters here */}
          </div>
      </div>


      {isLoading && payments.length > 0 && <p>Refreshing payments...</p>} {/* Show refreshing if list is already populated */}
      {payments.length === 0 && !isLoading && <p>No payments found matching the criteria.</p>}

      {payments.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Apartment</th> {/* Joined data from backend */}
              <th>Household ID</th>
              <th>Type</th>
              <th>Amount</th>
              <th>Due Date</th>
              <th>Payment Date</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {payments.map((p) => (
              <tr key={p.payment_id}>
                <td>{p.payment_id}</td>
                <td>{p.apartment_number || 'N/A'}</td> {/* Display joined apartment number */}
                <td>{p.household_id}</td>
                <td>{p.payment_type}</td>
                <td>{p.amount.toFixed(2)}</td>
                <td>{new Date(p.due_date).toLocaleDateString()}</td>
                <td>{p.payment_date ? new Date(p.payment_date).toLocaleDateString() : 'N/A'}</td>
                <td>{p.status}</td>
                <td>
                  {/* Actions: Mark Paid/Unpaid, Delete */}
                  {p.status === 'Unpaid' && (
                      <button onClick={() => handleUpdateStatus(p.payment_id, 'Paid')} style={{ marginRight: '0.5rem', backgroundColor: '#28a745', color: 'white' }}>Mark Paid</button>
                  )}
                   {p.status === 'Paid' && (
                      <button onClick={() => handleUpdateStatus(p.payment_id, 'Unpaid')} style={{ marginRight: '0.5rem', backgroundColor: '#ffc107', color: '#212529'}}>Mark Unpaid</button>
                   )}
                  {/* Add Edit button if you want to allow editing details other than status */}
                   <button onClick={() => handleDeletePayment(p.payment_id)} style={{ backgroundColor: '#dc3545'}}>Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <Modal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={'Create New Payment'}
      >
        <PaymentForm
          onSubmit={handleSubmitPayment}
          onCancel={handleCloseModal}
          isLoading={isSubmitting}
          errorMessage={formError}
        />
      </Modal>
    </div>
  );
};

export default FinancePage;