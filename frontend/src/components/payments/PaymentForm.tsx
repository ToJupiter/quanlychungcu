// src/components/payments/PaymentForm.tsx
import React, { useState, useEffect, } from 'react';
import type {FormEvent } from 'react';
import type { PaymentFormData, Household } from '../../types';
import { getHouseholds } from '../../api/paymentService'; // Use the re-exported function

interface PaymentFormProps {
  onSubmit: (data: PaymentFormData) => Promise<void>;
  onCancel: () => void;
  isLoading: boolean;
  errorMessage?: string | null;
}

const PaymentForm: React.FC<PaymentFormProps> = ({
  onSubmit,
  onCancel,
  isLoading,
  errorMessage
}) => {
  const [formData, setFormData] = useState<PaymentFormData>({
    household_id: 0, // Needs to be selected
    payment_type: '',
    amount: 0,
    due_date: '',
    payment_date: '', // Optional, for marking as paid during creation
    status: 'Unpaid', // Default status
  });
  const [households, setHouseholds] = useState<Household[]>([]);
  const [householdsLoading, setHouseholdsLoading] = useState(true);
  const [householdsError, setHouseholdsError] = useState<string | null>(null);

  useEffect(() => {
    const fetchHouseholdOptions = async () => {
      setHouseholdsLoading(true);
      setHouseholdsError(null);
      try {
        const data = await getHouseholds();
        setHouseholds(data);
         if (data.length > 0) {
            setFormData(prev => ({ ...prev, household_id: data[0].household_id }));
        }
      } catch (err) {
        setHouseholdsError('Failed to load household options.');
        console.error(err);
      } finally {
        setHouseholdsLoading(false);
      }
    };
    fetchHouseholdOptions();
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
       [name]: name === 'household_id' ? parseInt(value, 10) : name === 'amount' ? parseFloat(value) : value,
    }));
  };

   const handleSubmit = (e: FormEvent) => {
        e.preventDefault();
        // Basic validation
        if (formData.household_id <= 0 || !formData.payment_type || isNaN(formData.amount) || formData.amount <= 0 || !formData.due_date) {
            alert("Please select a household, enter payment type, a positive amount, and due date.");
            return;
        }

        onSubmit(formData);
    };


  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="household_id">Household / Apartment:</label>
        {householdsLoading ? (
            <p>Loading households...</p>
        ) : householdsError ? (
            <p className="error-message">{householdsError}</p>
        ) : households.length === 0 ? (
            <p>No households available to assign payments.</p>
        ) : (
             <select
                id="household_id"
                name="household_id"
                value={formData.household_id}
                onChange={handleChange}
                required
                disabled={isLoading || householdsLoading}
             >
                <option value={0}>-- Select Household --</option>
                {households.map(h => (
                    <option key={h.household_id} value={h.household_id}>
                         Household {h.household_id} (Apt {h.apartment_number}) - {h.head_full_name || 'N/A Head'}
                    </option>
                ))}
             </select>
        )}
      </div>
      <div>
        <label htmlFor="payment_type">Payment Type:</label>
        <input
          type="text"
          id="payment_type"
          name="payment_type"
          value={formData.payment_type}
          onChange={handleChange}
          required
          disabled={isLoading}
        />
      </div>
       <div>
        <label htmlFor="amount">Amount:</label>
        <input
          type="number"
          id="amount"
          name="amount"
          value={formData.amount}
          onChange={handleChange}
          required
          step="0.01"
          min="0.01"
          disabled={isLoading}
        />
      </div>
       <div>
        <label htmlFor="due_date">Due Date:</label>
        <input
          type="date"
          id="due_date"
          name="due_date"
          value={formData.due_date || ''}
          onChange={handleChange}
          required
          disabled={isLoading}
        />
      </div>
       <div>
        <label htmlFor="status">Status:</label>
        <select
          id="status"
          name="status"
          value={formData.status || 'Unpaid'}
          onChange={handleChange}
          required
          disabled={isLoading}
        >
          <option value="Unpaid">Unpaid</option>
          <option value="Paid">Paid</option>
           <option value="Overdue">Overdue</option> {/* Assuming this status exists */}
        </select>
      </div>
       {/* Optionally allow setting payment date if status is Paid */}
       {formData.status === 'Paid' && (
            <div>
                <label htmlFor="payment_date">Payment Date:</label>
                 <input
                    type="date"
                    id="payment_date"
                    name="payment_date"
                    value={formData.payment_date || ''}
                    onChange={handleChange}
                    disabled={isLoading}
                />
            </div>
       )}


      {errorMessage && <p className="error-message" style={{ marginTop: '1rem' }}>{errorMessage}</p>}

      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '1rem', marginTop: '1rem' }}>
        <button type="button" onClick={onCancel} disabled={isLoading} style={{ backgroundColor: '#6c757d' }}>
          Cancel
        </button>
        <button type="submit" disabled={isLoading}>
          {isLoading ? 'Saving...' : 'Create Payment'}
        </button>
      </div>
    </form>
  );
};

export default PaymentForm;