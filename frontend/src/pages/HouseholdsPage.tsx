// src/pages/HouseholdsPage.tsx
import React, { useEffect, useState } from 'react';
import type { Household, HouseholdFormData } from '../types';
import * as householdService from '../api/householdService';
import Modal from '../components/common/Modal';
import HouseholdForm from '../components/households/HouseholdForm';
import { Link } from 'react-router-dom'; // Import Link for navigation

const HouseholdsPage: React.FC = () => {
  const [households, setHouseholds] = useState<Household[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchHouseholds = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await householdService.getHouseholds();
      setHouseholds(data);
    } catch (err) {
      setError('Failed to fetch households. Please try again.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchHouseholds();
  }, []);

  const handleOpenModal = () => {
    setFormError(null); // Clear previous form errors
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setFormError(null);
  };

  const handleSubmitHousehold = async (data: HouseholdFormData) => {
    setIsSubmitting(true);
    setFormError(null);
    try {
      await householdService.createHouseholdWithHead(data);
      await fetchHouseholds(); // Refresh list
      handleCloseModal();
    } catch (err: any) {
        setFormError(err.message || 'An error occurred.');
        console.error(err);
    } finally {
        setIsSubmitting(false);
    }
  };

  // No Delete/Edit for Households implemented in backend yet based on snippets

  if (isLoading && households.length === 0) {
    return <p>Loading households...</p>;
  }

  if (error) {
    return <p className="error-message">{error}</p>;
  }

  return (
    <div>
      <div className="page-header">
        <h1>Household Management</h1>
        <button onClick={() => handleOpenModal()}>Add New Household</button>
      </div>

      {households.length === 0 && !isLoading && <p>No households found. Add one to get started!</p>}

      {households.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Apartment</th>
              <th>Head of Household</th>
              <th>Move In Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {households.map((h) => (
              <tr key={h.household_id}>
                <td>{h.household_id}</td>
                <td>{h.apartment_number}</td>
                <td>{h.head_full_name || 'N/A'}</td>
                <td>{h.move_in_date ? new Date(h.move_in_date).toLocaleDateString() : 'N/A'}</td>
                <td>
                   <Link to={`/households/${h.household_id}`}>
                      <button style={{ marginRight: '0.5rem', backgroundColor: '#17a2b8', color: 'white' }}>View Details</button>
                   </Link>
                   {/* Add Edit/Delete buttons here if backend functions are implemented */}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <Modal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={'Add New Household'}
      >
        <HouseholdForm
          onSubmit={handleSubmitHousehold}
          onCancel={handleCloseModal}
          isLoading={isSubmitting}
          errorMessage={formError}
        />
      </Modal>
    </div>
  );
};

export default HouseholdsPage;