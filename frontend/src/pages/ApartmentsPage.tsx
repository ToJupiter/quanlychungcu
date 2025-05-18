// src/pages/ApartmentsPage.tsx
import React, { useEffect, useState } from 'react';
import type { Apartment, ApartmentFormData } from '../types';
import * as apartmentService from '../api/apartmentService';
import Modal from '../components/common/Modal';
import ApartmentForm from '../components/apartments/ApartmentForm';

const ApartmentsPage: React.FC = () => {
  const [apartments, setApartments] = useState<Apartment[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentApartment, setCurrentApartment] = useState<Apartment | null>(null);
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchApartments = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await apartmentService.getApartments();
      setApartments(data);
    } catch (err) {
      setError('Failed to fetch apartments. Please try again.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchApartments();
  }, []);

  const handleOpenModal = (apartment?: Apartment) => {
    setCurrentApartment(apartment || null);
    setFormError(null); // Clear previous form errors
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setCurrentApartment(null);
    setFormError(null);
  };

  const handleSubmitApartment = async (data: ApartmentFormData) => {
    setIsSubmitting(true);
    setFormError(null);
    try {
      if (currentApartment && currentApartment.apartment_id) {
        await apartmentService.updateApartment(currentApartment.apartment_id, data);
      } else {
        await apartmentService.createApartment(data);
      }
      await fetchApartments(); // Refresh list
      handleCloseModal();
    } catch (err: any) {
        setFormError(err.message || 'An error occurred.');
        console.error(err);
    } finally {
        setIsSubmitting(false);
    }
  };

  const handleDeleteApartment = async (id: number) => {
    if (window.confirm('Are you sure you want to delete this apartment? This action cannot be undone.')) {
      setIsLoading(true); // Use main loading for delete action feedback
      setError(null);
      try {
        await apartmentService.deleteApartment(id);
        await fetchApartments(); // Refresh list
      } catch (err: any) {
        setError(err.message || 'Failed to delete apartment. It might be in use.');
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    }
  };

  if (isLoading && apartments.length === 0) { // Show loading only on initial load or if list is empty
    return <p>Loading apartments...</p>;
  }

  if (error) {
    return <p className="error-message">{error}</p>;
  }

  return (
    <div>
      <div className="page-header">
        <h1>Apartment Management</h1>
        <button onClick={() => handleOpenModal()}>Add New Apartment</button>
      </div>

      {apartments.length === 0 && !isLoading && <p>No apartments found. Add one to get started!</p>}

      {apartments.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Number</th>
              <th>Area (sqm)</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {apartments.map((apt) => (
              <tr key={apt.apartment_id}>
                <td>{apt.apartment_id}</td>
                <td>{apt.apartment_number}</td>
                <td>{apt.area || 'N/A'}</td>
                <td>{apt.status || 'N/A'}</td>
                <td>
                  <button onClick={() => handleOpenModal(apt)} style={{ marginRight: '0.5rem', backgroundColor: '#ffc107', color: '#212529'}}>Edit</button>
                  <button onClick={() => handleDeleteApartment(apt.apartment_id)} style={{ backgroundColor: '#dc3545'}}>Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <Modal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={currentApartment ? 'Edit Apartment' : 'Add New Apartment'}
      >
        <ApartmentForm
          onSubmit={handleSubmitApartment}
          initialData={currentApartment}
          onCancel={handleCloseModal}
          isLoading={isSubmitting}
          errorMessage={formError}
        />
      </Modal>
    </div>
  );
};

export default ApartmentsPage;