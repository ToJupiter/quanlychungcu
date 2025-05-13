// src/theme/theme.ts
import { createTheme, responsiveFontSizes } from '@mui/material/styles';
import { grey, blue, pink } from '@mui/material/colors';

let darkTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: blue[300], // A lighter blue for dark mode
    },
    secondary: {
      main: pink['A200'], // A vibrant pink for accents
    },
    background: {
      default: '#121212', // Standard dark background
      paper: '#1e1e1e',   // Slightly lighter for paper elements like cards, dialogs
    },
    text: {
      primary: grey[50],   // Off-white for primary text
      secondary: grey[400], // Lighter grey for secondary text
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    h1: { fontSize: '2.5rem', fontWeight: 500 },
    h2: { fontSize: '2rem', fontWeight: 500 },
    h3: { fontSize: '1.75rem', fontWeight: 500 },
    h4: { fontSize: '1.5rem', fontWeight: 500 },
    h5: { fontSize: '1.25rem', fontWeight: 500 },
    h6: { fontSize: '1rem', fontWeight: 500 },
    button: {
      textTransform: 'none', // Keep button text case as is
      fontWeight: 600,
    },
  },
  components: {
    MuiAppBar: {
      styleOverrides: {
        root: {
          backgroundColor: '#1e1e1e', // Match paper for a flatter look
          boxShadow: '0px 2px 4px -1px rgba(0,0,0,0.2), 0px 4px 5px 0px rgba(0,0,0,0.14), 0px 1px 10px 0px rgba(0,0,0,0.12)', // Subtle shadow
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          backgroundImage: 'none', // Ensure no gradient overlays from default MUI dark
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8, // Softer button corners
        },
        containedPrimary: {
          '&:hover': {
            backgroundColor: blue[400],
          },
        },
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            '& fieldset': {
              // borderColor: grey[700], // Subtle border
            },
            '&:hover fieldset': {
              // borderColor: blue[300],
            },
            '&.Mui-focused fieldset': {
              // borderColor: blue[300],
            },
          },
        },
      },
    },
    MuiCard: {
        styleOverrides: {
            root: {
                border: `1px solid ${grey[800]}`, // Subtle border for cards
            }
        }
    }
  },
});

darkTheme = responsiveFontSizes(darkTheme);

export default darkTheme;