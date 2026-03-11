#!/usr/bin/env node

/**
 * AgriVision API Gateway - Main Application
 * Organized, production-ready Node.js API gateway
 * 
 * Features:
 * - Modular architecture
 * - Security & Performance
 * - Agriculture-specific features
 * - East Africa optimizations
 * - Community features
 * - Business intelligence
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');

// Import configuration
const config = require('./config/config');
const logger = require('./utils/logger');

// Import middleware
const rateLimiter = require('./middleware/rateLimiter');
const requestId = require('./middleware/requestId');
const errorHandler = require('./middleware/errorHandler');
const auth = require('./middleware/auth');

// Import routes
const authRoutes = require('./routes/auth');
const weatherRoutes = require('./routes/weather');
const aiRoutes = require('./routes/ai');
const marketRoutes = require('./routes/market');
const smsRoutes = require('./routes/sms');
const mpesaRoutes = require('./routes/mpesa');
const communityRoutes = require('./routes/community');
const cooperativeRoutes = require('./routes/cooperative');
const analyticsRoutes = require('./routes/analytics');
const healthRoutes = require('./routes/health');

// Initialize Express app
const app = express();

// Create logs directory if it doesn't exist
if (!fs.existsSync('logs')) {
  fs.mkdirSync('logs');
}

// Security Middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// CORS configuration
app.use(cors({
  origin: config.NODE_ENV === 'production' 
    ? config.ALLOWED_ORIGINS?.split(',') || ['https://agrivision.com']
    : true,
  credentials: true,
  optionsSuccessStatus: 200
}));

// Compression
app.use(compression());

// Request logging
app.use(morgan('combined', {
  stream: { write: message => logger.info(message.trim()) }
}));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Apply rate limiting
app.use(rateLimiter.general);

// Request ID middleware
app.use(requestId);

// Health check (before auth)
app.use('/health', healthRoutes);

// API Documentation
app.get('/api/docs', (req, res) => {
  const apiDocs = {
    title: 'AgriVision API Gateway',
    version: '2.0.0',
    description: 'Production-ready API gateway for agricultural intelligence platform',
    baseUrl: `${req.protocol}://${req.get('host')}`,
    endpoints: {
      authentication: {
        register: 'POST /api/auth/register',
        login: 'POST /api/auth/login'
      },
      weather: {
        current: 'GET /api/weather/current',
        smartAlerts: 'GET /api/weather/smart-alerts'
      },
      ai: {
        cropDiagnosis: 'POST /api/ai/crop-diagnosis',
        soilAnalysis: 'POST /api/ai/soil-analysis',
        yieldPrediction: 'POST /api/ai/yield-prediction'
      },
      market: {
        intelligence: 'GET /api/market/intelligence',
        opportunities: 'GET /api/market/opportunities',
        prices: 'GET /api/market/prices'
      },
      sms: {
        send: 'POST /api/sms/send',
        templates: 'GET /api/sms/templates',
        sendTemplate: 'POST /api/sms/send-template'
      },
      mpesa: {
        stkPush: 'POST /api/mpesa/stkpush',
        payService: 'POST /api/mpesa/pay-service',
        transactions: 'GET /api/mpesa/transactions'
      },
      community: {
        posts: 'GET /api/community/posts',
        share: 'POST /api/community/share',
        profile: 'GET /api/community/profile/:userId'
      },
      cooperatives: {
        join: 'POST /api/cooperatives/join',
        info: 'GET /api/cooperatives/:cooperativeId'
      },
      analytics: {
        revenue: 'GET /api/analytics/revenue',
        sustainability: 'GET /api/analytics/sustainability'
      }
    },
    requestId: req.id
  };
  
  res.json(apiDocs);
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/weather', weatherRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/market', marketRoutes);
app.use('/api/sms', smsRoutes);
app.use('/api/mpesa', mpesaRoutes);
app.use('/api/community', communityRoutes);
app.use('/api/cooperatives', cooperativeRoutes);
app.use('/api/analytics', analyticsRoutes);

// Serve static files
app.use('/static', express.static(path.join(__dirname, '../web-interface')));

// Default route
app.get('/', (req, res) => {
  res.json({
    message: '🌾 Welcome to AgriVision API Gateway',
    version: '2.0.0',
    status: 'operational',
    documentation: '/api/docs',
    health: '/health',
    timestamp: new Date().toISOString(),
    requestId: req.id
  });
});

// Error handling middleware (must be last)
app.use(errorHandler);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    message: `${req.method} ${req.originalUrl} is not a valid endpoint`,
    documentation: '/api/docs',
    requestId: req.id
  });
});

// Graceful shutdown handling
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  process.exit(0);
});

// Error handling for uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

module.exports = app;