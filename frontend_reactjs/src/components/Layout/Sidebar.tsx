import React from 'react';
import {
  Box,
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Typography,
  Divider,
  Chip,
} from '@mui/material';
import {
  Dashboard,
  People,
  Home,
  Apartment,
  Payment,
  Analytics,
  Assessment,
  AdminPanelSettings,
  AccountBalance,
} from '@mui/icons-material';
import { useNavigate, useLocation } from 'react-router-dom';
import useAuthStore from '../../stores/authStore';

interface SidebarProps {
  open: boolean;
  onClose: () => void;
}

const Sidebar: React.FC<SidebarProps> = ({ open, onClose }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, isAdmin, isAccountant } = useAuthStore();

  const handleNavigation = (path: string) => {
    navigate(path);
    onClose();
  };

  const isActive = (path: string) => {
    return location.pathname === path;
  };

  const getRoleColor = (roles: number) => {
    return roles === 0 ? 'error' : 'warning'; // Admin = error (red), Accountant = warning (orange)
  };

  const getRoleLabel = (roles: number) => {
    return roles === 0 ? 'Admin' : 'Accountant';
  };

  const menuItems = [
    {
      title: 'Dashboard',
      icon: <Dashboard />,
      path: '/dashboard',
      allowAdmin: true,
      allowAccountant: true
    },
    {
      title: 'Staff Management',
      icon: <People />,
      path: '/staff',
      allowAdmin: true,
      allowAccountant: false
    },
    {
      title: 'Apartment Management',
      icon: <Apartment />,
      path: '/apartments',
      allowAdmin: true,
      allowAccountant: false
    },
    {
      title: 'Household Management',
      icon: <Home />,
      path: '/households',
      allowAdmin: true,
      allowAccountant: false
    },
    {
      title: 'Payment Management',
      icon: <Payment />,
      path: '/payments',
      allowAdmin: true,
      allowAccountant: true
    },
    {
      title: 'Analytics',
      icon: <Analytics />,
      path: '/analytics',
      allowAdmin: true,
      allowAccountant: true
    },
    {
      title: 'Financial Reports',
      icon: <Assessment />,
      path: '/financial-reports',
      allowAdmin: true,
      allowAccountant: true
    },
  ];

  const filteredMenuItems = menuItems.filter(item => {
    if (isAdmin()) return item.allowAdmin;
    if (isAccountant()) return item.allowAccountant;
    return false;
  });

  const drawerContent = (
    <Box sx={{ width: 280, height: '100%' }}>
      {/* Header */}
      <Box sx={{ p: 3, borderBottom: '1px solid', borderColor: 'divider' }}>
        <Typography variant="h6" sx={{ fontWeight: 600, mb: 1 }}>
          BlueMoon
        </Typography>
        {user && (
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Typography variant="body2" color="text.secondary">
              {user.full_name}
            </Typography>
            <Chip 
              label={getRoleLabel(user.roles)} 
              size="small" 
              color={getRoleColor(user.roles) as any}
              icon={user.roles === 0 ? <AdminPanelSettings /> : <AccountBalance />}
            />
          </Box>
        )}
      </Box>

      {/* Navigation */}
      <List sx={{ pt: 2 }}>
        {filteredMenuItems.map((item) => (
          <ListItem key={item.path} disablePadding>
            <ListItemButton
              onClick={() => handleNavigation(item.path)}
              selected={isActive(item.path)}
              sx={{
                mx: 1,
                borderRadius: 1,
                '&.Mui-selected': {
                  backgroundColor: 'primary.main',
                  color: 'primary.contrastText',
                  '&:hover': {
                    backgroundColor: 'primary.dark',
                  },
                  '& .MuiListItemIcon-root': {
                    color: 'primary.contrastText',
                  },
                },
              }}
            >
              <ListItemIcon sx={{ minWidth: 40 }}>
                {item.icon}
              </ListItemIcon>
              <ListItemText 
                primary={item.title}
                primaryTypographyProps={{
                  fontSize: '0.875rem',
                  fontWeight: isActive(item.path) ? 600 : 400,
                }}
              />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Box>
  );

  return (
    <Drawer
      anchor="left"
      open={open}
      onClose={onClose}
      sx={{
        '& .MuiDrawer-paper': {
          boxSizing: 'border-box',
          width: 280,
        },
      }}
    >
      {drawerContent}
    </Drawer>
  );
};

export default Sidebar; 