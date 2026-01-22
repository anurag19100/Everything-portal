import React from 'react';
import { Typography, Paper, Box } from '@mui/material';

const Services: React.FC = () => {
  return (
    <Box>
      <Typography variant="h4" gutterBottom>Services</Typography>
      <Paper sx={{ p: 2 }}>
        <Typography>Service management interface</Typography>
      </Paper>
    </Box>
  );
};

export default Services;
