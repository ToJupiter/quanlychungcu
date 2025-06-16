import { createTheme } from '@mui/material/styles';

// Define custom colors inspired by Apple's design language
const colors = {
  primary: {
    main: '#007AFF', // iOS Blue
    light: '#4A90E2',
    dark: '#0056B3',
    contrastText: '#FFFFFF',
  },
  secondary: {
    main: '#FF9500', // iOS Orange
    light: '#FFB74D',
    dark: '#F57C00',
    contrastText: '#FFFFFF',
  },
  success: {
    main: '#34C759', // iOS Green
    light: '#4CAF50',
    dark: '#2E7D32',
  },
  warning: {
    main: '#FF9500', // iOS Orange
    light: '#FFB74D',
    dark: '#F57C00',
  },
  error: {
    main: '#FF3B30', // iOS Red
    light: '#F44336',
    dark: '#D32F2F',
  },
  info: {
    main: '#5AC8FA', // iOS Light Blue
    light: '#81C784',
    dark: '#388E3C',
  },
  background: {
    default: '#F2F2F7', // iOS System Background
    paper: '#FFFFFF',
  },
  text: {
    primary: '#000000',
    secondary: '#3C3C43', // iOS Secondary Label
  },
};

// Create the theme
const theme = createTheme({
  palette: {
    mode: 'light',
    ...colors,
  },
  typography: {
    fontFamily: [
      '-apple-system',
      'BlinkMacSystemFont',
      'SF Pro Display',
      'Segoe UI',
      'Roboto',
      'Helvetica Neue',
      'Arial',
      'sans-serif',
    ].join(','),
    h1: {
      fontSize: '2.5rem',
      fontWeight: 700,
      letterSpacing: '-0.02em',
    },
    h2: {
      fontSize: '2rem',
      fontWeight: 600,
      letterSpacing: '-0.01em',
    },
    h3: {
      fontSize: '1.75rem',
      fontWeight: 600,
      letterSpacing: '-0.01em',
    },
    h4: {
      fontSize: '1.5rem',
      fontWeight: 600,
    },
    h5: {
      fontSize: '1.25rem',
      fontWeight: 600,
    },
    h6: {
      fontSize: '1.125rem',
      fontWeight: 600,
    },
    body1: {
      fontSize: '1rem',
      lineHeight: 1.5,
    },
    body2: {
      fontSize: '0.875rem',
      lineHeight: 1.43,
    },
    button: {
      textTransform: 'none',
      fontWeight: 500,
    },
  },
  shape: {
    borderRadius: 12, // Apple-like rounded corners
  },
  components: {
    // AppBar customization
    MuiAppBar: {
      styleOverrides: {
        root: {
          backgroundColor: 'rgba(255, 255, 255, 0.95)',
          backdropFilter: 'blur(20px)',
          borderBottom: '1px solid rgba(0, 0, 0, 0.12)',
          boxShadow: 'none',
          color: colors.text.primary,
        },
      },
    },
    // Button customization
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 10,
          padding: '10px 20px',
          fontSize: '1rem',
          fontWeight: 500,
          textTransform: 'none',
          boxShadow: 'none',
          '&:hover': {
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
          },
        },
        contained: {
          '&:hover': {
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
          },
        },
      },
    },
    // Card customization
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 16,
          border: '1px solid rgba(0, 0, 0, 0.06)',
          boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
          '&:hover': {
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
          },
        },
      },
    },
    // Paper customization
    MuiPaper: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          border: '1px solid rgba(0, 0, 0, 0.06)',
        },
        elevation1: {
          boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
        },
        elevation2: {
          boxShadow: '0 2px 6px rgba(0, 0, 0, 0.12)',
        },
        elevation3: {
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
        },
      },
    },
    // TextField customization
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            borderRadius: 10,
            backgroundColor: '#FFFFFF',
            '& fieldset': {
              borderColor: 'rgba(0, 0, 0, 0.23)',
            },
            '&:hover fieldset': {
              borderColor: colors.primary.main,
            },
            '&.Mui-focused fieldset': {
              borderColor: colors.primary.main,
              borderWidth: 2,
            },
          },
        },
      },
    },
    // Chip customization
    MuiChip: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          fontWeight: 500,
        },
        filled: {
          backgroundColor: 'rgba(0, 122, 255, 0.1)',
          color: colors.primary.main,
          '&:hover': {
            backgroundColor: 'rgba(0, 122, 255, 0.15)',
          },
        },
      },
    },
    // Drawer customization
    MuiDrawer: {
      styleOverrides: {
        paper: {
          borderRight: '1px solid rgba(0, 0, 0, 0.12)',
          backgroundColor: 'rgba(255, 255, 255, 0.95)',
          backdropFilter: 'blur(20px)',
        },
      },
    },
    // List customization
    MuiListItemButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          margin: '2px 8px',
          '&:hover': {
            backgroundColor: 'rgba(0, 122, 255, 0.08)',
          },
          '&.Mui-selected': {
            backgroundColor: 'rgba(0, 122, 255, 0.12)',
            '&:hover': {
              backgroundColor: 'rgba(0, 122, 255, 0.16)',
            },
          },
        },
      },
    },
    // Table customization
    MuiTableHead: {
      styleOverrides: {
        root: {
          backgroundColor: 'rgba(0, 0, 0, 0.02)',
          '& .MuiTableCell-head': {
            fontWeight: 600,
            borderBottom: '2px solid rgba(0, 0, 0, 0.12)',
          },
        },
      },
    },
    MuiTableRow: {
      styleOverrides: {
        root: {
          '&:hover': {
            backgroundColor: 'rgba(0, 122, 255, 0.04)',
          },
        },
      },
    },
  },
  breakpoints: {
    values: {
      xs: 0,
      sm: 768,
      md: 1024,
      lg: 1280,
      xl: 1440,
    },
  },
});

export default theme; 