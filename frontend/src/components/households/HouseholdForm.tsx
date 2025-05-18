// src/components/households/HouseholdForm.tsx
import React, { useState, useEffect} from 'react';
import type { FormEvent } from 'react';
import type { HouseholdFormData, Apartment } from '../../types/index.ts';
import { getApartments } from '../../api/householdService'; // Use the re-exported function

interface HouseholdFormProps {
  onSubmit: (data: HouseholdFormData) => Promise<void>;
  onCancel: () => void;
  isLoading: boolean;
  errorMessage?: string | null;
}

const HouseholdForm: React.FC<HouseholdFormProps> = ({
  onSubmit,
  onCancel,
  isLoading,
  errorMessage
}) => {
  const [formData, setFormData] = useState<HouseholdFormData>({
    apartment_id: 0, // Needs to be selected
    move_in_date: '',
    head_full_name: '',
    head_date_of_birth: '',
    head_cccd_number: '',
  });
  const [apartments, setApartments] = useState<Apartment[]>([]);
  const [apartmentsLoading, setApartmentsLoading] = useState(true);
  const [apartmentsError, setApartmentsError] = useState<string | null>(null);

  useEffect(() => {
    const fetchApartmentOptions = async () => {
      setApartmentsLoading(true);
      setApartmentsError(null);
      try {
        // Fetch only vacant apartments if you want to prevent assigning to occupied ones
        // Or fetch all and handle the logic on the backend/frontend
        const allApartments = await getApartments();
        // Filter for vacant ones if applicable, based on your logic
        const vacantApartments = allApartments.filter(apt => apt.status === 'vacant' || !apt.status); // Assuming status can be null/undefined or 'vacant'
        setApartments(vacantApartments);
         if (vacantApartments.length > 0) {
            setFormData(prev => ({ ...prev, apartment_id: vacantApartments[0].apartment_id }));
        }
      } catch (err) {
        setApartmentsError('Failed to load apartment options.');
        console.error(err);
      } finally {
        setApartmentsLoading(false);
      }
    };
    fetchApartmentOptions();
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === 'apartment_id' ? parseInt(value, 10) : value,
    }));
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    // Basic validation
    if (formData.apartment_id <= 0 || !formData.head_full_name) {
        alert("Please select an apartment and enter head resident's full name.");
        return;
    }
     // Optional: Add more validation for date formats, CCCD length etc.

    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="apartment_id">Apartment:</label>
        {apartmentsLoading ? (
            <p>Loading apartments...</p>
        ) : apartmentsError ? (
            <p className="error-message">{apartmentsError}</p>
        ) : apartments.length === 0 ? (
            <p>No vacant apartments available.</p>
        ) : (
             <select
                id="apartment_id"
                name="apartment_id"
                value={formData.apartment_id}
                onChange={handleChange}
                required
                disabled={isLoading || apartmentsLoading}
             >
                <option value={0}>-- Select Apartment --</option>
                {apartments.map(apt => (
                    <option key={apt.apartment_id} value={apt.apartment_id}>
                        {apt.apartment_number} ({apt.status})
                    </option>
                ))}
             </select>
        )}
      </div>
      <div>
        <label htmlFor="move_in_date">Move In Date:</label>
        <input
          type="date"
          id="move_in_date"
          name="move_in_date"
          value={formData.move_in_date || ''}
          onChange={handleChange}
          disabled={isLoading}
        />
      </div>

      <h3 style={{marginTop: '1.5rem', marginBottom: '1rem', borderBottom: '1px solid #eee', paddingBottom: '0.5rem'}}>Head Resident Information</h3>

      <div>
        <label htmlFor="head_full_name">Full Name:</label>
        <input
          type="text"
          id="head_full_name"
          name="head_full_name"
          value={formData.head_full_name}
          onChange={handleChange}
          required
          disabled={isLoading}
        />
      </div>
      <div>
        <label htmlFor="head_date_of_birth">Date of Birth:</label>
        <input
          type="date"
          id="head_date_of_birth"
          name="head_date_of_birth"
          value={formData.head_date_of_birth || ''}
          onChange={handleChange}
          disabled={isLoading}
        />
      </div>
      <div>
        <label htmlFor="head_cccd_number">CCCD Number:</label>
        <input
          type="text"
          id="head_cccd_number"
          name="head_cccd_number"
          value={formData.head_cccd_number || ''}
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
          {isLoading ? 'Creating...' : 'Create Household'}
        </button>
      </div>
    </form>
  );
};

export default HouseholdForm;