import React, { useState } from 'react';
import {
  Box,
  AppBar,
  Toolbar,
  Typography,
  IconButton,
  Menu,
  MenuItem,
  Avatar,
  useMediaQuery,
  useTheme,
  Tooltip,
} from '@mui/material';
import {
  Menu as MenuIcon,
  Logout,
  Person,
  VpnKey,
} from '@mui/icons-material';
import { Outlet, useNavigate } from 'react-router-dom';
import Sidebar from './Sidebar';
import useAuthStore from '../../stores/authStore';

const MainLayout: React.FC = () => {
  const theme = useTheme();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  
  const { user, logout } = useAuthStore();

  const handleUserMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleUserMenuClose = () => {
    setAnchorEl(null);
  };

  const handleProfile = () => {
    handleUserMenuClose();
    navigate('/profile');
  };

  const handleChangePassword = () => {
    handleUserMenuClose();
    navigate('/change-password');
  };

  const handleLogout = async () => {
    handleUserMenuClose();
    try {
      await logout();
      navigate('/login');
    } catch (error) {
      console.error('Logout error:', error);
      // Force navigation even if logout fails
      navigate('/login');
    }
  };

  const toggleSidebar = () => {
    setSidebarOpen(!sidebarOpen);
  };

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
      {/* Sidebar */}
      <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />

      {/* Main Content */}
      <Box sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column' }}>
        {/* AppBar */}
        <AppBar 
          position="sticky" 
          elevation={1}
          sx={{ 
            zIndex: theme.zIndex.drawer + 1,
            backgroundColor: 'background.paper',
            color: 'text.primary',
            borderBottom: '1px solid',
            borderColor: 'divider',
          }}
        >
          <Toolbar>
            <IconButton
              edge="start"
              color="inherit"
              aria-label="menu"
              onClick={toggleSidebar}
              sx={{ mr: 2 }}
            >
              <MenuIcon />
            </IconButton>

            <Typography variant="h6" component="div" sx={{ flexGrow: 1, fontWeight: 600 }}>
              BlueMoon Management System
            </Typography>

            {/* User Menu */}
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Typography variant="body2" sx={{ mr: 1, display: { xs: 'none', sm: 'block' } }}>
                {user?.full_name}
              </Typography>
              
              <Tooltip title="Account settings">
                <IconButton
                  onClick={handleUserMenuOpen}
                  size="small"
                  sx={{ ml: 1 }}
                >
                  <Avatar sx={{ width: 32, height: 32, fontSize: '14px' }}>
                    {user?.full_name?.charAt(0)?.toUpperCase() || 'U'}
                  </Avatar>
                </IconButton>
              </Tooltip>
            </Box>

            <Menu
              anchorEl={anchorEl}
              open={Boolean(anchorEl)}
              onClose={handleUserMenuClose}
              onClick={handleUserMenuClose}
              PaperProps={{
                elevation: 0,
                sx: {
                  overflow: 'visible',
                  filter: 'drop-shadow(0px 2px 8px rgba(0,0,0,0.32))',
                  mt: 1.5,
                  '& .MuiAvatar-root': {
                    width: 32,
                    height: 32,
                    ml: -0.5,
                    mr: 1,
                  },
                },
              }}
              transformOrigin={{ horizontal: 'right', vertical: 'top' }}
              anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
            >
              <MenuItem onClick={handleProfile}>
                <Person sx={{ mr: 1 }} />
                Profile
              </MenuItem>
              <MenuItem onClick={handleChangePassword}>
                <VpnKey sx={{ mr: 1 }} />
                Change Password
              </MenuItem>
              <MenuItem onClick={handleLogout}>
                <Logout sx={{ mr: 1 }} />
                Logout
              </MenuItem>
            </Menu>
          </Toolbar>
        </AppBar>

        {/* Page Content */}
        <Box 
          component="main" 
          sx={{ 
            flexGrow: 1, 
            p: 3,
            backgroundColor: 'background.default',
            minHeight: 'calc(100vh - 64px)',
          }}
        >
          <Outlet />
        </Box>
      </Box>
    </Box>
  );
};

export default MainLayout; 