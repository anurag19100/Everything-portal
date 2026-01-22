import React from 'react';
import { AppBar, Toolbar, Typography, Box } from '@mui/material';
import SmartToyIcon from '@mui/icons-material/SmartToy';

const Header: React.FC = () => {
  return (
    <AppBar position="static">
      <Toolbar>
        <SmartToyIcon sx={{ mr: 2 }} />
        <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
          Claude Chat Interface
        </Typography>
        <Box sx={{ display: 'flex', alignItems: 'center' }}>
          <Typography variant="body2" sx={{ mr: 2 }}>
            Everything Portal
          </Typography>
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default Header;
