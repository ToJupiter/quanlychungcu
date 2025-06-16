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
  Accordion,
  AccordionSummary,
  AccordionDetails,
  List,
  ListItem,
  ListItemText,
  Divider,
  Grid,
} from '@mui/material';
import {
  Add,
  Edit,
  Delete,
  Visibility,
  Home,
  People,
  DirectionsCar,
  ExpandMore,
} from '@mui/icons-material';
import apiService from '../../services/api';
import useAuthStore from '../../stores/authStore';
import type { HouseholdDto, ApartmentDto, HouseholdCreateRequest, ResidentCreateRequest, VehicleCreateRequest } from '../../types/api';

// Simple UUID generator
const generateUUID = () => {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
};

const HouseholdManagementPage: React.FC = () => {
  const { user: currentUser } = useAuthStore();
  const [households, setHouseholds] = useState<HouseholdDto[]>([]);
  const [apartments, setApartments] = useState<ApartmentDto[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedHousehold, setSelectedHousehold] = useState<HouseholdDto | null>(null);
  const [editingHousehold, setEditingHousehold] = useState<HouseholdDto | null>(null);
  const [detailsDialogOpen, setDetailsDialogOpen] = useState(false);
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [formLoading, setFormLoading] = useState(false);

  // Form state for creating household
  const [formData, setFormData] = useState({
    apartment_id: '',
    move_in_date: '',
    head_resident: {
      full_name: '',
      date_of_birth: '',
      cccd_number: '',
      role_in_household: 'Head of Household',
    },
    residents: [] as ResidentCreateRequest[],
    vehicles: [] as VehicleCreateRequest[],
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      const [householdsData, apartmentsData] = await Promise.all([
        apiService.getAllHouseholds(),
        apiService.getAllApartments(),
      ]);
      setHouseholds(householdsData);
      setApartments(apartmentsData);
    } catch (err: any) {
      setError(err.message || 'Failed to load households');
    } finally {
      setLoading(false);
    }
  };

  const handleViewDetails = (household: HouseholdDto) => {
    setSelectedHousehold(household);
    setDetailsDialogOpen(true);
  };

  const handleCloseDetails = () => {
    setDetailsDialogOpen(false);
    setSelectedHousehold(null);
  };

  const handleOpenAddDialog = () => {
    setFormData({
      apartment_id: '',
      move_in_date: '',
      head_resident: {
        full_name: '',
        date_of_birth: '',
        cccd_number: '',
        role_in_household: 'Head of Household',
      },
      residents: [],
      vehicles: [],
    });
    setAddDialogOpen(true);
    setError(null);
  };

  const handleCloseAddDialog = () => {
    setAddDialogOpen(false);
    setEditingHousehold(null);
    // Reset form to default
    setFormData({
      apartment_id: '',
      move_in_date: '',
      head_resident: {
        full_name: '',
        date_of_birth: '',
        cccd_number: '',
        role_in_household: 'Head',
      },
      residents: [],
      vehicles: [],
    });
  };

  const handleFormChange = (section: string, field: string, value: string) => {
    if (section === 'head_resident') {
      setFormData(prev => ({
        ...prev,
        head_resident: {
          ...prev.head_resident,
          [field]: value,
        },
      }));
    } else {
      setFormData(prev => ({
        ...prev,
        [field]: value,
      }));
    }
  };

  const addResident = () => {
    const newResident: ResidentCreateRequest = {
      household_id: '', // Will be set when household is created
      full_name: '',
      date_of_birth: '',
      cccd_number: '',
      role_in_household: 'Member',
    };
    setFormData(prev => ({
      ...prev,
      residents: [...prev.residents, newResident],
    }));
  };

  const updateResident = (index: number, field: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      residents: prev.residents.map((resident, i) => 
        i === index ? { ...resident, [field]: value } : resident
      ),
    }));
  };

  const removeResident = (index: number) => {
    setFormData(prev => ({
      ...prev,
      residents: prev.residents.filter((_, i) => i !== index),
    }));
  };

  const addVehicle = () => {
    const newVehicle: VehicleCreateRequest = {
      household_id: '', // Will be set when household is created
      plate_number: '',
      vehicle_type: 'Car',
      registration_date: '',
    };
    setFormData(prev => ({
      ...prev,
      vehicles: [...prev.vehicles, newVehicle],
    }));
  };

  const updateVehicle = (index: number, field: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      vehicles: prev.vehicles.map((vehicle, i) => 
        i === index ? { ...vehicle, [field]: value } : vehicle
      ),
    }));
  };

  const removeVehicle = (index: number) => {
    setFormData(prev => ({
      ...prev,
      vehicles: prev.vehicles.filter((_, i) => i !== index),
    }));
  };

  const validateForm = () => {
    if (!formData.apartment_id) {
      setError('Please select an apartment');
      return false;
    }
    if (!formData.move_in_date) {
      setError('Please select a move-in date');
      return false;
    }
    if (!formData.head_resident.full_name.trim()) {
      setError('Head of household name is required');
      return false;
    }
    if (!formData.head_resident.cccd_number.trim()) {
      setError('Head of household CCCD number is required');
      return false;
    }
    if (!formData.head_resident.date_of_birth) {
      setError('Head of household date of birth is required');
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

      if (editingHousehold) {
        // Update existing household
        const updateData = {
          move_in_date: formData.move_in_date,
          // Only allow updating move-in date for now
        };
        await apiService.updateHousehold(editingHousehold.household_id, updateData);
      } else {
        // Create new household
        // Prepare head resident with generated ID
        const headResidentId = generateUUID();
        const headResident: ResidentCreateRequest = {
          ...formData.head_resident,
          household_id: '', // Will be set by backend
        };

        // Prepare household creation request
        const householdId = generateUUID();
        const additionalResidents = formData.residents.map(resident => ({
          ...resident,
          household_id: householdId,
        }));
        const vehicles = formData.vehicles.map(vehicle => ({
          ...vehicle,
          household_id: householdId,
        }));
        const householdRequest: HouseholdCreateRequest = {
          household_id: householdId,
          apartment_id: formData.apartment_id,
          move_in_date: formData.move_in_date,
          residents: [headResident, ...additionalResidents],
          vehicles: vehicles,
        };

        await apiService.createHousehold(householdRequest);
      }

      await loadData();
      handleCloseAddDialog();
    } catch (err: any) {
      setError(err.message || 'Failed to save household');
    } finally {
      setFormLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString();
  };

  const getAvailableApartments = () => {
    // Filter apartments that are not already occupied by a household
    const occupiedApartmentIds = households.map(h => h.apartment_id);
    return apartments.filter(apt => !occupiedApartmentIds.includes(apt.apartment_id));
  };

  const handleEdit = (household: HouseholdDto) => {
    // Set the household data for editing
    setFormData({
      apartment_id: household.apartment_id,
      move_in_date: household.move_in_date,
      head_resident: {
        full_name: household.head_full_name,
        date_of_birth: household.head_dob,
        cccd_number: household.head_cccd,
        role_in_household: 'Head',
      },
      residents: household.residents.filter(r => r.role_in_household !== 'Head').map(r => ({
        full_name: r.full_name,
        date_of_birth: r.date_of_birth,
        cccd_number: r.cccd_number,
        role_in_household: r.role_in_household,
        household_id: r.household_id,
      })),
      vehicles: household.vehicles.map(v => ({
        plate_number: v.plate_number,
        vehicle_type: v.vehicle_type,
        registration_date: v.registration_date,
        household_id: v.household_id,
      })),
    });
    setEditingHousehold(household);
    setAddDialogOpen(true);
  };

  const handleDelete = async (household: HouseholdDto) => {
    if (!window.confirm(`Are you sure you want to delete household in apartment ${household.apartment_number}?`)) {
      return;
    }

    try {
      setError(null);
      await apiService.deleteHousehold(household.household_id);
      await loadData(); // Reload the data
    } catch (err: any) {
      setError(err.message || 'Failed to delete household');
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
            Household Management
          </Typography>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={handleOpenAddDialog}
            sx={{ background: 'linear-gradient(45deg, #2196F3 30%, #21CBF3 90%)' }}
          >
            Add Household
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
                <TableCell>Apartment</TableCell>
                <TableCell>Head of Household</TableCell>
                <TableCell>Residents</TableCell>
                <TableCell>Vehicles</TableCell>
                <TableCell>Move-in Date</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {households.map((household) => (
                <TableRow key={household.household_id}>
                  <TableCell>
                    <Box>
                      <Typography variant="body2" fontWeight="bold">
                        {household.apartment_number}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {household.apartment_area}m² - {household.apartment_status}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Box>
                      <Typography variant="body2">
                        {household.head_full_name}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        CCCD: {household.head_cccd}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Chip
                      icon={<People />}
                      label={`${household.residents.length} residents`}
                      color="primary"
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    <Chip
                      icon={<DirectionsCar />}
                      label={`${household.vehicles.length} vehicles`}
                      color="secondary"
                      size="small"
                    />
                  </TableCell>
                  <TableCell>{formatDate(household.move_in_date)}</TableCell>
                  <TableCell align="center">
                    <Stack direction="row" spacing={1} justifyContent="center">
                      <Tooltip title="View Details">
                        <IconButton
                          size="small"
                          onClick={() => handleViewDetails(household)}
                        >
                          <Visibility />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Edit Household">
                        <IconButton
                          size="small"
                          onClick={() => handleEdit(household)}
                        >
                          <Edit />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Delete Household">
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => handleDelete(household)}
                        >
                          <Delete />
                        </IconButton>
                      </Tooltip>
                    </Stack>
                  </TableCell>
                </TableRow>
              ))}
              {households.length === 0 && (
                <TableRow>
                  <TableCell colSpan={6} align="center">
                    <Typography variant="body2" color="text.secondary" sx={{ py: 2 }}>
                      No households found. Add one to get started.
                    </Typography>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      {/* Add Household Dialog */}
      <Dialog open={addDialogOpen} onClose={handleCloseAddDialog} maxWidth="md" fullWidth>
        <DialogTitle>{editingHousehold ? 'Edit Household' : 'Add New Household'}</DialogTitle>
        <DialogContent>
          <Stack spacing={3} sx={{ mt: 1 }}>
            {/* Basic Information */}
            <Typography variant="h6" color="primary">Basic Information</Typography>
            
            <Grid container spacing={2}>
              <Grid item xs={12} sm={6}>
                <FormControl fullWidth required>
                  <InputLabel>Apartment</InputLabel>
                  <Select
                    value={formData.apartment_id}
                    label="Apartment"
                    disabled={!!editingHousehold}
                    onChange={(e) => handleFormChange('', 'apartment_id', e.target.value)}
                  >
                    {getAvailableApartments().map((apartment) => (
                      <MenuItem key={apartment.apartment_id} value={apartment.apartment_id}>
                        {apartment.apartment_number} - {apartment.area}m²
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Grid>
              
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Move-in Date"
                  type="date"
                  value={formData.move_in_date}
                  onChange={(e) => handleFormChange('', 'move_in_date', e.target.value)}
                  InputLabelProps={{ shrink: true }}
                  required
                />
              </Grid>
            </Grid>

            {/* Head of Household */}
            <Divider />
            <Typography variant="h6" color="primary">Head of Household</Typography>
            
            <Grid container spacing={2}>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Full Name"
                  value={formData.head_resident.full_name}
                  onChange={(e) => handleFormChange('head_resident', 'full_name', e.target.value)}
                  required
                />
              </Grid>
              
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="CCCD Number"
                  value={formData.head_resident.cccd_number}
                  onChange={(e) => handleFormChange('head_resident', 'cccd_number', e.target.value)}
                  required
                />
              </Grid>
              
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Date of Birth"
                  type="date"
                  value={formData.head_resident.date_of_birth}
                  onChange={(e) => handleFormChange('head_resident', 'date_of_birth', e.target.value)}
                  InputLabelProps={{ shrink: true }}
                  required
                />
              </Grid>
            </Grid>

            {/* Additional Residents */}
            <Divider />
            <Box display="flex" justifyContent="space-between" alignItems="center">
              <Typography variant="h6" color="primary">Additional Residents</Typography>
              <Button startIcon={<Add />} onClick={addResident}>
                Add Resident
              </Button>
            </Box>
            
            {formData.residents.map((resident, index) => (
              <Paper key={index} sx={{ p: 2, bgcolor: 'grey.50' }}>
                <Grid container spacing={2}>
                  <Grid item xs={12} sm={3}>
                    <TextField
                      fullWidth
                      label="Full Name"
                      value={resident.full_name}
                      onChange={(e) => updateResident(index, 'full_name', e.target.value)}
                    />
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <TextField
                      fullWidth
                      label="CCCD Number"
                      value={resident.cccd_number}
                      onChange={(e) => updateResident(index, 'cccd_number', e.target.value)}
                    />
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <TextField
                      fullWidth
                      label="Date of Birth"
                      type="date"
                      value={resident.date_of_birth}
                      onChange={(e) => updateResident(index, 'date_of_birth', e.target.value)}
                      InputLabelProps={{ shrink: true }}
                    />
                  </Grid>
                  <Grid item xs={12} sm={2}>
                    <TextField
                      fullWidth
                      label="Role"
                      value={resident.role_in_household}
                      onChange={(e) => updateResident(index, 'role_in_household', e.target.value)}
                    />
                  </Grid>
                  <Grid item xs={12} sm={1}>
                    <IconButton color="error" onClick={() => removeResident(index)}>
                      <Delete />
                    </IconButton>
                  </Grid>
                </Grid>
              </Paper>
            ))}

            {/* Vehicles */}
            <Divider />
            <Box display="flex" justifyContent="space-between" alignItems="center">
              <Typography variant="h6" color="primary">Vehicles</Typography>
              <Button startIcon={<Add />} onClick={addVehicle}>
                Add Vehicle
              </Button>
            </Box>
            
            {formData.vehicles.map((vehicle, index) => (
              <Paper key={index} sx={{ p: 2, bgcolor: 'grey.50' }}>
                <Grid container spacing={2}>
                  <Grid item xs={12} sm={3}>
                    <TextField
                      fullWidth
                      label="Plate Number"
                      value={vehicle.plate_number}
                      onChange={(e) => updateVehicle(index, 'plate_number', e.target.value)}
                    />
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <FormControl fullWidth>
                      <InputLabel>Vehicle Type</InputLabel>
                      <Select
                        value={vehicle.vehicle_type}
                        label="Vehicle Type"
                        onChange={(e) => updateVehicle(index, 'vehicle_type', e.target.value)}
                      >
                        <MenuItem value="Car">Car</MenuItem>
                        <MenuItem value="Motorbike">Motorbike</MenuItem>
                        <MenuItem value="Bicycle">Bicycle</MenuItem>
                        <MenuItem value="Other">Other</MenuItem>
                      </Select>
                    </FormControl>
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <TextField
                      fullWidth
                      label="Registration Date"
                      type="date"
                      value={vehicle.registration_date}
                      onChange={(e) => updateVehicle(index, 'registration_date', e.target.value)}
                      InputLabelProps={{ shrink: true }}
                    />
                  </Grid>
                  <Grid item xs={12} sm={3}>
                    <IconButton color="error" onClick={() => removeVehicle(index)}>
                      <Delete />
                    </IconButton>
                  </Grid>
                </Grid>
              </Paper>
            ))}
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAddDialog} disabled={formLoading}>
            Cancel
          </Button>
          <Button
            onClick={handleSubmit}
            variant="contained"
            disabled={formLoading}
          >
            {formLoading ? <CircularProgress size={20} /> : (editingHousehold ? 'Save Changes' : 'Create Household')}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Details Dialog */}
      <Dialog open={detailsDialogOpen} onClose={handleCloseDetails} maxWidth="md" fullWidth>
        <DialogTitle>
          Household Details - {selectedHousehold?.apartment_number}
        </DialogTitle>
        <DialogContent>
          {selectedHousehold && (
            <Stack spacing={3}>
              {/* Basic Info */}
              <Box>
                <Typography variant="h6" gutterBottom>Basic Information</Typography>
                <Typography><strong>Apartment:</strong> {selectedHousehold.apartment_number}</Typography>
                <Typography><strong>Area:</strong> {selectedHousehold.apartment_area}m²</Typography>
                <Typography><strong>Status:</strong> {selectedHousehold.apartment_status}</Typography>
                <Typography><strong>Move-in Date:</strong> {formatDate(selectedHousehold.move_in_date)}</Typography>
              </Box>

              {/* Head of Household */}
              <Box>
                <Typography variant="h6" gutterBottom>Head of Household</Typography>
                <Typography><strong>Name:</strong> {selectedHousehold.head_full_name}</Typography>
                <Typography><strong>CCCD:</strong> {selectedHousehold.head_cccd}</Typography>
                <Typography><strong>Date of Birth:</strong> {formatDate(selectedHousehold.head_dob)}</Typography>
              </Box>

              {/* Residents */}
              <Accordion>
                <AccordionSummary expandIcon={<ExpandMore />}>
                  <Typography variant="h6">
                    Residents ({selectedHousehold.residents.length})
                  </Typography>
                </AccordionSummary>
                <AccordionDetails>
                  <List>
                    {selectedHousehold.residents.map((resident) => (
                      <ListItem key={resident.resident_id}>
                        <ListItemText
                          primary={resident.full_name}
                          secondary={
                            <span>
                              CCCD: {resident.cccd_number} | 
                              Role: {resident.role_in_household} | 
                              DOB: {formatDate(resident.date_of_birth)}
                            </span>
                          }
                        />
                      </ListItem>
                    ))}
                  </List>
                </AccordionDetails>
              </Accordion>

              {/* Vehicles */}
              <Accordion>
                <AccordionSummary expandIcon={<ExpandMore />}>
                  <Typography variant="h6">
                    Vehicles ({selectedHousehold.vehicles.length})
                  </Typography>
                </AccordionSummary>
                <AccordionDetails>
                  <List>
                    {selectedHousehold.vehicles.map((vehicle) => (
                      <ListItem key={vehicle.vehicle_id}>
                        <ListItemText
                          primary={`${vehicle.vehicle_type} - ${vehicle.plate_number}`}
                          secondary={`Registered: ${formatDate(vehicle.registration_date)}`}
                        />
                      </ListItem>
                    ))}
                  </List>
                </AccordionDetails>
              </Accordion>
            </Stack>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDetails}>Close</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default HouseholdManagementPage; 