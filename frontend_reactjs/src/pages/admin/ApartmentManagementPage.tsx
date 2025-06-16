import React, { useState, useEffect } from 'react';
import {
  Box,
  Paper,
  Typography,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Chip,
  Alert,
  CircularProgress,
  Stack,
  Tooltip,
} from '@mui/material';
import {
  Add,
  Edit,
  Delete,
  Visibility,
  Home,
} from '@mui/icons-material';
import apiService from '../../services/api';
import useAuthStore from '../../stores/authStore';
import type { ApartmentDto, ApartmentCreateRequest } from '../../types/api';

// Simple UUID generator for apartment IDs
const generateUUID = () => {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
};

const ApartmentManagementPage: React.FC = () => {
  const { user: currentUser } = useAuthStore();
  const [apartments, setApartments] = useState<ApartmentDto[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingApartment, setEditingApartment] = useState<ApartmentDto | null>(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [apartmentToDelete, setApartmentToDelete] = useState<ApartmentDto | null>(null);
  const [formLoading, setFormLoading] = useState(false);

  const [formData, setFormData] = useState<ApartmentCreateRequest>({
    apartment_number: '',
    area: 0,
    status: 'available',
  });

  const statusOptions = [
    { value: 'available', label: 'Available', color: 'success' },
    { value: 'occupied', label: 'Occupied', color: 'warning' },
    { value: 'maintenance', label: 'Maintenance', color: 'error' },
  ];

  useEffect(() => {
    loadApartments();
  }, []);

  const loadApartments = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await apiService.getAllApartments();
      setApartments(data);
    } catch (err: any) {
      setError(err.message || 'Failed to load apartments');
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    const statusConfig = statusOptions.find(s => s.value === status);
    return statusConfig?.color || 'default';
  };

  const handleOpenDialog = (apartment?: ApartmentDto) => {
    if (apartment) {
      setEditingApartment(apartment);
      setFormData({
        apartment_number: apartment.apartment_number,
        area: apartment.area,
        status: apartment.status,
      });
    } else {
      setEditingApartment(null);
      setFormData({
        apartment_number: '',
        area: 0,
        status: 'available',
      });
    }
    setDialogOpen(true);
    setError(null);
  };

  const handleCloseDialog = () => {
    setDialogOpen(false);
    setEditingApartment(null);
    setError(null);
  };

  const handleFormChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === 'area' ? parseFloat(value) || 0 : value,
    }));
  };

  const handleStatusChange = (value: string) => {
    setFormData(prev => ({
      ...prev,
      status: value,
    }));
  };

  const validateForm = () => {
    if (!formData.apartment_number.trim()) {
      setError('Apartment number is required');
      return false;
    }
    if (formData.area <= 0) {
      setError('Area must be greater than 0');
      return false;
    }
    
    // Check for duplicate apartment number (excluding current one when editing)
    const existingApartment = apartments.find(apt => 
      apt.apartment_number === formData.apartment_number && 
      (!editingApartment || apt.apartment_id !== editingApartment.apartment_id)
    );
    if (existingApartment) {
      setError('Apartment number already exists');
      return false;
    }
    
    return true;
  };

  const handleSubmit = async () => {
    if (!validateForm()) {
      return;
    }

    try {
      setFormLoading(true);
      setError(null);
      
      if (editingApartment) {
        // For editing, we would need an update endpoint
        setError('Edit functionality not yet implemented in backend');
        return;
      } else {
        // Create new apartment with generated ID
        const apartmentData: ApartmentCreateRequest = {
          ...formData,
          apartment_id: generateUUID(), // Generate UUID for backend
        };
        await apiService.createApartment(apartmentData);
      }
      
      await loadApartments();
      handleCloseDialog();
    } catch (err: any) {
      setError(err.message || 'Failed to save apartment');
    } finally {
      setFormLoading(false);
    }
  };

  const handleDeleteClick = (apartment: ApartmentDto) => {
    setApartmentToDelete(apartment);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    if (!apartmentToDelete) return;
    
    try {
      setError(null);
      // Delete functionality not shown in API docs
      setError('Delete functionality not yet implemented in backend');
      setDeleteDialogOpen(false);
      setApartmentToDelete(null);
    } catch (err: any) {
      setError(err.message || 'Failed to delete apartment');
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress size={40} />
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      <Paper sx={{ p: 3 }}>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
          <Typography variant="h4" component="h1" gutterBottom>
            <Home sx={{ mr: 1, verticalAlign: 'middle' }} />
            Apartment Management
          </Typography>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={() => handleOpenDialog()}
            sx={{ background: 'linear-gradient(45deg, #2196F3 30%, #21CBF3 90%)' }}
          >
            Add Apartment
          </Button>
        </Box>

        {error && (
          <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
            {error}
          </Alert>
        )}

        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Apartment Number</TableCell>
                <TableCell>Area (m²)</TableCell>
                <TableCell>Status</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {apartments.map((apartment) => (
                <TableRow key={apartment.apartment_id}>
                  <TableCell>
                    <Typography variant="body1" fontWeight="bold">
                      {apartment.apartment_number}
                    </Typography>
                  </TableCell>
                  <TableCell>{apartment.area}m²</TableCell>
                  <TableCell>
                    <Chip
                      label={apartment.status.charAt(0).toUpperCase() + apartment.status.slice(1)}
                      color={getStatusColor(apartment.status) as any}
                      size="small"
                    />
                  </TableCell>
                  <TableCell align="center">
                    <Stack direction="row" spacing={1} justifyContent="center">
                      <Tooltip title="Edit Apartment">
                        <IconButton
                          size="small"
                          onClick={() => handleOpenDialog(apartment)}
                        >
                          <Edit />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Delete Apartment">
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => handleDeleteClick(apartment)}
                        >
                          <Delete />
                        </IconButton>
                      </Tooltip>
                    </Stack>
                  </TableCell>
                </TableRow>
              ))}
              {apartments.length === 0 && (
                <TableRow>
                  <TableCell colSpan={4} align="center">
                    <Typography variant="body2" color="text.secondary" sx={{ py: 2 }}>
                      No apartments found. Add one to get started.
                    </Typography>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      {/* Add/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          {editingApartment ? 'Edit Apartment' : 'Add New Apartment'}
        </DialogTitle>
        <DialogContent>
          <Stack spacing={3} sx={{ mt: 1 }}>
            <TextField
              fullWidth
              label="Apartment Number"
              name="apartment_number"
              value={formData.apartment_number}
              onChange={handleFormChange}
              required
              placeholder="e.g., A101, B205"
            />
            
            <TextField
              fullWidth
              label="Area (m²)"
              name="area"
              type="number"
              value={formData.area}
              onChange={handleFormChange}
              required
              inputProps={{ min: 0, step: 0.1 }}
            />
            
            <FormControl fullWidth>
              <InputLabel>Status</InputLabel>
              <Select
                value={formData.status}
                label="Status"
                onChange={(e) => handleStatusChange(e.target.value)}
              >
                {statusOptions.map((status) => (
                  <MenuItem key={status.value} value={status.value}>
                    {status.label}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog} disabled={formLoading}>
            Cancel
          </Button>
          <Button
            onClick={handleSubmit}
            variant="contained"
            disabled={formLoading}
          >
            {formLoading ? <CircularProgress size={20} /> : (editingApartment ? 'Update' : 'Create')}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
        <DialogTitle>Confirm Delete</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to delete apartment {apartmentToDelete?.apartment_number}?
            This action cannot be undone.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error" variant="contained">
            Delete
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default ApartmentManagementPage; 