// src/components/vehicles/VehicleForm.tsx
import React, { useState, useEffect,  } from 'react';
import type {FormEvent} from 'react';
import type { Vehicle, VehicleFormData } from '../../types';

interface VehicleFormProps {
  onSubmit: (data: VehicleFormData) => Promise<void>;
  initialData?: Vehicle | null;
  onCancel: () => void;
  isLoading: boolean;
  errorMessage?: string | null;
}

const VehicleForm: React.FC<VehicleFormProps> = ({
  onSubmit,
  initialData,
  onCancel,
  isLoading,
  errorMessage
}) => {
  const [formData, setFormData] = useState<VehicleFormData>({
    plate_number: '',
    vehicle_type: '',
    registration_date: '',
  });

  useEffect(() => {
    if (initialData) {
      setFormData({
        plate_number: initialData.plate_number,
        vehicle_type: initialData.vehicle_type || '',
        registration_date: initialData.registration_date || '', // Ensure date is string or empty
      });
    } else {
      // Reset for new form
       setFormData({
        plate_number: '',
        vehicle_type: '',
        registration_date: '',
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
    if (!formData.plate_number || !formData.vehicle_type) {
        alert("Plate number and vehicle type are required.");
        return;
    }
    // Optional: Add more validation for date formats etc.

    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="plate_number">Plate Number:</label>
        <input
          type="text"
          id="plate_number"
          name="plate_number"
          value={formData.plate_number}
          onChange={handleChange}
          required
          disabled={isLoading}
        />
      </div>
      <div>
        <label htmlFor="vehicle_type">Vehicle Type:</label>
         <select
          id="vehicle_type"
          name="vehicle_type"
          value={formData.vehicle_type || ''}
          onChange={handleChange}
          required
          disabled={isLoading}
        >
            <option value="">-- Select Type --</option>
            <option value="Car">Car</option>
            <option value="Motorcycle">Motorcycle</option>
            <option value="Other">Other</option>
        </select>
      </div>
      <div>
        <label htmlFor="registration_date">Registration Date:</label>
        <input
          type="date"
          id="registration_date"
          name="registration_date"
          value={formData.registration_date || ''}
          onChange={handleChange}
          disabled={isLoading}
        />
      </div>

      {errorMessage && <p className="error-message" style={{ marginTop: '1rem' }}>{errorMessage}</p>}

      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '1rem', marginTop: '1rem' }}>
        <button type="button" onClick={onCancel} disabled={isLoading} style={{ backgroundColor: '#6c757d' }}>
          Cancel
        </button>
        <button type="submit" disabled={isLoading}>
          {isLoading ? 'Saving...' : (initialData ? 'Update Vehicle' : 'Add Vehicle')}
        </button>
      </div>
    </form>
  );
};

export default VehicleForm;