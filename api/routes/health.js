/**
 * Health check routes for AgriVision API Gateway
 */

const express = require('express');
const router = express.Router();
const fs = require('fs');
const config = require('../config/config');

// Health check endpoint
router.get('/', (req, res) => {
  const healthCheck = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: '2.0.0',
    environment: config.NODE_ENV,
    services: {
      weather: 'operational',
      sms: config.TWILIO_ACCOUNT_SID !== 'your_twilio_sid' ? 'operational' : 'mock',
      firebase: fs.existsSync('./firebase-service-account.json') ? 'operational' : 'mock',
      mpesa: config.MPESA_CONSUMER_KEY !== 'your_mpesa_key' ? 'operational' : 'mock',
      ai: config.HUGGINGFACE_API_KEY !== 'your_hf_token' ? 'operational' : 'mock'
    },
    features: {
      ai: config.ENABLE_AI_FEATURES,
      payments: config.ENABLE_PAYMENT_FEATURES,
      community: config.ENABLE_COMMUNITY_FEATURES,
      analytics: config.ENABLE_ANALYTICS
    },
    requestId: req.id
  };
  
  res.json(healthCheck);
});

// Detailed health check
router.get('/detailed', (req, res) => {
  const detailed = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpu: process.cpuUsage(),
    platform: process.platform,
    nodeVersion: process.version,
    pid: process.pid,
    environment: config.NODE_ENV,
    services: {
      weather: {
        status: 'operational',
        url: config.WEATHER_API_URL,
        cache_ttl: config.WEATHER_CACHE_TTL
      },
      sms: {
        status: config.TWILIO_ACCOUNT_SID !== 'your_twilio_sid' ? 'operational' : 'mock',
        provider: 'twilio',
        configured: config.TWILIO_ACCOUNT_SID !== 'your_twilio_sid'
      },
      mpesa: {
        status: config.MPESA_CONSUMER_KEY !== 'your_mpesa_key' ? 'operational' : 'mock',
        environment: config.MPESA_ENV,
        configured: config.MPESA_CONSUMER_KEY !== 'your_mpesa_key'
      },
      ai: {
        status: config.HUGGINGFACE_API_KEY !== 'your_hf_token' ? 'operational' : 'mock',
        providers: ['huggingface', 'openai'],
        configured: config.HUGGINGFACE_API_KEY !== 'your_hf_token'
      }
    },
    features: {
      ai_features: config.ENABLE_AI_FEATURES,
      payment_features: config.ENABLE_PAYMENT_FEATURES,
      community_features: config.ENABLE_COMMUNITY_FEATURES,
      analytics: config.ENABLE_ANALYTICS
    },
    configuration: {
      default_country: config.DEFAULT_COUNTRY,
      default_currency: config.DEFAULT_CURRENCY,
      default_language: config.DEFAULT_LANGUAGE,
      supported_languages: config.SUPPORTED_LANGUAGES.split(',')
    },
    requestId: req.id
  };
  
  res.json(detailed);
});

// Readiness probe
router.get('/ready', (req, res) => {
  // Check if all critical services are ready
  const ready = {
    status: 'ready',
    timestamp: new Date().toISOString(),
    checks: {
      server: true,
      memory: process.memoryUsage().heapUsed < 1000000000, // Less than 1GB
      uptime: process.uptime() > 5 // At least 5 seconds uptime
    },
    requestId: req.id
  };
  
  const allReady = Object.values(ready.checks).every(check => check === true);
  
  if (allReady) {
    res.json(ready);
  } else {
    res.status(503).json({
      ...ready,
      status: 'not ready'
    });
  }
});

// Liveness probe
router.get('/live', (req, res) => {
  res.json({
    status: 'alive',
    timestamp: new Date().toISOString(),
    requestId: req.id
  });
});

module.exports = router;