#!/usr/bin/env node

/**
 * AgriVision Complete API Gateway
 * Production-ready Node.js API gateway combining all features
 * 
 * This file integrates the enhanced features with the original API gateway
 * to provide a complete, production-ready solution.
 */

// Import the enhanced API gateway
const app = require('./api-gateway-enhanced');

// Import additional features
const {
  getMarketIntelligence,
  findPriceOpportunities,
  getFarmerProfile,
  getSMSTemplates,
  generateRevenueAnalytics,
  calculateSustainabilityScore
} = require('./api-gateway-features');

// Additional middleware and utilities
const express = require('express');
const path = require('path');
const fs = require('fs');

// Serve static documentation
app.use('/docs', express.static(path.join(__dirname, 'docs')));

// API Documentation endpoint
app.get('/api/docs', (req, res) => {
  const apiDocs = {
    title: 'AgriVision Enhanced API Gateway',
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
        soilAnalysis: 'POST /api/soil/analyze',
        yieldPrediction: 'POST /api/yield/predict'
      },
      market: {
        intelligence: 'GET /api/market/intelligence',
        opportunities: 'GET /api/market/opportunities',
        prices: 'GET /api/market/prices',
        history: 'GET /api/market/history/:crop'
      },
      sms: {
        send: 'POST /api/sms/send',
        templates: 'GET /api/sms/templates',
        sendTemplate: 'POST /api/sms/send-template',
        bulk: 'POST /api/sms/bulk'
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
      },
      notifications: {
        send: 'POST /api/notifications/send'
      },
      experts: {
        list: 'GET /api/experts',
        book: 'POST /api/experts/book'
      },
      agora: {
        token: 'POST /api/agora/token'
      },
      geocoding: {
        geocode: 'GET /api/geocode',
        reverseGeocode: 'GET /api/reverse-geocode'
      }
    },
    features: {
      security: [
        'Rate limiting',
        'CORS protection',
        'Security headers',
        'Input validation',
        'JWT authentication',
        'Request logging'
      ],
      agriculture: [
        'Smart weather alerts',
        'AI crop diagnosis',
        'Soil analysis',
        'Yield prediction',
        'Market intelligence'
      ],
      eastAfrica: [
        'SMS templates (English/Swahili)',
        'M-Pesa integration',
        'Local market data',
        'Multi-language support'
      ],
      community: [
        'Farmer profiles',
        'Knowledge sharing',
        'Cooperative support',
        'Expert consultation'
      ],
      business: [
        'Revenue analytics',
        'Sustainability scoring',
        'Price opportunities',
        'Performance tracking'
      ]
    },
    requestId: req.id
  };
  
  res.json(apiDocs);
});

// API status endpoint
app.get('/api/status', (req, res) => {
  const status = {
    service: 'AgriVision Enhanced API Gateway',
    version: '2.0.0',
    status: 'operational',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    environment: process.env.NODE_ENV || 'development',
    features: {
      authentication: true,
      weather: true,
      ai: process.env.ENABLE_AI_FEATURES !== 'false',
      payments: process.env.ENABLE_PAYMENT_FEATURES !== 'false',
      community: process.env.ENABLE_COMMUNITY_FEATURES !== 'false',
      analytics: process.env.ENABLE_ANALYTICS !== 'false'
    },
    services: {
      twilio: process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_ACCOUNT_SID !== 'your_twilio_sid',
      mpesa: process.env.MPESA_CONSUMER_KEY && process.env.MPESA_CONSUMER_KEY !== 'your_mpesa_key',
      firebase: fs.existsSync('./firebase-service-account.json'),
      huggingface: process.env.HUGGINGFACE_API_KEY && process.env.HUGGINGFACE_API_KEY !== 'your_hf_token',
      openai: process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== 'your_openai_key'
    },
    requestId: req.id
  };
  
  res.json(status);
});

// Metrics endpoint (if enabled)
if (process.env.ENABLE_METRICS_ENDPOINT === 'true') {
  app.get('/metrics', (req, res) => {
    const metrics = {
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      cpu: process.cpuUsage(),
      platform: process.platform,
      nodeVersion: process.version,
      pid: process.pid,
      requestId: req.id
    };
    
    res.json(metrics);
  });
}

// Graceful shutdown handling
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});

// Error handling for uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

module.exports = app;