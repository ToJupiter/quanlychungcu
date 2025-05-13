// src/pages/DashboardPage.tsx
import React from 'react';
import { Typography, Grid, Paper, Box } from '@mui/material';
import PeopleIcon from '@mui/icons-material/People';
import ApartmentIcon from '@mui/icons-material/Apartment';
import PaymentsIcon from '@mui/icons-material/Payments';
import { Link as RouterLink } from 'react-router-dom';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ReactElement;
  linkTo?: string;
}

const StatCard: React.FC<StatCardProps> = ({ title, value, icon, linkTo }) => (
  <Grid item xs={12} sm={6} md={4}>
    <Paper
      elevation={3}
      component={linkTo ? RouterLink : 'div'}
      to={linkTo}
      sx={{
        p: 3,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        height: '100%',
        textDecoration: linkTo ? 'none' : 'inherit',
        '&:hover': linkTo ? { boxShadow: 6, transform: 'scale(1.02)', transition: 'transform 0.2s ease-in-out' } : {},
      }}
    >
      <Box sx={{ color: 'primary.main', fontSize: 40, mb: 1 }}>{icon}</Box>
      <Typography variant="h6" gutterBottom>
        {title}
      </Typography>
      <Typography variant="h4" component="p">
        {value}
      </Typography>
    </Paper>
  </Grid>
);


const DashboardPage: React.FC = () => {
  // In a real app, fetch these values from the backend
  const stats = [
    { title: 'Total Apartments', value: '50+', icon: <ApartmentIcon />, linkTo: '/apartments' }, // Placeholder
    { title: 'Total Households', value: '45+', icon: <PeopleIcon />, linkTo: '/households' }, // Placeholder
    { title: 'Pending Payments', value: '10+', icon: <PaymentsIcon />, linkTo: '/payments?status=Unpaid' }, // Placeholder
  ];

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ mb: 4 }}>
        Dashboard Overview
      </Typography>
      <Grid container spacing={3}>
        {stats.map((stat) => (
          <StatCard key={stat.title} title={stat.title} value={stat.value} icon={stat.icon} linkTo={stat.linkTo}/>
        ))}
      </Grid>

      {/* Placeholder for "Danh Sách Công Việc" from SDD */}
      <Paper elevation={3} sx={{ p: 2, mt: 4 }}>
        <Typography variant="h5" gutterBottom>
          Recent Activity / Tasks
        </Typography>
        <Typography color="text.secondary">
          (This section will display recent household registrations, payment updates, etc.
          Data would be fetched and displayed in a table or list format, similar to SDD mockup.)
        </Typography>
        {/* Example: <RecentActivityTable /> */}
      </Paper>
    </Box>
  );
};

export default DashboardPage;