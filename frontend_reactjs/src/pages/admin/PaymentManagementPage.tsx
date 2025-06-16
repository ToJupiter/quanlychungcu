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
  Payment,
  CheckCircle,
  Error,
} from '@mui/icons-material';
import apiService from '../../services/api';
import useAuthStore from '../../stores/authStore';
import type { PaymentDto, PaymentCreateRequest, HouseholdDto } from '../../types/api';

const PaymentManagementPage: React.FC = () => {
  const { user: currentUser } = useAuthStore();
  const [payments, setPayments] = useState<PaymentDto[]>([]);
  const [households, setHouseholds] = useState<HouseholdDto[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingPayment, setEditingPayment] = useState<PaymentDto | null>(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [paymentToDelete, setPaymentToDelete] = useState<PaymentDto | null>(null);
  const [bulkDialogOpen, setBulkDialogOpen] = useState(false);

  const [formData, setFormData] = useState<PaymentCreateRequest>({
    household_id: '',
    payment_type: 'electricity',
    amount: 0,
    due_date: '',
    status: 'unpaid',
    notes: '',
  });

  const [bulkFormData, setBulkFormData] = useState({
    payment_type: 'electricity',
    amount: 0,
    due_date: '',
  });

  const paymentTypes = [
    'electricity',
    'water',
    'internet',
    'parking',
    'maintenance',
    'management_fee',
    'other'
  ];

  const statusOptions = [
    { value: 'paid', label: 'Paid', color: 'success' },
    { value: 'unpaid', label: 'Unpaid', color: 'error' },
    { value: 'overdue', label: 'Overdue', color: 'warning' },
  ];

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      const householdsData = await apiService.getAllHouseholds();
      setHouseholds(householdsData);
      
      // Get payments for all households
      const allPayments: PaymentDto[] = [];
      for (const household of householdsData) {
        try {
          const payments = await apiService.getPaymentsByHousehold(household.household_id);
          allPayments.push(...payments);
        } catch (err) {
          // Continue if some household payments fail to load
          console.warn(`Failed to load payments for household ${household.household_id}`);
        }
      }
      setPayments(allPayments);
    } catch (err: any) {
      setError(err.message || 'Failed to load payments');
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    const statusConfig = statusOptions.find(s => s.value === status);
    return statusConfig?.color || 'default';
  };

  const handleOpenDialog = (payment?: PaymentDto) => {
    if (payment) {
      setEditingPayment(payment);
      setFormData({
        household_id: payment.household_id,
        payment_type: payment.payment_type,
        amount: payment.amount,
        due_date: payment.due_date.split('T')[0], // Extract date part
        status: payment.status,
        notes: payment.notes || '',
      });
    } else {
      setEditingPayment(null);
      setFormData({
        household_id: '',
        payment_type: 'electricity',
        amount: 0,
        due_date: '',
        status: 'unpaid',
        notes: '',
      });
    }
    setDialogOpen(true);
  };

  const handleCloseDialog = () => {
    setDialogOpen(false);
    setEditingPayment(null);
  };

  const handleFormChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === 'amount' ? parseFloat(value) || 0 : value,
    }));
  };

  const handleSubmit = async () => {
    try {
      setError(null);
      
      if (editingPayment) {
        await apiService.updatePayment(editingPayment.payment_id, formData);
      } else {
        await apiService.createPayment(formData);
      }
      
      await loadData();
      handleCloseDialog();
    } catch (err: any) {
      setError(err.message || 'Failed to save payment');
    }
  };

  const handleBulkCreate = async () => {
    try {
      setError(null);
      await apiService.createBulkPayments(bulkFormData);
      await loadData();
      setBulkDialogOpen(false);
    } catch (err: any) {
      setError(err.message || 'Failed to create bulk payments');
    }
  };

  const handleUpdatePaymentStatus = async (paymentId: string, newStatus: string) => {
    try {
      setError(null);
      const paymentDate = newStatus === 'paid' ? new Date().toISOString().split('T')[0] : undefined;
      await apiService.updatePaymentStatus(paymentId, newStatus, paymentDate);
      await loadData();
    } catch (err: any) {
      setError(err.message || 'Failed to update payment status');
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString();
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
    }).format(amount);
  };

  const handleDeletePayment = async () => {
    if (!paymentToDelete) return;
    
    try {
      setError(null);
      await apiService.deletePayment(paymentToDelete.payment_id);
      await loadData();
      setDeleteDialogOpen(false);
      setPaymentToDelete(null);
    } catch (err: any) {
      setError(err.message || 'Failed to delete payment');
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
            Payment Management
          </Typography>
          <Stack direction="row" spacing={2}>
            <Button
              variant="outlined"
              onClick={() => setBulkDialogOpen(true)}
            >
              Bulk Create
            </Button>
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={() => handleOpenDialog()}
              sx={{ background: 'linear-gradient(45deg, #2196F3 30%, #21CBF3 90%)' }}
            >
              Add Payment
            </Button>
          </Stack>
        </Box>

        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Payment ID</TableCell>
                <TableCell>Apartment</TableCell>
                <TableCell>Type</TableCell>
                <TableCell>Amount</TableCell>
                <TableCell>Due Date</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Payment Date</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {payments.map((payment) => (
                <TableRow key={payment.payment_id}>
                  <TableCell>{payment.payment_id}</TableCell>
                  <TableCell>{payment.apartment_number}</TableCell>
                  <TableCell>{payment.payment_type}</TableCell>
                  <TableCell>{formatCurrency(payment.amount)}</TableCell>
                  <TableCell>{formatDate(payment.due_date)}</TableCell>
                  <TableCell>
                    <Chip
                      label={payment.status}
                      color={getStatusColor(payment.status) as any}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    {payment.payment_date ? formatDate(payment.payment_date) : '-'}
                  </TableCell>
                  <TableCell align="center">
                    <Stack direction="row" spacing={1} justifyContent="center">
                      {payment.status === 'unpaid' && (
                        <Tooltip title="Mark as Paid">
                          <IconButton
                            size="small"
                            color="success"
                            onClick={() => handleUpdatePaymentStatus(payment.payment_id, 'paid')}
                          >
                            <CheckCircle />
                          </IconButton>
                        </Tooltip>
                      )}
                      <Tooltip title="Edit Payment">
                        <IconButton
                          size="small"
                          onClick={() => handleOpenDialog(payment)}
                        >
                          <Edit />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Delete Payment">
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => {
                            setPaymentToDelete(payment);
                            setDeleteDialogOpen(true);
                          }}
                        >
                          <Delete />
                        </IconButton>
                      </Tooltip>
                    </Stack>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>

        {/* Create/Edit Payment Dialog */}
        <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
          <DialogTitle>
            {editingPayment ? 'Edit Payment' : 'Add New Payment'}
          </DialogTitle>
          <DialogContent>
            <Box display="flex" flexDirection="column" gap={2} mt={1}>
              <FormControl fullWidth>
                <InputLabel>Household</InputLabel>
                <Select
                  value={formData.household_id}
                  onChange={(e) => setFormData(prev => ({ ...prev, household_id: e.target.value }))}
                  label="Household"
                  disabled={!!editingPayment}
                >
                  {households.map((household) => (
                    <MenuItem key={household.household_id} value={household.household_id}>
                      {household.apartment_number} - {household.head_full_name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <FormControl fullWidth>
                <InputLabel>Payment Type</InputLabel>
                <Select
                  value={formData.payment_type}
                  onChange={(e) => setFormData(prev => ({ ...prev, payment_type: e.target.value }))}
                  label="Payment Type"
                >
                  {paymentTypes.map((type) => (
                    <MenuItem key={type} value={type}>
                      {type.charAt(0).toUpperCase() + type.slice(1).replace('_', ' ')}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <TextField
                name="amount"
                label="Amount (VND)"
                type="number"
                value={formData.amount}
                onChange={handleFormChange}
                fullWidth
                required
                inputProps={{ min: 0 }}
              />
              <TextField
                name="due_date"
                label="Due Date"
                type="date"
                value={formData.due_date}
                onChange={handleFormChange}
                fullWidth
                required
                InputLabelProps={{ shrink: true }}
              />
              <FormControl fullWidth>
                <InputLabel>Status</InputLabel>
                <Select
                  value={formData.status}
                  onChange={(e) => setFormData(prev => ({ ...prev, status: e.target.value }))}
                  label="Status"
                >
                  {statusOptions.map((status) => (
                    <MenuItem key={status.value} value={status.value}>
                      {status.label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <TextField
                name="notes"
                label="Notes"
                value={formData.notes}
                onChange={handleFormChange}
                fullWidth
                multiline
                rows={3}
              />
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseDialog}>Cancel</Button>
            <Button onClick={handleSubmit} variant="contained">
              {editingPayment ? 'Update' : 'Create'}
            </Button>
          </DialogActions>
        </Dialog>

        {/* Bulk Create Dialog */}
        <Dialog open={bulkDialogOpen} onClose={() => setBulkDialogOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Create Bulk Payments</DialogTitle>
          <DialogContent>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              This will create the same payment for all households.
            </Typography>
            <Box display="flex" flexDirection="column" gap={2} mt={2}>
              <FormControl fullWidth>
                <InputLabel>Payment Type</InputLabel>
                <Select
                  value={bulkFormData.payment_type}
                  onChange={(e) => setBulkFormData(prev => ({ ...prev, payment_type: e.target.value }))}
                  label="Payment Type"
                >
                  {paymentTypes.map((type) => (
                    <MenuItem key={type} value={type}>
                      {type.charAt(0).toUpperCase() + type.slice(1).replace('_', ' ')}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <TextField
                label="Amount (VND)"
                type="number"
                value={bulkFormData.amount}
                onChange={(e) => setBulkFormData(prev => ({ ...prev, amount: parseFloat(e.target.value) || 0 }))}
                fullWidth
                required
                inputProps={{ min: 0 }}
              />
              <TextField
                label="Due Date"
                type="date"
                value={bulkFormData.due_date}
                onChange={(e) => setBulkFormData(prev => ({ ...prev, due_date: e.target.value }))}
                fullWidth
                required
                InputLabelProps={{ shrink: true }}
              />
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setBulkDialogOpen(false)}>Cancel</Button>
            <Button onClick={handleBulkCreate} variant="contained">
              Create for All Households
            </Button>
          </DialogActions>
        </Dialog>

        {/* Delete Confirmation Dialog */}
        <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
          <DialogTitle>Confirm Delete</DialogTitle>
          <DialogContent>
            <Typography>
              Are you sure you want to delete this payment? This action cannot be undone.
            </Typography>
            {paymentToDelete && (
              <Box mt={2}>
                <Typography variant="body2" color="text.secondary">
                  Payment ID: {paymentToDelete.payment_id}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Type: {paymentToDelete.payment_type}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Amount: {formatCurrency(paymentToDelete.amount)}
                </Typography>
              </Box>
            )}
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
            <Button onClick={handleDeletePayment} color="error" variant="contained">
              Delete
            </Button>
          </DialogActions>
        </Dialog>
      </Paper>
    </Box>
  );
};

export default PaymentManagementPage; 