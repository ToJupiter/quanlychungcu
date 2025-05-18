// src/components/apartments/ApartmentForm.tsx
import React, { useState, useEffect, } from 'react';
import type {FormEvent } from 'react';
import type { Apartment, ApartmentFormData } from '../../types/index.ts';

interface ApartmentFormProps {
  onSubmit: (data: ApartmentFormData) => Promise<void>;
  initialData?: Apartment | null;
  onCancel: () => void;
  isLoading: boolean;
  errorMessage?: string | null;
}

const ApartmentForm: React.FC<ApartmentFormProps> = ({
  onSubmit,
  initialData,
  onCancel,
  isLoading,
  errorMessage
}) => {
  const [formData, setFormData] = useState<ApartmentFormData>({
    apartment_number: '',
    area: undefined, // Or 0 if you prefer a default number
    status: 'vacant', // Default status
  });

  useEffect(() => {
    if (initialData) {
      setFormData({
        apartment_number: initialData.apartment_number,
        area: initialData.area ?? undefined,
        status: initialData.status ?? 'vacant',
      });
    } else {
      // Reset for new form
       setFormData({
        apartment_number: '',
        area: undefined,
        status: 'vacant',
      });
    }
  }, [initialData]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === 'area' ? (value === '' ? undefined : parseFloat(value)) : value,
    }));
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    if (!formData.apartment_number) {
        // Basic validation, more can be added
        alert("Apartment number is required.");
        return;
    }
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="apartment_number">Apartment Number:</label>
        <input
          type="text"
          id="apartment_number"
          name="apartment_number"
          value={formData.apartment_number}
          onChange={handleChange}
          required
          disabled={isLoading}
        />
      </div>
      <div>
        <label htmlFor="area">Area (sqm):</label>
        <input
          type="number"
          id="area"
          name="area"
          value={formData.area === undefined || formData.area === null ? '' : formData.area}
          onChange={handleChange}
          step="0.01"
          min="0"
          disabled={isLoading}
        />
      </div>
      <div>
        <label htmlFor="status">Status:</label>
        <select
          id="status"
          name="status"
          value={formData.status || 'vacant'}
          onChange={handleChange}
          disabled={isLoading}
        >
          <option value="vacant">Vacant</option>
          <option value="occupied">Occupied</option>
          <option value="maintenance">Maintenance</option>
          {/* Add other statuses if needed */}
        </select>
      </div>

      {errorMessage && <p className="error-message" style={{ marginTop: '1rem' }}>{errorMessage}</p>}

      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '1rem', marginTop: '1rem' }}>
        <button type="button" onClick={onCancel} disabled={isLoading} style={{ backgroundColor: '#6c757d' }}>
          Cancel
        </button>
        <button type="submit" disabled={isLoading}>
          {isLoading ? 'Saving...' : (initialData ? 'Update Apartment' : 'Create Apartment')}
        </button>
      </div>
    </form>
  );
};

export default ApartmentForm;