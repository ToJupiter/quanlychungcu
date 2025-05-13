// src/pages/ApartmentManagementPage.tsx
import React, { useEffect, useState } from 'react';
import {
  Box, Typography, Button, CircularProgress, Alert, Paper,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow, IconButton, Tooltip, Dialog, DialogTitle, DialogContent, DialogActions, TextField
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import apiClient from '../services/api';
import { Apartment, ApiErrorResponse } from '../types';

const ApartmentManagementPage: React.FC = () => {
  const [apartments, setApartments] = useState<Apartment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [currentApartment, setCurrentApartment] = useState<Partial<Apartment> | null>(null);
  const [isEditMode, setIsEditMode] = useState(false);

  const fetchApartments = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await apiClient.get<Apartment[]>('/management/apartments');
      setApartments(response.data);
    } catch (err) {
      const apiError = err as ApiErrorResponse;
      setError(apiError.message || 'Failed to fetch apartments.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchApartments();
  }, []);

  const handleOpenDialog = (apartment?: Apartment) => {
    setIsEditMode(!!apartment);
    setCurrentApartment(apartment ? { ...apartment } : { apartment_number: '', area: 0, status: 'vacant' });
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setCurrentApartment(null);
  };

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (currentApartment) {
      setCurrentApartment({
        ...currentApartment,
        [event.target.name]: event.target.value,
      });
    }
  };

  const handleSubmitDialog = async () => {
    if (!currentApartment || !currentApartment.apartment_number) {
        setError("Apartment number is required."); // Simple client validation
        return;
    }
    setLoading(true);
    try {
      if (isEditMode && currentApartment.apartment_id) {
        await apiClient.put(`/management/apartments/${currentApartment.apartment_id}`, currentApartment);
      } else {
        await apiClient.post('/management/apartments', currentApartment);
      }
      handleCloseDialog();
      fetchApartments(); // Refresh list
    } catch (err) {
      const apiError = err as ApiErrorResponse;
      setError(apiError.message || `Failed to ${isEditMode ? 'update' : 'create'} apartment.`);
       // Keep dialog open on error to allow correction
    } finally {
      setLoading(false); // Stop loading only for the dialog submission part
    }
  };

  const handleDeleteApartment = async (apartmentId: number) => {
    if(window.confirm('Are you sure you want to delete this apartment? This action cannot be undone.')) {
        setLoading(true);
        try {
            await apiClient.delete(`/management/apartments/${apartmentId}`);
            fetchApartments();
        } catch (err) {
            const apiError = err as ApiErrorResponse;
            setError(apiError.message || 'Failed to delete apartment.');
        } finally {
            setLoading(false);
        }
    }
  };


  if (loading && apartments.length === 0) { // Show main loading only on initial fetch
    return <Box display="flex" justifyContent="center" alignItems="center" minHeight="50vh"><CircularProgress /></Box>;
  }

  return (
    <Paper sx={{ p: 2, m: 1 }}>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
        <Typography variant="h5">Apartment Management</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenDialog()}>
          Add Apartment
        </Button>
      </Box>

      {error && <Alert severity="error" onClose={() => setError(null)} sx={{ mb: 2 }}>{error}</Alert>}

      <TableContainer>
        <Table stickyHeader>
          <TableHead>
            <TableRow>
              <TableCell>Apartment Number</TableCell>
              <TableCell>Area (sqm)</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {apartments.map((apt) => (
              <TableRow hover key={apt.apartment_id}>
                <TableCell>{apt.apartment_number}</TableCell>
                <TableCell>{apt.area || 'N/A'}</TableCell>
                <TableCell>{apt.status || 'N/A'}</TableCell>
                <TableCell align="right">
                  <Tooltip title="Edit">
                    <IconButton onClick={() => handleOpenDialog(apt)}><EditIcon /></IconButton>
                  </Tooltip>
                  <Tooltip title="Delete">
                    <IconButton onClick={() => handleDeleteApartment(apt.apartment_id)}><DeleteIcon color="error" /></IconButton>
                  </Tooltip>
                </TableCell>
              </TableRow>
            ))}
             {apartments.length === 0 && !loading && (
                <TableRow>
                    <TableCell colSpan={4} align="center">No apartments found.</TableCell>
                </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>
      {loading && apartments.length > 0 && <Box display="flex" justifyContent="center" py={2}><CircularProgress size={24} /></Box> }


      <Dialog open={openDialog} onClose={handleCloseDialog}>
        <DialogTitle>{isEditMode ? 'Edit Apartment' : 'Add New Apartment'}</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            name="apartment_number"
            label="Apartment Number"
            type="text"
            fullWidth
            variant="outlined"
            value={currentApartment?.apartment_number || ''}
            onChange={handleInputChange}
            required
          />
          <TextField
            margin="dense"
            name="area"
            label="Area (sqm)"
            type="number"
            fullWidth
            variant="outlined"
            value={currentApartment?.area || ''}
            onChange={handleInputChange}
          />
          <TextField
            margin="dense"
            name="status"
            label="Status (e.g., vacant, occupied)"
            type="text"
            fullWidth
            variant="outlined"
            value={currentApartment?.status || ''}
            onChange={handleInputChange}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>Cancel</Button>
          <Button onClick={handleSubmitDialog} variant="contained" disabled={loading}>
            {loading ? <CircularProgress size={20}/> : (isEditMode ? 'Save Changes' : 'Add Apartment')}
          </Button>
        </DialogActions>
      </Dialog>
    </Paper>
  );
};

export default ApartmentManagementPage;