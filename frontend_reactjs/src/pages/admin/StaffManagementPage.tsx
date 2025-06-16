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
  AdminPanelSettings,
  AccountBalance,
  VpnKey,
  ToggleOn,
  ToggleOff,
} from '@mui/icons-material';
import apiService from '../../services/api';
import useAuthStore from '../../stores/authStore';
import type { User } from '../../types/auth';
import type { StaffDto, StaffCreateRequest } from '../../types/api';

const StaffManagementPage: React.FC = () => {
  const { user: currentUser } = useAuthStore();
  const [staff, setStaff] = useState<StaffDto[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingStaff, setEditingStaff] = useState<StaffDto | null>(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [staffToDelete, setStaffToDelete] = useState<StaffDto | null>(null);
  const [resetPasswordDialogOpen, setResetPasswordDialogOpen] = useState(false);
  const [staffToResetPassword, setStaffToResetPassword] = useState<StaffDto | null>(null);
  const [newPassword, setNewPassword] = useState('');

  const [formData, setFormData] = useState<StaffCreateRequest>({
    full_name: '',
    email: '',
    phone_number: '',
    password: '',
    status: 'active',
    roles: 0, // Default to Admin
  });

  const roles = [
    { value: 0, label: 'Admin', color: 'error', icon: <AdminPanelSettings /> },
    { value: 1, label: 'Accountant', color: 'warning', icon: <AccountBalance /> },
  ];

  useEffect(() => {
    loadStaff();
  }, []);

  const loadStaff = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await apiService.getAllStaff();
      setStaff(data);
    } catch (err: any) {
      setError(err.message || 'Failed to load staff');
    } finally {
      setLoading(false);
    }
  };

  const getRoleColor = (roles: number) => {
    const roleConfig = roles === 0 ? 'error' : 'warning';
    return roleConfig;
  };

  const getRoleIcon = (roles: number) => {
    return roles === 0 ? <AdminPanelSettings /> : <AccountBalance />;
  };

  const getRoleLabel = (roles: number) => {
    return roles === 0 ? 'Admin' : 'Accountant';
  };

  const handleOpenDialog = (staffMember?: StaffDto) => {
    if (staffMember) {
      setEditingStaff(staffMember);
      setFormData({
        full_name: staffMember.full_name,
        email: staffMember.email,
        phone_number: staffMember.phone_number,
        password: '', // Don't prefill password for editing
        status: staffMember.status,
        roles: staffMember.roles,
      });
    } else {
      setEditingStaff(null);
      setFormData({
        full_name: '',
        email: '',
        phone_number: '',
        password: '',
        status: 'active',
        roles: 0,
      });
    }
    setDialogOpen(true);
  };

  const handleCloseDialog = () => {
    setDialogOpen(false);
    setEditingStaff(null);
  };

  const handleFormChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleRoleChange = (value: number) => {
    setFormData(prev => ({
      ...prev,
      roles: value,
    }));
  };

  const handleStatusChange = (value: string) => {
    setFormData(prev => ({
      ...prev,
      status: value,
    }));
  };

  const handleSubmit = async () => {
    try {
      setError(null);
      
      if (editingStaff) {
        // Update existing staff
        const updateData = {
          full_name: formData.full_name,
          email: formData.email,
          phone_number: formData.phone_number,
          status: formData.status,
          roles: formData.roles,
        };
        
        await apiService.updateStaff(editingStaff.staff_id, updateData);
      } else {
        // Create new staff
        await apiService.createStaff(formData);
      }
      
      await loadStaff();
      handleCloseDialog();
    } catch (err: any) {
      setError(err.message || 'Failed to save staff member');
    }
  };

  const handleDeleteClick = (staffMember: StaffDto) => {
    setStaffToDelete(staffMember);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    if (!staffToDelete) return;
    
    try {
      setError(null);
      await apiService.deleteStaff(staffToDelete.staff_id);
      await loadStaff();
      setDeleteDialogOpen(false);
      setStaffToDelete(null);
    } catch (err: any) {
      setError(err.message || 'Failed to delete staff member');
    }
  };

  const handleToggleStatus = async (staffMember: StaffDto) => {
    try {
      setError(null);
      const newStatus = staffMember.status === 'active' ? 'inactive' : 'active';
      await apiService.updateStaffStatus(staffMember.staff_id, newStatus);
      await loadStaff();
    } catch (err: any) {
      setError(err.message || 'Failed to update staff status');
    }
  };

  const handleResetPasswordClick = (staffMember: StaffDto) => {
    setStaffToResetPassword(staffMember);
    setNewPassword('');
    setResetPasswordDialogOpen(true);
  };

  const handleResetPasswordConfirm = async () => {
    if (!staffToResetPassword || !newPassword) return;
    
    try {
      setError(null);
      await apiService.resetStaffPassword(staffToResetPassword.staff_id, newPassword);
      setResetPasswordDialogOpen(false);
      setStaffToResetPassword(null);
      setNewPassword('');
    } catch (err: any) {
      setError(err.message || 'Failed to reset password');
    }
  };

  const canEditStaff = (staffMember: StaffDto) => {
    return currentUser?.staff_id !== staffMember.staff_id;
  };

  const canDeleteStaff = (staffMember: StaffDto) => {
    return currentUser?.staff_id !== staffMember.staff_id;
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
            Staff Management
          </Typography>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={() => handleOpenDialog()}
            sx={{ background: 'linear-gradient(45deg, #2196F3 30%, #21CBF3 90%)' }}
          >
            Add Staff Member
          </Button>
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
                <TableCell>Staff ID</TableCell>
                <TableCell>Full Name</TableCell>
                <TableCell>Email</TableCell>
                <TableCell>Phone</TableCell>
                <TableCell>Role</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Created At</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {staff.map((staffMember) => (
                <TableRow key={staffMember.staff_id}>
                  <TableCell>{staffMember.staff_id}</TableCell>
                  <TableCell>{staffMember.full_name}</TableCell>
                  <TableCell>{staffMember.email}</TableCell>
                  <TableCell>{staffMember.phone_number}</TableCell>
                  <TableCell>
                    <Chip
                      icon={getRoleIcon(staffMember.roles)}
                      label={getRoleLabel(staffMember.roles)}
                      color={getRoleColor(staffMember.roles) as any}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={staffMember.status}
                      color={staffMember.status === 'active' ? 'success' : 'default'}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>{new Date(staffMember.created_at).toLocaleDateString()}</TableCell>
                  <TableCell align="center">
                    <Stack direction="row" spacing={1} justifyContent="center">
                      <Tooltip title="Edit Staff">
                        <IconButton
                          size="small"
                          onClick={() => handleOpenDialog(staffMember)}
                          disabled={!canEditStaff(staffMember)}
                        >
                          <Edit />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Reset Password">
                        <IconButton
                          size="small"
                          onClick={() => handleResetPasswordClick(staffMember)}
                          disabled={!canEditStaff(staffMember)}
                        >
                          <VpnKey />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title={`${staffMember.status === 'active' ? 'Deactivate' : 'Activate'} Staff`}>
                        <IconButton
                          size="small"
                          onClick={() => handleToggleStatus(staffMember)}
                          disabled={!canEditStaff(staffMember)}
                        >
                          {staffMember.status === 'active' ? <ToggleOff /> : <ToggleOn />}
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Delete Staff">
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => handleDeleteClick(staffMember)}
                          disabled={!canDeleteStaff(staffMember)}
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

        {/* Create/Edit Staff Dialog */}
        <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
          <DialogTitle>
            {editingStaff ? 'Edit Staff Member' : 'Add New Staff Member'}
          </DialogTitle>
          <DialogContent>
            <Box display="flex" flexDirection="column" gap={2} mt={1}>
              <TextField
                name="full_name"
                label="Full Name"
                value={formData.full_name}
                onChange={handleFormChange}
                fullWidth
                required
              />
              <TextField
                name="email"
                label="Email"
                type="email"
                value={formData.email}
                onChange={handleFormChange}
                fullWidth
                required
              />
              <TextField
                name="phone_number"
                label="Phone Number"
                value={formData.phone_number}
                onChange={handleFormChange}
                fullWidth
                required
              />
              {!editingStaff && (
                <TextField
                  name="password"
                  label="Password"
                  type="password"
                  value={formData.password}
                  onChange={handleFormChange}
                  fullWidth
                  required
                />
              )}
              <FormControl fullWidth>
                <InputLabel>Role</InputLabel>
                <Select
                  value={formData.roles}
                  onChange={(e) => handleRoleChange(e.target.value as number)}
                  label="Role"
                >
                  {roles.map((role) => (
                    <MenuItem key={role.value} value={role.value}>
                      <Box display="flex" alignItems="center" gap={1}>
                        {role.icon}
                        {role.label}
                      </Box>
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <FormControl fullWidth>
                <InputLabel>Status</InputLabel>
                <Select
                  value={formData.status}
                  onChange={(e) => handleStatusChange(e.target.value)}
                  label="Status"
                >
                  <MenuItem value="active">Active</MenuItem>
                  <MenuItem value="inactive">Inactive</MenuItem>
                </Select>
              </FormControl>
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseDialog}>Cancel</Button>
            <Button onClick={handleSubmit} variant="contained">
              {editingStaff ? 'Update' : 'Create'}
            </Button>
          </DialogActions>
        </Dialog>

        {/* Delete Confirmation Dialog */}
        <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
          <DialogTitle>Confirm Delete</DialogTitle>
          <DialogContent>
            <Typography>
              Are you sure you want to delete staff member "{staffToDelete?.full_name}"?
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

        {/* Reset Password Dialog */}
        <Dialog open={resetPasswordDialogOpen} onClose={() => setResetPasswordDialogOpen(false)}>
          <DialogTitle>Reset Password</DialogTitle>
          <DialogContent>
            <Typography gutterBottom>
              Reset password for "{staffToResetPassword?.full_name}":
            </Typography>
            <TextField
              label="New Password"
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              fullWidth
              margin="normal"
              required
            />
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setResetPasswordDialogOpen(false)}>Cancel</Button>
            <Button 
              onClick={handleResetPasswordConfirm} 
              variant="contained"
              disabled={!newPassword}
            >
              Reset Password
            </Button>
          </DialogActions>
        </Dialog>
      </Paper>
    </Box>
  );
};

export default StaffManagementPage; 