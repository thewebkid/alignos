const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/alignos';

// Middleware
app.use(cors());
app.use(express.json());
app.set('trust proxy', true);


// Database Connection
mongoose.connect(MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('Could not connect to MongoDB:', err));

// API Routes (prefix with /api to distinguish from static files)
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'AlignOS API is running',
    timestamp: new Date().toISOString()
  });
});

// Serve static files from Vue build
const clientPath = path.join(__dirname, '../client/dist');
app.use(express.static(clientPath, {
  maxAge: '1d', // Cache static assets for 1 day
  etag: true,
  extensions: ['html'] // Try .html extension for routes without extensions
}));

// Serve .well-known directory for ACME certificate verification
app.use('/.well-known', express.static(path.join(__dirname, '../client/public/.well-known'), {
  maxAge: 0, // No caching for ACME challenges
  dotfiles: 'allow'
}));

// SPA fallback - serve index.html for all non-API routes
// This allows Vue Router to handle client-side routing
app.use((req, res) => {
  res.sendFile(path.join(clientPath, 'index.html'));
});

// Start Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Serving static files from: ${clientPath}`);
  console.log(`Access URLs:`);
  console.log(`  Local:    http://localhost:${PORT}`);
  console.log(`  Network:  http://192.168.50.209:${PORT}`);
  console.log(`  WAN:      https://alignos.cosmiccreation.net:${PORT}`);
});
