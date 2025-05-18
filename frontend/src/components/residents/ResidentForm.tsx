// src/components/residents/ResidentForm.tsx
import React, { useState, useEffect, } from 'react';
import type {FormEvent } from 'react';
import type { Resident, ResidentFormData } from '../../types';

interface ResidentFormProps {
  onSubmit: (data: ResidentFormData) => Promise<void>;
  initialData?: Resident | null;
  onCancel: () => void;
  isLoading: boolean;
  errorMessage?: string | null;
}

const ResidentForm: React.FC<ResidentFormProps> = ({
  onSubmit,
  initialData,
  onCancel,
  isLoading,
  errorMessage
}) => {
  const [formData, setFormData] = useState<ResidentFormData>({
    full_name: '',
    date_of_birth: '',
    cccd_number: '',
    role_in_household: '',
  });

  useEffect(() => {
    if (initialData) {
      setFormData({
        full_name: initialData.full_name,
        date_of_birth: initialData.date_of_birth || '', // Ensure date is string or empty
        cccd_number: initialData.cccd_number || '',
        role_in_household: initialData.role_in_household || '',
      });
    } else {
      // Reset for new form
       setFormData({
        full_name: '',
        date_of_birth: '',
        cccd_number: '',
        role_in_household: '',
      });
    }
  }, [initialData]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    if (!formData.full_name || !formData.role_in_household) {
        alert("Full name and role are required.");
        return;
    }
    // Optional: Add more validation for date formats, CCCD length etc.

    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="full_name">Full Name:</label>
        <input
          type="text"
          id="full_name"
          name="full_name"
          value={formData.full_name}
          onChange={handleChange}
          required
          disabled={isLoading}
        />
      </div>
      <div>
        <label htmlFor="date_of_birth">Date of Birth:</label>
        <input
          type="date"
          id="date_of_birth"
          name="date_of_birth"
          value={formData.date_of_birth || ''}
          onChange={handleChange}
          disabled={isLoading}
        />
      </div>
       <div>
        <label htmlFor="cccd_number">CCCD Number:</label>
        <input
          type="text"
          id="cccd_number"
          name="cccd_number"
          value={formData.cccd_number || ''}
          onChange={handleChange}
          disabled={isLoading}
        />
      </div>
      <div>
        <label htmlFor="role_in_household">Role in Household:</label>
        <select
          id="role_in_household"
          name="role_in_household"
          value={formData.role_in_household || ''}
          onChange={handleChange}
          required
          disabled={isLoading}
        >
          <option value="">-- Select Role --</option>
          <option value="Head">Head</option>
          <option value="Member">Member</option>
           <option value="Tenant">Tenant</option> {/* Add other roles if needed */}
        </select>
      </div>

      {errorMessage && <p className="error-message" style={{ marginTop: '1rem' }}>{errorMessage}</p>}

      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '1rem', marginTop: '1rem' }}>
        <button type="button" onClick={onCancel} disabled={isLoading} style={{ backgroundColor: '#6c757d' }}>
          Cancel
        </button>
        <button type="submit" disabled={isLoading}>
          {isLoading ? 'Saving...' : (initialData ? 'Update Resident' : 'Add Resident')}
        </button>
      </div>
    </form>
  );
};

export default ResidentForm;