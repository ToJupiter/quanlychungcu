import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Alert,
  Chip,
} from '@mui/material';
import { petBookingStorage, PetBookingAssociation } from '../../utils/petBookingStorage';

const PetBookingDebug: React.FC = () => {
  const [associations, setAssociations] = useState<PetBookingAssociation[]>([]);

  const loadAssociations = () => {
    setAssociations(petBookingStorage.getAllAssociations());
  };

  useEffect(() => {
    loadAssociations();
  }, []);

  const handleClearAll = () => {
    petBookingStorage.clearAllAssociations();
    loadAssociations();
  };

  const handleTestStorage = () => {
    // Add some test data
    petBookingStorage.savePetBookingAssociation(999, 1, 'Test Dog', 'Dog');
    petBookingStorage.savePetBookingAssociation(998, 2, 'Test Cat', 'Cat');
    loadAssociations();
  };

  const formatDate = (timestamp: number) => {
    return new Date(timestamp).toLocaleString();
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h5" gutterBottom>
        Pet Booking Storage Debug
      </Typography>
      
      <Alert severity="info" sx={{ mb: 3 }}>
        This debug panel shows the temporary pet-booking associations stored in localStorage.
        This is a workaround since the backend doesn't include pet_id in booking responses.
      </Alert>

      <Box sx={{ mb: 3 }}>
        <Button 
          variant="contained" 
          onClick={handleTestStorage} 
          sx={{ mr: 2 }}
        >
          Add Test Data
        </Button>
        <Button 
          variant="outlined" 
          color="warning" 
          onClick={handleClearAll}
        >
          Clear All
        </Button>
        <Button 
          variant="outlined" 
          onClick={loadAssociations}
          sx={{ ml: 2 }}
        >
          Refresh
        </Button>
      </Box>

      <Paper>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Booking ID</TableCell>
                <TableCell>Pet ID</TableCell>
                <TableCell>Pet Name</TableCell>
                <TableCell>Species</TableCell>
                <TableCell>Stored At</TableCell>
                <TableCell>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {associations.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} align="center" sx={{ py: 3 }}>
                    <Typography variant="body2" color="text.secondary">
                      No pet-booking associations stored
                    </Typography>
                  </TableCell>
                </TableRow>
              ) : (
                associations.map((assoc, index) => (
                  <TableRow key={index}>
                    <TableCell>
                      <Chip label={assoc.bookingId} size="small" color="primary" />
                    </TableCell>
                    <TableCell>
                      <Chip label={assoc.petId} size="small" color="secondary" />
                    </TableCell>
                    <TableCell>{assoc.petName}</TableCell>
                    <TableCell>{assoc.petSpecies}</TableCell>
                    <TableCell>
                      <Typography variant="caption">
                        {formatDate(assoc.timestamp)}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Button
                        size="small"
                        color="error"
                        onClick={() => {
                          petBookingStorage.removePetBookingAssociation(assoc.bookingId);
                          loadAssociations();
                        }}
                      >
                        Remove
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" gutterBottom>
          How it works:
        </Typography>
        <Typography variant="body2" color="text.secondary">
          • When creating/editing bookings with pets, the association is saved to localStorage<br/>
          • When displaying bookings, we first check localStorage for pet information<br/>
          • Associations are automatically cleaned up after 30 days<br/>
          • This is a temporary solution until the backend includes pet_id in booking responses
        </Typography>
      </Box>
    </Box>
  );
};

export default PetBookingDebug; 